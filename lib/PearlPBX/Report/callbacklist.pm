#===============================================================================
#         FILE:  callbacklist.pm
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  2.0
#      CREATED:  29.12.2014
#     MODIFIED:  25.12.2023 # Merry Christmas :)
#===============================================================================

package PearlPBX::Report::callbacklist;

use 5.8.0;
use strict;
use warnings;

use base qw(PearlPBX::Report);
use Data::Dumper;
use Template;

use version; our $VERSION = "1.0";
our @EXPORT_OK = ();

sub new {
    my ( $class, $conf ) = @_;
    my $this = $class->SUPER::new($conf);
    bless $this;
    return $this;
}

sub pearlpbx_player {
	my $this = shift;
	my $cdr_start = shift;
	my $cdr_src = shift;
	my $cdr_dst = shift;
    my $uniqueid = shift;

	return '<a data-toggle="modal" href="#pearlpbx_player" onClick="turnOnPBXPlayer(\''.$cdr_start.'\',\''.$cdr_src.'\',\''.$cdr_dst.'\',\''.$uniqueid.'\')">link</a>';
}

sub report {
    my ($this, $params) = @_;

    my $sincedatetime =
      $this->filldatetime( $params->{'dateFrom'}, $params->{'timeFrom'} );
    my $tilldatetime =
      $this->filldatetime( $params->{'dateTo'}, $params->{'timeTo'} );

    my $sql = "select cdr_start, cdr_src, cdr_dst, cdr_uniqueid from integration.recordings where cdr_src=cdr_dst and cdr_start between ? and ? order by cdr_start";
    my $sth = $this->{dbh}->prepare($sql);
    eval { $sth->execute( $sincedatetime, $tilldatetime ); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }

    my $hash_ref = $sth->fetchall_hashref('cdr_start');
    unless ($hash_ref) {
        return 0;
    }

    my $template = Template->new(
        {
            INCLUDE_PATH => '/usr/share/pearlpbx/reports/templates',
            INTERPOLATE  => 1,
        }
    ) || die "$Template::ERROR\n";

    my @cdr_keys      = $this->hashref2arrayofhashref($hash_ref);

    my $template_vars = {
        cdr_keys        => \@cdr_keys,
        pearlpbx_player => sub { return $this->pearlpbx_player(@_); },
    };

    warn Dumper $hash_ref, \@cdr_keys;

    $template->process( 'callbacklist.html', $template_vars )
      || die $template->error();

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


