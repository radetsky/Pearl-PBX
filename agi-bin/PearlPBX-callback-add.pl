#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  PearlPBX-callback-add.pl
#
#        USAGE:  ./PearlPBX-callback-add.pl
#
#  DESCRIPTION:  AGI adds application to callback from Call Center.  
#
#      OPTIONS:  ${CALLERID}, ${EXTEN}, ${CHANNEL} 
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  1.0
#      CREATED:  29.12.2014
#     REVISION:  001
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

sub _cutoff_channel {
    my $this    = shift;
    my $channel = shift;
    my ( $proto, $a ) = split( '/', $channel );
    my ( $peername, $channel_number ) = split( '-', $a );

    return $peername; 
}



sub _channel_desc { 
    my ($this,$channel) = @_; 

    my $peername = $this->_cutoff_channel ($channel); 
    my $sql = "select comment from public.sip_peers where name=?"; 
    my $sth = $this->dbh->prepare($sql); 
    eval { $sth->execute ($peername); }; 
    if ( $@ ) { $this->agi->verbose( $this->dbh->errstr ); exit(-1); }
    my $hashref = $sth->fetchrow_hashref(); 
    return $hashref->{'comment'};     

}

sub process {
    my $this = shift;

    my $callerid = $ARGV[0]; 
    my $exten = $ARGV[1]; 
    my $channel = $ARGV[2]; 

    my $channeldesc = $this->_channel_desc ($channel); 

    my $sql = "insert into callback_list ( callerid, calledidnum, calledidname) values ( ?,?,?)"; 
    my $sth = $this->dbh->prepare($sql);
    eval { $sth->execute ($callerid, $exten, $channeldesc); };
    if ($@) { $this->agi->verbose( $this->dbh->errstr ); exit(-1); } 
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

