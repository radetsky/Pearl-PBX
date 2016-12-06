#!/usr/bin/env perl
#===============================================================================
#
#         FILE:  PearlPBX-makecallfile.pl
#
#        USAGE:  ./PearlPBX-makecallfile.pl Destination Localnumber DisplayFrom MaxCount RetryTime
#
#  DESCRIPTION:  Make call file that gives asterisk a chance to dial to destination, callback to localnumber
#  @context default with display @DisplayFrom to as callerid name
#
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  1.0
#===============================================================================

# subst - надо ли подставлять поле from ?
# В случае подстановки юзеру будет куда отвечать в рассылку
# Пример: "From: 700, Body: "799: Bulk SMS message".
# В обратном случае ответ будет направлен только одному человеку
# Если подставлять reply to не надо, но фром поменять надо, то пример такой:
# script.pl,"811,809,810",false,"INFO"

use strict;
use warnings;

$| = 1;

BulkSMS->run(
    conf_file   => '/etc/PearlPBX/asterisk-router.conf',
    has_conf    => 1,
    daemon      => undef,
    use_pidfile => undef,
    verbose     => undef,
    debug       => 1,
    infinite    => undef
);

1;

package BulkSMS;

use parent qw/PearlPBX::IVR/;
use Date::Format qw/time2str/;
use Data::Dumper;

use constant {
     RETRY_MAX_COUNT => 1008,
     RETRY_TIME => 600,
}; # 1 Week

sub process {
    my $this = shift;

    unless ( defined( $ARGV[0] ) ) {
        $this->agi->verbose(
            "Usage: <INTERNAL> || <List,Of,Users>, [<subst>] ", 3 );
        exit(-1);
    }
    $this->{to}   = $this->agi->get_variable('MESSAGE(to)');
    $this->{origfrom} = $this->{from} = $this->agi->get_variable('MESSAGE(from)');

    $this->{body} = $this->agi->get_variable('MESSAGE(body)');
    $this->{exten} = $this->agi->get_variable('EXTEN');

	#From: $VAR1 = '"Alex Radetsky" <sip:888@93.158.209.11>';#012, To: $VAR1 = 'sip:888@93.158.209.11';#012, exten: $VAR1 = '888';#012, body: $VAR1 = 'Тест 8';

    my $debug = sprintf("From: %s, To: %s, exten: %s, body: %s",
	Dumper ($this->{from}),
        Dumper ( $this->{to}),
        Dumper ($this->{exten}),
        Dumper ( $this->{body}) );

   $this->log("info",$debug);

    my @names = $this->_list();
    if (@names == 1) {
	$this->{notify} = 1;
    } else {
	$this->{notify} = 0;
    }

    $this->{fromname} = $ARGV[2] // "List";
    if ( $ARGV[2] ) {
        my ($display,$uri) = split("<",$this->{from});
        $this->{from} = "\"".$ARGV[2]."\"<$uri";

    }

    foreach my $name (@names) {
        $this->send_message($name);
    }
    $this->agi->exec("Hangup","16");
}

# Application call MessageSend("sip: ExtenTo", "sip: 'MyName'<exten>");

sub send_message {
    my ( $this, $dest ) = @_;

    my $from = $this->{from};
    my $body = $this->{body};
    if ( $ARGV[1] eq 'subst' ) {
	my $qfrom = $this->{origfrom};
	$qfrom =~ s/"/\\"/g;
        $body = $qfrom . ': ' . $body;
	my $qto = $this->{to};
	$qto =~ s/@/\\@/g;
        $from = "\"".$this->{fromname}."\" <".$qto.">";
        $this->agi->set_variable('MESSAGE(body)', $body); # subst: "$from: $body".
    }

    my $params = sprintf("sip:%s,%s",
        $dest, $from);
    $params =~ s/"/\\"/g;
    $this->log("info",$params);

    $this->agi->exec("Set","MESSAGE(from)=$from");
    $this->agi->exec("MessageSend", "$params");

    my $status = $this->agi->get_variable('MESSAGE_SEND_STATUS');
    if ( $status ne 'SUCCESS' ) {
        $this->send_failed_message ( $dest );
        return 1;
    }
    my $notify = $this->agi->get_variable('NOTIFY');
    if ( $notify ) {
        $this->send_success_notification($this->{from}, $dest);
    }
    return 1;

}

sub send_success_notification {
    my $this = shift;
    my $fulldest = shift;
    my $failed_dest = shift;

    $this->agi->verbose("Sending notification to $fulldest", 3);
    my ($display,$uri) = split("<",$this->{from});
    my ($to,$ipaddr) = split("\@",$uri);
    my $from = "\"$failed_dest\"<sip:$failed_dest\@$ipaddr";
    my $body = "The subscriber $failed_dest received your message";
    $this->agi->set_variable('MESSAGE(body)', $body); # Notify about offline
    $this->agi->exec("MessageSend", "$to,$from");

    return 1;
}

sub send_failed_message {
    my $this = shift;
    my $failed_dest = shift;

    if ( $this->{notify} ) {
       # Это личное или специальное сообщение. Уведомляем юзера про offline
       my $time = time2str("%Y-%m-%d %H:%M", time());
       my $body = "$time ServiceCenter: The subscriber $failed_dest temporarily unavailable. Will receive a message when subscriber registers in the network.";
       my ($display,$uri) = split("<",$this->{from});
       my ($to,$ipaddr) = split("\@",$uri);
       my $from = "\"$failed_dest\"<sip:$failed_dest\@$ipaddr";
       $this->agi->set_variable('MESSAGE(body)', $body); # Notify about offline
       $this->agi->exec("MessageSend", "$to,$from");
    }
    my $notify = $this->agi->get_variable('NOTIFY');
    unless ( $notify ) {
       $this->agi->verbose("Putting failed message to the queue...", 3);
       my $time = time2str("%Y-%m-%d %H:%M", time());
       my $body = "$time " . $this->{body};
       $this->ast_queue($failed_dest, $body, $this->{from});
    }

    return 1;
}

sub ast_queue {
    my $this = shift;
    my $dest = shift;
    my $body = shift;
    my $from = shift;

    $this->agi->verbose("Putting failed message to the queue...", 3);

    my $random = int(rand(1000)+1);
    my $time = time();
    my $filename = $dest."_".$time."_".$random.".call";

    my $notify = $this->{notify};

    my $fh;

    eval {
	open ($fh, ">", "/var/spool/asterisk/temp/$filename") or die "Can't open $filename: $!";
    };
    if ($@) {
	$this->agi->verbose($@, 3);
	$this->agi->exec("Hangup","17");
        return 1;
    }
    print $fh "Channel: Local/$dest\@app-fakeanswer
CallerID: $from
Maxretries: " . RETRY_MAX_COUNT . "
RetryTime: " . RETRY_TIME . "
Context: messages
Extension: $dest
Priority: 1
Set: MESSAGE(body)=$body
Set: MESSAGE(to)=$dest
Set: MESSAGE(from)=$from
Set: NOTIFY=$notify
";
    close $fh;
    system("/usr/bin/chown asterisk:asterisk /var/spool/asterisk/temp/$filename");
    system("/usr/bin/chmod 777 /var/spool/asterisk/temp/$filename");
    sleep(3);
    system("/usr/bin/mv /var/spool/asterisk/temp/$filename /var/spool/asterisk/outgoing/");
    return 1;
}

sub _list {
    my $this = shift;

    my @list;
    if ( $ARGV[0] eq 'INTERNAL' ) {
        my $result = $this->_list_internal();
        foreach my $row ( @{$result} ) {
            push @list, $row->[0];
        }
    }
    else {
        @list = split( ',', $ARGV[0] );
    }
    return @list;
}

sub _list_internal {
    my $this = shift;

    my $sql
        = "select a.name as name from public.sip_peers a, integration.workplaces b where a.ipaddr  is not null and a.ipaddr != '' and b.sip_id = a.id order by a.name";
    my $result = $this->dbh->selectall_arrayref($sql);

}

1;

#===============================================================================

__END__

=head1 NAME

PearlPBX-bulksms.pl

=head1 SYNOPSIS

PearlPBX-bulksms.pl

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

