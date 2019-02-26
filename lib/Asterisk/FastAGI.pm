package Asterisk::FastAGI;

use 5.006;
use strict;
use warnings;

$Asterisk::FastAGI::VERSION = '0.02';

use Asterisk::AGI;
use Net::Server::PreFork;

our @ISA = qw(Net::Server::PreFork);

=head1 NAME

Asterisk::FastAGI - Module for FastAGI handling.

=head1 SYNOPSIS

  use base 'Asterisk::FastAGI';

  sub fastagi_handler {
    my $self = shift;

    my $param = $self->param('foo');
    my $callerid = $self->input('calleridname');

    $self->agi->say_number(1000);
  }

=head1 DESCRIPTION

Asterisk::FastAGI provides a preforking daemon for handling FastAGI
requests from Asterisk.

Read the L<Net::Server> for more information about the logging
facilities, configuration, etc.

=head1 USAGE EXAMPLE

First you need a module containing all of your AGI handlers.

  package MyAGI;

  use base 'Asterisk::FastAGI';
  
  sub agi_handler {
    my $self = shift;
    $self->agi->say_number(8675309);
  }

Then you simply need to have a script that runs the daemon.

  #!/usr/bin/perl
  use MyAGI;

  MyAGI->run();

When it is run it creates a preforking daemon on port '4573'.  That is
the default port for FastAGI.  Read the L<Net::Server> documentation
on how to change this and many other options.

=head1 METHODS

=head2 param

Returns parsed parameters sent in from the AGI script.

Inside extensions.conf:
	
  exten => 1111,1,Agi(agi://${SERVER}/fastagi_handler?foo=bar&blam=blah

You can access those parameters from inside your AGI script.  Much
like you would if those were URL parameters on a CGI script.

  my $foo = $self->param('foo');

=cut

sub param {
  my($self, $param) = @_;
  return $param ? $self->{server}{params}{$param} : $self->{server}{params};
}

=head2 input

Returns a hash containing the input from the AGI script.

  my %hash = $self->input()
	
If given a key.  It will return that particular value.

  my $uniqueid = $self->input('uniqueid');

=cut

sub input {
  my($self, $param) = @_;

  if( not defined $self->{server}{input} ) {
    $self->parse_request();
  }

  return $param ? $self->{server}{input}{$param} : $self->{server}{input};
}

=head2 agi

Will return the Asterisk::AGI object.

=cut

sub agi {
  my($self, $agi) = @_;

  if(defined $agi) {
    $self->{server}{agi} = $agi
  }

  return $self->{server}{agi};
}


=head2 process_request

This will process the agi request from asterisk.

=cut

sub process_request {
  my $self = shift;

  $self->_agi_parse();
  $self->_parse_request();
  $self->dispatch_request();
}

=head2 dispatch_request

Method used to dispatch the FastAGI request.

=cut

sub dispatch_request {
  my $self = shift;

  if( $self->can( $self->{server}{method} ) ) {
    my $method = $self->{server}{method};
    $self->log(4, "Handling request: $method");
    $self->$method();
  } else { # Can't find that method.
    $self->log(2, "No method found for: " . $self->{server}{method});
    $self->agi->execute( 'NOOP' ); #NOTE is this the right thing todo?
  }
}

=head2 child_init_hook

This is called by Net::Server during child initialization.  This is
the method to override if you are going to be creating database
connections for instance.

  sub child_init_hook {
    my $self = shift;
    $self->{server}{dbi} = DBI->connect();
  }

=cut

#####
# Internal methods.
#####

sub _agi_parse {
  my $self = shift;

  # Setup AGI object.
  $self->agi(Asterisk::AGI->new);

  # Parse the request.
  my %input = $self->agi->ReadParse();
  $self->{server}{input} = \%input;
}


sub _parse_request {
  my $self = shift;

  # Grab the method and optional path.
  my($method, $path) = $self->{server}{input}{request} =~ m/\/(\w+)\?*([^\/]*)$/;

  # Parse each parameter.  Format is ?blah=foo&asdf=blah
  # Turns into: { blah => foo, asdf => blah }.
  my %params;
  my(@pairs) = split(/[&;]/,$path);
  foreach (@pairs) {
    my($p,$v) = split('=',$_,2);
    $params{$p} = $v;
  }

  # Setup instance variables.
  $self->{server}{params} = \%params;
  $self->{server}{method} = $method;
  $self->{server}{path}	= $path;
}


=head1 SEE ALSO

L<Net::Server>, L<http://asterisk.gnuinter.net/>
		
=head1 AUTHOR

Jason Yates <jaywhy@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2007 by Jason Yates

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
