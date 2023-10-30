#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-callback-add.pl
#        USAGE:  ./PearlPBX-callback-add.pl
#  DESCRIPTION:  AGI adds application to callback from Call Center.  
#      OPTIONS:  ${CALLERID}, ServiceName 
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  2.0
#      CREATED:  29.12.2014
#     MODIFIED:  08.10.2018 
#===============================================================================

use 5.8.0;
use strict;
use warnings;

$| = 1;

Cb->run(
    conf_file   => '/etc/PearlPBX/asterisk-router.conf',
    has_conf    => 1,
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;

package Cb;

use base 'PearlPBX::IVR';
use Data::Dumper;
use NetSDS::Util::String;  


sub exist_in_addressbook {
    my $this = shift; 
    my $callerid = shift; 

    my $sth = $this->dbh->prepare("select count(msisdn) as c from ivr.addressbook where msisdn=?"); 
    eval { 
        $sth->execute($callerid);
    };
    if ( $@ ) { 
        return undef; 
    }

    my $result = $sth->fetchrow_hashref();
    if ( ! defined ( $result->{'c'} ) ) {
        return undef; 
    }
    if ( $result->{'c'} > 0 ) {
        return 1;
    }
    return undef; 
}

sub _hangup_check {
    my ($this, $callerid, $service) = @_; 

    $this->agi->verbose ("Hangup checking for $callerid", 3); 
    my $sql = "select * from callback_list where callerid=? and servicename=?"; 
    my $sth = $this->dbh->prepare($sql);
    eval { $sth->execute($callerid, $service); }; 
    if ( $@ ) {
        $this->agi->verbose($this->dbh->errstr);
        exit(-1);
    }
    if ( my $data = $sth->fetchrow_hashref ) {
        # Если там что-то есть, то оператор рано кинул трубку.
        $this->agi->verbose("Hangup too early? $callerid", 3);  
        $this->_increase_priority($callerid, $service);  
        return 
    } 
    #Если там ничего нет, то все ОК. 
    $this->agi->verbose("Hangup OK. Callback successful $callerid"); 
}

sub _remove_callerid {
    my ($this, $callerid, $service) = @_; 

    $this->agi->verbose("Removing $callerid from $service callback", 3); 
    my $sql2 = "delete from callback_list where callerid=? and servicename=?"; 
    my $sth2 = $this->dbh->prepare($sql2); 
    eval {
        $sth2->execute($callerid, $service); 
    }; 
    if ($@) {
        $this->agi->verbose($this->dbh->errstr, 3); 
        exit(-1);
    }
}

sub _increase_priority {
    my ($this, $callerid, $service) = @_; 

    $this->agi->verbose("Increasing priority for ".$callerid , 3); 
    my $sql2 = "update callback_list set priority=priority+1,inprogress='f',updated=now() where callerid=? and servicename=?"; 
    my $sth2 = $this->dbh->prepare($sql2);
    eval { 
         $sth2->execute($callerid, $service); 
    };
    if ($@) {
         $this->agi->verbose( $this->dbh->errstr, 3 ); 
         exit(-1);
    }
}

sub _decrease_priority {
    my ($this, $callerid, $service) = @_; 

    $this->agi->verbose("Decreasing priority for ".$callerid, 3 ); 
    my $sql2 = "update callback_list set priority=priority-1,inprogress='f',updated=now() where callerid=? and servicename=?"; 
    my $sth2 = $this->dbh->prepare($sql2);
    eval { 
         $sth2->execute($callerid, $service); 
    };
    if ($@) {
         $this->agi->verbose( $this->dbh->errstr, 3 ); 
         exit(-1);
    }
}

sub _read {
    my ($this, $callerid, $service ) = @_; 

    $this->agi->verbose("Getting priority for $callerid", 3 ); 
    my $sql1 = "select * from callback_list where callerid=? and servicename=?"; 
    my $sth1 = $this->dbh->prepare($sql1); 
    eval { 
        $sth1->execute($callerid, $service); 
    }; 
    my $res = $sth1->fetchrow_hashref;
    return $res;  
}

sub _read_single {
    my ($this, $callerid ) = @_; 

    my $sql1 = "select * from callback_list where callerid=?"; 
    my $sth1 = $this->dbh->prepare($sql1); 
    eval { 
        $sth1->execute($callerid); 
    }; 
    my $res = $sth1->fetchrow_hashref;
    return $res;  
}

sub _set_priority {
    my ($this, $callerid, $service, $priority) = @_; 

    $this->agi->verbose("Setting priority to $priority for ".$callerid, 3 ); 
    my $sql2 = "update callback_list set priority=?,inprogress='f',updated=now() where callerid=? and servicename=?"; 
    my $sth2 = $this->dbh->prepare($sql2);
    eval { 
         $sth2->execute($priority, $callerid, $service); 
    };
    if ($@) {
         $this->agi->verbose( $this->dbh->errstr, 3 ); 
         exit(-1);
    }
}

sub process {
    my $this = shift;

    my $callerid = $ARGV[0]; 
    my $service  = $ARGV[1];
    my $optional = $ARGV[2];  

    # При нахождении в адресной книге - не добавляем 
    if ( $this->exist_in_addressbook($callerid) ) { 
        $this->agi->verbose($callerid . " exists in address book", 3); 
        exit(0);
    } 

    if ( defined ( $optional ) && $optional eq 'REMOVE' ) {
        $this->_remove_callerid($callerid, $service);
        exit(0);
    }

    if (defined ( $optional ) && $optional eq 'HANGUP' ) {
       $this->_hangup_check($callerid, $service);
       exit(0);
    }  

    if ( defined ( $optional ) && $optional eq '0' ) {
        my $res = $this->_read($callerid, $service); 
        if ( defined($res) && ($res->{'priority'} <= -2 )) {
            $this->_remove_callerid($callerid, $service); 
        } elsif ( defined ($res) && ($res->{'priority'} <= 0)) {
            $this->_decrease_priority($callerid, $service); 
        } else { 
            $this->_set_priority($callerid, $service, $optional);
        }
        exit(0);
    }
     
    # patch for single entry for every cvallerid 
    my $r = $this->_read_single($callerid); 
    if ( defined ( $r ) ) {
       $this->agi->verbose($callerid . " exists in other service", 3);
       exit(0);
    }

    my $sql = "insert into callback_list ( callerid, servicename) values ( ?,? )"; 
    my $sth = $this->dbh->prepare($sql);

    eval { 
        $sth->execute ($callerid, $service ); 
    };

    if ($@) { 
        # При ошибке добавления - смотрим на $optional  
        if ( defined ( $optional ) ) {
            $this->_set_priority($callerid, $service, $optional); 
            exit(0);
        }
    }

    $this->agi->verbose("inserted to callback list: $callerid", 3);  
    exit(0);
}

1;

#===============================================================================

__END__

=head1 NAME

PearlPBX-callback-add.pl

=head1 SYNOPSIS

PearlPBX-callback-add.pl

=head1 DESCRIPTION

FIXME

=head1 EXAMPLES

FIXME

=head1 BUGS

Unknown.

=head1 TODO

Empty.

=head1 AUTHOR

Alex Radetsky <rad@rad.kiev.ua>

=cut

