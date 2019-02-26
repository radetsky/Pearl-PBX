#===============================================================================
#
#         FILE:  Queues.pm
#
#  DESCRIPTION:  PearlPBX Queues management API
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  2.0
#      CREATED:  23.06.12
#     MODIFIED:  25.07.17
#===============================================================================
=head1 NAME

PearlPBX::Queues

=head1 SYNOPSIS

	use PearlPBX::Queues;

=cut

package PearlPBX::Queues;

use 5.8.0;
use strict;
use warnings;

use DBI;
use Config::General;
use JSON::XS;
use NetSDS::Util::String;

use PearlPBX::Config qw/conf/;
use PearlPBX::DB qw/pearlpbx_db/;
use PearlPBX::HttpUtils qw/http_response/;

use Exporter;
use parent qw(Exporter);

our @EXPORT = qw (
    queues_list
    queues_getqueue
    queues_setqueue
    queues_delqueue
    queues_listmembers
    queues_addmember
    queues_removemember
);

sub queues_list {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $format = $params->{'format'};

    use constant HEADER => {
        'li' => '<ul class="nav nav-tabs">'
    };

    use constant FOOTER => {
        'li' => '</ul>'
    };

    use constant BODY => {
        'li' => '<li><a href="#pearlpbx_queues_edit" data-toggle="modal" onClick="pearlpbx_queues_load_by_name(\'%s\')">%s</a></li>'
    };

    unless ( defined ( $format ) ) {
        return http_response($env,400,"Format is unavailable");
    }

    my $sql = "select name from public.queues order by name";
    my $qnames = pearlpbx_db()->selectall_arrayref($sql);
    my $count = @{$qnames};

    unless ( $count ) {
        return http_response($env,200,'Queues not defined');
    }

    my $header = HEADER->{$format};
    my $footer = FOOTER->{$format};
    my $body   = '';

    foreach my $q ( @{$qnames} ) {
        $body .= sprintf(BODY->{$format},$q->[0],$q->[0]);
    }

    my $text_response = $header . $body . $footer;

    return http_response($env,200,$text_response);

}

=item B<queues_getqueue>

    Looking for queue in the database and returns all fields

=cut

sub queues_getqueue {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $qname  = $params->{'name'};

    my $sql = "select * from public.queues where name=?";
    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute ($qname); };
    if ( $@ ) {
        return http_response($env,400,pearlpbx_db()->stderr);
    }
    my $row = $sth->fetchrow_hashref;
    return http_response($env,200,encode_json($row));

}

=item B<queues_listmembers>

    Searching in the database queue members and returns the list

=cut

sub queues_listmembers {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $qname = $params->{'name'};

    my $sql = "select membername,interface from queue_members where queue_name = ? order by membername";
    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute ($qname); };
    if ( $@ ) {
        return http_response($env,400,pearlpbx_db()->stderr);
    }

    my @rows;
    while (my $row = $sth->fetchrow_hashref) {
        push @rows,$row;
    }

    return http_response($env,200,encode_json(\@rows));

}

=item B<queues_setqueue>

    Updates queue properties in the database

=cut

sub queues_setqueue {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $oldname  = $params->{'oldname'} // '';
    my $name     = $params->{'name'} // '';
    my $strategy = $params->{'strategy'} // 'ringall';
    my $timeout  = $params->{'timeout'} ne '' ? $params->{'timeout'} : 10;
    my $maxlen   = $params->{'maxlen'} ne '' ? $params->{'maxlen'} : 5;

    if ($name eq '' ) {
        return http_response($env,400,"Name can not be empty!");
    }

    if ($oldname eq '' ) {
        return queues_addqueue ( $env, $name, $strategy, $timeout, $maxlen );
    }

    #  Сохраняем параметры группы
    my $sql = "update public.queues set name=?, strategy=?, timeout=?, maxlen=? where name=?";
    my $sth = pearlpbx_db()->prepare($sql);
    eval {
        $sth->execute ($name, $strategy, $timeout, $maxlen, $oldname);
    };
    if ($@) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }

    # Если у группы новое имя, то стоит и членам группы поменять название группы
    if ( $oldname ne $name ) {
        $sql = "update public.queue_members set queue_name=? where queue_name=?";
        $sth = pearlpbx_db()->prepare($sql);
        eval {
          $sth->execute ($name, $oldname);
        };
        if ($@) {
            return http_response($env,400,pearlpbx_db()->errstr);
        }
    }
    return http_response($env,200,"OK");
}

sub queues_addqueue {
  my ($env, $name, $strategy, $timeout, $maxlen) = @_;

  my $sql = "insert into public.queues (name, strategy,timeout,maxlen ) values ( ?, ? ,? ,?);";
  my $sth  = pearlpbx_db()->prepare($sql);
  eval {
    $sth->execute ($name, $strategy, $timeout, $maxlen );
  };
  if ( $@ ) {
    return http_response($env,400, pearlpbx_db()->errstr);
  }
  return http_response($env, 200, "OK");
}

=item B<queues_addmember>

    Adds the member to the queue

=cut

sub queues_addmember {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $qname = $params->{'queue'};
    my $member = $params->{'newmember'};

    # Check for existing operator.
    my $sql = "select membername,interface from public.queue_members where queue_name=? and membername=?";
    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute($qname,$member);};
    if ( $@ ) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }
    my $row = $sth->fetchrow_hashref;
    if ($row->{'membername'}) {
      return http_response($env,200,"ALREADY");
    }

    $sql = "insert into public.queue_members (membername,queue_name,interface) values (?,?,?);";
    $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute($member,$qname,'SIP/'.$member);};
    if ( $@ ) {
        return http_response($env,400,pearlpbx_db()->errstr);
    }
    return http_response($env,200,"OK");

}

=item B<queues_removemember>

    Removes the member from the queue

=cut

sub queues_removemember {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $qname  = $params->{'queue'};
    my $member = $params->{'member'};

    my $sql = "delete from public.queue_members where queue_name=? and membername=?";
    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute($qname,$member); };
    if ( $@ ) { return http_response($env, 400, pearlpbx_db()->errstr); }
    return http_response($env,200,"OK");
}

=item B<queues_delqueue>

    Removes queue settings and members from the database

=cut

sub queues_delqueue {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $params = $req->parameters;
    my $name   = $params->{'queue'};

    my $sql = "delete from public.queues where name=?";
    my $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute ($name); };
    if ( $@ ) { return http_response($env, 400, pearlpbx_db()->errstr); }

    $sql = "delete from public.queue_members where queue_name=?";
    $sth = pearlpbx_db()->prepare($sql);
    eval { $sth->execute ($name); };
    if ( $@ ) { return http_response($env, 400, pearlpbx_db()->errstr); }
    return http_response($env,200,"OK");
}

1;

__END__

=back

=head1 EXAMPLES


=head1 BUGS

Unknown yet

=head1 SEE ALSO

None

=head1 TODO

None

=head1 AUTHOR

Alex Radetsky <rad@rad.kiev.ua>

=cut


