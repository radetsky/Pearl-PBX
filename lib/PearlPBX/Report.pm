#===============================================================================
#
#         FILE:  Report.pm
#
#  DESCRIPTION:  Base class for PearlPBX reports. 
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  01.06.2012 08:06:56 EEST
#===============================================================================
=head1 NAME

PearlPBX::Report

=head1 SYNOPSIS

	use base PearlPBX::Report;

=head1 DESCRIPTION

C<PearlPBX::Report> module contains superclass all other classes should be inherited from.

=cut

package PearlPBX::Report;

use 5.8.0;
use strict;
use warnings;

use DBI;
use Config::General; 
use NetSDS::Util::DateTime;  

use version; our $VERSION = "1.00";
our @EXPORT_OK = qw();

#===============================================================================
#
=head1 CLASS METHODS

=over

=item B<new($configfilename)> - class constructor

    my $object = PearlPBX::Report->new(%options);

=cut

#-----------------------------------------------------------------------
sub new {

	my $class = shift; 
	
  my $conf = shift;

  my $this = {}; 

  unless ( defined ( $conf ) ) {
     $conf = '/etc/PearlPBX/asterisk-router.conf';
  }

  my $config = Config::General->new (
    -ConfigFile        => $conf,
    -AllowMultiOptions => 'yes',
    -UseApacheInclude  => 'yes',
    -InterPolateVars   => 'yes',
    -ConfigPath        => [ $ENV{PEARL_CONF_DIR}, '/etc/PearlPBX' ],
    -IncludeRelative   => 'yes',
    -IncludeGlob       => 'yes',
    -UTF8              => 'yes',
  );

  unless ( ref $config ) {
    return undef;
  }

  my %cf_hash = $config->getall or ();
  $this->{conf} = \%cf_hash;
  $this->{dbh} = undef;     # DB handler 
  $this->{error} = undef;   # Error description string    

	bless ( $this,$class ); 
	return $this;

};

#***********************************************************************
=head1 OBJECT METHODS

=over

=item B<db_connect(...)> - соединяется с базой данных. 
Возвращает undef в случае неуспеха или true если ОК.
DBH хранит в this->{dbh};  

=cut

#-----------------------------------------------------------------------

sub db_connect {
	my $this = shift; 
  
    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'dsn'} ) ) {
        $this->{error} = "Can't find \"db main->dsn\" in configuration.";
        return undef;  
    }

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'login'} ) ) {
        $this->{error} = "Can't find \"db main->login\" in configuraion.";
        return undef;
    }

    unless ( defined( $this->{conf}->{'db'}->{'main'}->{'password'} ) ) {
        $this->{error} = "Can't find \"db main->password\" in configuraion.";
        return undef;
    }

    my $dsn    = $this->{conf}->{'db'}->{'main'}->{'dsn'};
    my $user   = $this->{conf}->{'db'}->{'main'}->{'login'};
    my $passwd = $this->{conf}->{'db'}->{'main'}->{'password'};

    # If DBMS isn' t accessible - try reconnect
    if ( !$this->{dbh} or !$this->{dbh}->ping ) {
        $this->{dbh} = 
            DBI->connect_cached( $dsn, $user, $passwd, { RaiseError => 1, AutoCommit => 0 } );
    }

    if ( !$this->{dbh} ) {
        $this->{error} = "Cant connect to DBMS!";
        return undef;
    }

    return 1;
};

=item B<filldatetime>

 Преобразовывает дату и время (даже если они не заданы) в параметр, который годится для работы с БД.
 Пример: 2012-12-21, 12:00 функция преобразует в "2012-12-21 12:00:00", 
 undef,23:12 функция преобразует в <сегодня> "23:12:00" , где <сегодня> будет текущей датой в формате ГГГГ-ММ-ДД.
 если же будет undef,undef , то функция вернет time() в формате YYYY-MM-DD HH:MM:SS

=cut

sub filldatetime {
	
 	my $this = shift;
 
  my $date = shift; 
  my $time = shift; 

  unless ( defined ( $date ) ) { 
    unless ( defined ( $time ) ) { 
      return date_now();
    }
  } 

  unless ( defined ( $date ) ) {
    $date = date_date(date_now());
  }

  unless ( defined ( $time ) ) {
    $time = date_time(date_now());
  }

  return $date . ' ' . $time;

}

=item B<fill_direction_sql_condition()> 

	Возвращает SQL условие для таблицы public.cdr 

=cut 
sub fill_direction_sql_condition { 
	my $this = shift; 
	my $direction = shift; 

	if ($direction == 1) { # Incoming 
	  return " channel not like 'SIP/2__-%' and channel not like 'Parked%' "; 	
  }
  if ($direction == 2) { # Outgoing 
		return " channel like 'SIP/2__-%' ";  
  } 
	# Anyway 
	return " channel not like 'Parked%' ";   
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


