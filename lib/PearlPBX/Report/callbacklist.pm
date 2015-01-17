#===============================================================================
#
#         FILE:  callbacklist.pm
#
#  DESCRIPTION:
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  1.0
#      CREATED:  29.12.2014 
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

sub _sql_cond { 
    my ($this, $hide) = @_; 

    if ($hide =~ /true/) { 
	return " and not done "; 
    } else { 
	return " "; 
    }
} 

sub report {
    my ($this, $params) = @_; 

    my $sincedatetime =
      $this->filldatetime( $params->{'dateFrom'}, $params->{'timeFrom'} );
    my $tilldatetime =
      $this->filldatetime( $params->{'dateTo'}, $params->{'timeTo'} );
    my $done = $params->{'done'}; 
    my $sql_cond = $this->_sql_cond ( $done );

    my $sql = "select created,callerid,operator,calledidnum, calledidname, done from callback_list where created between ? and ? $sql_cond order by created desc"; 

    my $sth = $this->{dbh}->prepare($sql);
    eval { $sth->execute( $sincedatetime, $tilldatetime ); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }

    my $hash_ref = $sth->fetchall_hashref('created');
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


