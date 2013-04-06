#===============================================================================
#
#         FILE:  Audiofile.pm
#
#  DESCRIPTION:  Класс для загрузки голосовых файлов. 
#                Для получения списка и удаления смотрите в PearlPBX::Modules::Audiofiles.  
#        FIXME:  Потом надо будет объединить эти два класса, но сейчас я очень тороплюсь. 
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  01.06.2012 08:06:56 EEST
#===============================================================================
=head1 NAME

PearlPBX::Audiofile

=head1 SYNOPSIS

	use base PearlPBX::Audiofile;

=head1 DESCRIPTION

C<PearlPBX::Audiofile> Audiofile contains superclass all other classes should be inherited from.

=cut

package PearlPBX::Audiofile;

use 5.8.0;
use strict;
use warnings;

use DBI;
use Config::General; 

use version; our $VERSION = "1.00";
our @EXPORT_OK = qw();

#===============================================================================
#
=head1 CLASS METHODS

=over

=item B<new($configfilename)> - class constructor

    my $object = PearlPBX::Audiofile->new(%options);

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

sub add_or_replace {
  my ($this, $filename, $typeOfMusic, $description ) = @_; 

  my $sql = "insert into ivr.audiofiles (filename, typeOfMusic, description) values (?,?,?) returning id"; 
  my $sql2 = "update ivr.audiofiles set typeOfMusic=?,description=? where filename=?"; 
  my $sql3 = "select id from ivr.audiofiles where filename=?"; 

  my $sth = $this->{dbh}->prepare($sql);
  my $sth2 = $this->{dbh}->prepare($sql2); 
  my $sth3 = $this->{dbh}->prepare($sql3); 

  eval { 
    $sth->execute ( $filename, $typeOfMusic, $description); 
  }; 
  if ( $@ ) { 
#    print $this->{dbh}->errstr . "<br>"; 
    if ($this->{dbh}->errstr =~ /duplicate/i ) { 
      $this->{dbh}->rollback; 
      eval { 
       $sth2->execute ( $typeOfMusic, $description, $filename); 
      }; 
      if ( $@ ) { 
       return undef; 
      }
      $this->{dbh}->commit; 
      eval { 
       $sth3->execute ( $filename ); 
      };
      if ( $@ ) { 
        return undef; 
      }
      my $hashref = $sth3->fetchrow_hashref; 
      return $hashref->{'id'};
    }
    return undef;  
  } 
  my $hashref = $sth->fetchrow_hashref; 
  $this->{dbh}->commit; 
  return $hashref->{'id'}; 

}

sub convert { 
  my ($this, $filename,$file_id,$typeOfMusic) = @_; 

  my $infile = "files/".$filename; 
  my $outdir = "/usr/share/asterisk/sounds/ru/pearlpbx/"; 
  if ($typeOfMusic =~ /moh/i ) { 
    $outdir = "/usr/share/asterisk/moh/"; 
  }
  my $outfile = $outdir."/".$file_id.".ul"; 
  my $res = system("/usr/bin/sox",$infile,"-t","ul","-c","1","-r","8000",$outfile);

  return $res; 
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


