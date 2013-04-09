#===============================================================================
#
#         FILE:  Hints.pm
#
#  DESCRIPTION:  Класс для управления дополнительными подсказками  
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  08.04.2013 
#===============================================================================
=head1 NAME

NetSDS::

=head1 SYNOPSIS

	use NetSDS::;

=head1 DESCRIPTION

C<NetSDS> module contains superclass all other classes should be inherited from.

=cut

package PearlPBX::Module::Hints; 

use 5.8.0;
use strict;
use warnings;

use base qw(PearlPBX::Module);
use Data::Dumper; 
use JSON; 
use NetSDS::Util::String;


use version; our $VERSION = "0.01";
our @EXPORT_OK = qw();


#===============================================================================
#
=head1 CLASS METHODS

=over

=item B<new([...])> - class constructor

    my $object = NetSDS::SomeClass->new(%options);

=cut

sub new {
    my ( $class, $conf ) = @_;
    my $this = $class->SUPER::new($conf);
    bless $this;
    return $this;
}

sub getlist { 
    my ($this, $params) = @_; 

    my $sql = "select msisdn from ivr.hints where hint_id=? order by msisdn"; 
    my $sth = $this->{dbh}->prepare ($sql); 

    eval { $sth->execute ($params->{'hint_id'});}; 
    if ( $@ ) { 
        print $this->{dbh}->errstr; 
        return; 
    }
    while ( my $hashref = $sth->fetchrow_hashref ) { 
        print $hashref->{'msisdn'}."<br/>"; 
    }
    return; 
}

sub getGroupJSON {
	my ($this,$params) = @_; 

	my $sql = "select count(msisdn) as msisdn_count,since,till,message,hint_id from ivr.hints group by since,till,message,hint_id order by hint_id desc"; 
	my $sth = $this->{dbh}->prepare($sql); 

	eval { $sth->execute(); }; 
    if ( $@ ) {
        print $this->{dbh}->errstr;
        return undef;
    }

    my @hints; 

    while (my $hashref = $sth->fetchrow_hashref ) {
    	$hashref->{'message'} = str_encode($hashref->{'message'} );
    	push @hints,$hashref; 
    }
    
    my $jdata  = encode_json(\@hints); 
    print $jdata; 
    return 1; 

}

sub del { 
	my ($this, $params) = @_; 

	my $sql = "delete from ivr.hints where hint_id=?";
	my $sth = $this->{dbh}->prepare($sql); 

	eval { $sth->execute($params->{'hint_id'}); };
	if ( $@ ) { 
		print $this->{dbh}->errstr; 
		return;
	}
	
	$this->{dbh}->commit; 
	print "OK"; 
	return;
}

sub add { 
    my ($this, $params) = @_; 

    my $hint = $params->{'hintupload'}; 
    my $filename = $params->{'fileupload_name_hidden'}; 
    my $since = $params->{'sincehint'}; 
    my $till = $params->{'tillhint'}; 

    my $fullpath = "files/".$filename; 
    my $hint_id_sql = "select nextval('ivr.hints_hint_id_seq'::regclass) as hint_id"; 
    my $sql = "insert into ivr.hints ( msisdn, since, till, message, hint_id ) values ( ?, ?, ?, ?, ?);"; 

    my $hint_id_sth = $this->{dbh}->prepare($hint_id_sql); 
    my $sth = $this->{dbh}->prepare($sql); 

    eval { $hint_id_sth->execute; }; 
    if ( $@ ) { 
        return undef; 
    }
    my $hashref = $hint_id_sth->fetchrow_hashref; 
    my $hint_id = $hashref->{'hint_id'}; 
    unless ( defined ( $hint_id ) ) { 
        return undef; 
    }

    open (my $csv, $fullpath) or return undef; 
    while ( my $line = <$csv> ) { 
        chomp $line; 
        my $tline = str_trim($line); 
        if ($tline eq '') { next; }
        eval { $sth->execute ($tline, $since, $till, $hint, $hint_id); }; 
        if ( $@ ) { return undef; }
    }
    $this->{dbh}->commit; 

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


