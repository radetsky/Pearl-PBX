package PearlPBX::Config;

use warnings;
use strict;

use Carp;
use Config::General;
use Data::Dumper;
use parent qw(Exporter);

our @EXPORT_OK = qw(conf);

our $CONFIG;
use constant CONFIG_DIR  => '/etc/PearlPBX';
use constant CONFIG_FILE => 'asterisk-router.conf';

sub import {
	my ($class, $opt ) = @_;

	if ( $opt && $opt eq '-load') {
		confess "Config is already loaded" if $CONFIG;
		read_config();
	} else {
        __PACKAGE__->export_to_level(1,@_);
    }
}

sub read_config {

    my $config = Config::General->new (
      -ConfigFile        => CONFIG_FILE,
      -AllowMultiOptions => 'yes',
      -UseApacheInclude  => 'yes',
      -InterPolateVars   => 'yes',
      -ConfigPath        => [ $ENV{CONFIG_DIR} // '/', CONFIG_DIR ],
      -IncludeRelative   => 'yes',
      -IncludeGlob       => 'yes',
      -UTF8              => 'yes',
    );

    unless ( ref $config ) {
      die "Can't read config\n";
    }

    my %cf_hash = $config->getall or ();
    $CONFIG = \%cf_hash;

}

sub conf {
	confess "Load config before using it" unless $CONFIG;
	return $CONFIG;
}

1;

