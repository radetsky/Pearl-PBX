#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  alltraffic_test.pl
#
#        USAGE:  ./alltraffic_test.pl 
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  01.06.2012 16:58:31 EEST
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

use PearlPBX::Report::alltraffic; 
use Data::Dumper; 

my $report = PearlPBX::Report::alltraffic->new('/etc/PearlPBX/asterisk-router.conf'); 
$report->db_connect();
warn Dumper $report->report('2012-03-19','00:00','2012-03-30','00:00', 1); 
1;
#===============================================================================

__END__

=head1 NAME

alltraffic_test.pl

=head1 SYNOPSIS

alltraffic_test.pl

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

