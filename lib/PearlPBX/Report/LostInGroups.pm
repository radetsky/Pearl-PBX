#===============================================================================
#
#         FILE:  LostInGroups.pm
#
#  DESCRIPTION:  Returns count of lost calls. 
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  1.0
#      CREATED:  01.06.2012 05:30:27 EEST
#     MODIFIED:  27.04.2015 (Remember Olga) 
#===============================================================================

package PearlPBX::Report::LostInGroups;

use 5.8.0;
use strict;
use warnings;

use base qw(PearlPBX::Report);
use Data::Dumper;
use Template;
use JSON; 

use version; our $VERSION = "1.0";
our @EXPORT_OK = ();

#===============================================================================
#

=head1 CLASS METHODS

=over

=item B<new([...])> - class constructor

    my $object = NetSDS::SomeClass->new(%options);

=cut

#-----------------------------------------------------------------------
sub new {
    my ( $class, $conf ) = @_;
    my $this = $class->SUPER::new($conf);
    bless $this;
    return $this;
}

#***********************************************************************

=head1 OBJECT METHODS

=over

=item B<user(...)> - object method

=cut

#-----------------------------------------------------------------------
sub report {

    my $this = shift;

		my $params = shift;

    my $sincedatetime = $this->filldatetime( $params->{'dateFrom'}, $params->{'timeFrom'} );
    my $tilldatetime  = $this->filldatetime( $params->{'dateTo'},  $params->{'timeTo'} );

    my $sql = "select count(queue) as s,queue as queuename from public.queue_parsed 
      where time between ? and ? and success=0 group by queue order by count(queue) desc"; 

    my $sth = $this->{dbh}->prepare($sql);
    eval { $sth->execute( $sincedatetime, $tilldatetime ); };
    if ($@) {
        $this->{error} = $this->{dbh}->errstr;
        return undef;
    }
	
		my @aOfa; 
		my @cdr_keys; 

    while ( my $hash_ref = $sth->fetchrow_hashref ) {
			push @aOfa, [ $hash_ref->{'queuename'},$hash_ref->{'s'}+0 ]; 
			push @cdr_keys, $hash_ref;  
    }

    foreach my $pos ( @cdr_keys ) { 
      my $qname = $pos->{'queuename'}; 
      my ( $lucky, $done ) = $this->_get_lucky_done ($qname, $sincedatetime, $tilldatetime);
      $pos->{'lucky'} = $lucky; 
      $pos->{'done'}  = $done; 
      $pos->{'left'}  = $pos->{'s'} - $lucky - $done;  
    }

		my $template = Template->new( { 
			INCLUDE_PATH => '/usr/share/pearlpbx/reports/templates',
			INTERPOLATE  => 1, 
			} ) || die "$Template::ERROR\n"; 

		my $jdata = encode_json (\@aOfa);

		my $template_vars = { 
			cdr_keys => \@cdr_keys,
			jdata => $jdata, 
      sincedatetime => $sincedatetime,
      tilldatetime => $tilldatetime,
		};  
		$template->process('LostInGroups.html', $template_vars) || die $template->error(); 
		
}

sub hashref2arrayOfArrays {
	my ($this,$hash_ref) = @_;
  my @result; 

  foreach my $hrkey ( keys %$hash_ref ) { 
	  my $sub_hashref = $hash_ref->{$hrkey}; 
		my @sub_array; 
    foreach my $hrsubkey ( keys %$sub_hashref ) { 
			push @sub_array, $sub_hashref->{'dst'}; 
			push @sub_array, $sub_hashref->{'s'}+0; 
		} 
		push @result, [ @sub_array ]; 
  }
	return @result; 
}

sub hashref2arrayofhashref {
  my $this = shift;
  my $hash_ref = shift;
  my @output;

  foreach my $cdr_key (keys %$hash_ref ) {
    my $record = $hash_ref->{$cdr_key};
    push @output, $record;
  }
  return @output;
}

sub _get_lucky_done { 
  my ($this, $queuename, $sincedatetime, $tilldatetime) = @_; 

  # Подробный список пропущенных
  my $sql = "select time,callerid,holdtime from queue_parsed where queue=? 
      and success=0 and time between ? and ? order by time desc"; 

  # Список дозвонившихся после пропущенного
  my $sql_redial = "select time,holdtime from queue_parsed where queue=? 
      and callerid=? and success=1 and time between ? and ? order by time desc limit 1"; 

  # Список обработанных операторами 
  my $sql_operator_redial = "select calldate, billsec, src from public.cdr where dst=? 
      and calldate between ? and ? and disposition = 'ANSWERED' order by calldate limit 1"; 

  my $sth = $this->{dbh}->prepare($sql);
  eval { $sth->execute( $queuename, $sincedatetime, $tilldatetime ); };
  if ($@) {
      $this->{error} = $this->{dbh}->errstr;
      return undef;
  }

  my @first_rows; 
  while ( my $hash_ref = $sth->fetchrow_hashref ) {
      push @first_rows,$hash_ref; 
  }

  my $sth_redial  = $this->{dbh}->prepare ($sql_redial); 
  my $sth_outtime = $this->{dbh}->prepare ($sql_operator_redial); 

  my $lucky = 0;
  my $done  = 0; 
  foreach my $row (@first_rows) { 
    my $callerid = $row->{'callerid'};
    my $first_time = $row->{'time'}; 
    unless ( defined ( $this->_lucky($callerid, $first_time, $sth_redial, $queuename, $tilldatetime) ) ) { 
      unless ( defined ( $this->_outtime($callerid, $first_time, $sth_outtime, $tilldatetime) ) ) { 
        next;
      } else {
        $done++; 
      }

    } else {
      $lucky++; 
    }
  }
  return ($lucky, $done); 
}

sub _outtime { 
    my ($this, $callerid, $first_time, $sth, $tilldatetime) = @_; 
    eval { $sth->execute ($callerid, $first_time, $tilldatetime); }; 
    if ($@) { 
        $this->{error} = $this->{dbh}->errstr;
        return undef; 
    }
    my $outtime = $sth->fetchrow_hashref;
    unless ( defined ( $outtime->{'calldate'}) ) { return undef; } 
    return 1;  
}

sub _lucky { 
    my ($this, $callerid, $first_time, $sth_redial, $queuename, $tilldatetime) = @_; 

    eval { $sth_redial->execute ($queuename, $callerid, $first_time, $tilldatetime); }; 
    if ($@) { 
        $this->{error} = $this->{dbh}->errstr;
        return undef; 
    }
    my $lucky = $sth_redial->fetchrow_hashref;
    unless ( defined ( $lucky->{'time'}) ) { return undef; }
    return 1;  
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


