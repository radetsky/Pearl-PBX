#===============================================================================
#
#         FILE:  WBList.pm
#
#  DESCRIPTION:  Класс для управления черным и белым списками  
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  PearlPBX
#      VERSION:  1.0
#      CREATED:  02.04.2013 
#===============================================================================

package PearlPBX::Module::callbacklist; 

use 5.8.0;
use strict;
use warnings;

use base qw(PearlPBX::Module);
use Data::Dumper; 
use JSON; 
use NetSDS::Util::String;

use version; our $VERSION = "0.01";
our @EXPORT_OK = qw();

sub new {
    my ( $class, $conf ) = @_;
    my $this = $class->SUPER::new($conf);
    bless $this;
    return $this;
}

sub _tableName {
    return 'callback_list'; 
} 

sub getJSON {
	my ( $this, $params ) = @_;
	 
	my $tableName = 'callback_list';  
	my $sql = "select * from ".$tableName." where inprogress='f' and created > now()-'1 hour'::interval order by created desc"; 
	
	my $sth = $this->{dbh}->prepare($sql); 

	eval { $sth->execute; }; 
    if ( $@ ) {
        print $this->{dbh}->errstr;
        return undef;
    }

    my @wblist; 

    while (my $hashref = $sth->fetchrow_hashref ) {
  		$hashref->{'number'} = str_encode($hashref->{'number'});
   		$hashref->{'reason'} = str_encode($hashref->{'reason'});
    	push @wblist,$hashref; 
    }
    
    my $jdata  = encode_json(\@wblist); 

    print $jdata; 

    return 1; 

}

sub add { 
	my ($this, $params) = @_; 
	
	my $tableName = $this->_tableName($params->{'wb'}); 
	return undef unless ( defined ( $tableName ) ); 

	my $sql = "insert into ".$tableName." (number,reason) values ( ?, ?) "; 
	my $sth = $this->{dbh}->prepare($sql); 

	my $msisdn = str_trim($params->{'msisdn'}); 
	my $reason = str_trim($params->{'reason'}); 

	eval { $sth->execute ($msisdn,$reason); }; 
	if ( $@ ) { 
		print $this->{dbh}->errstr; 
		return;
	}

	$this->{dbh}->commit; 
	print "OK"; 
	return;

}

sub del { 
	my ($this, $params) = @_; 
	
	my $tableName = $this->_tableName($params->{'wb'}); 
	return undef unless ( defined ( $tableName ) ); 

	my $sql = "delete from ".$tableName." where id=?";
	my $sth = $this->{dbh}->prepare($sql); 

	eval { $sth->execute($params->{'id'}); };
	if ( $@ ) { 
		print $this->{dbh}->errstr; 
		return;
	}
	
	$this->{dbh}->commit; 
	print "OK"; 
	return;

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


