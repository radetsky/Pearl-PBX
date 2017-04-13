package PearlPBX::Actions;

use warnings;
use strict;

use Data::Dumper;

use Plack::Request;

use PearlPBX::ScalarUtils qw/trim/;
use PearlPBX::Notifications;
use PearlPBX::DB qw/pearlpbx_db/;
use PearlPBX::Pages; 
use PearlPBX::Const;
use PearlPBX::Logger;

use Exporter;
use parent qw(Exporter);
our @EXPORT = qw (
    action_login
    action_logout
);

sub _webuser_authenticate {
  my ($username, $password) = @_;
  my $crypted = undef;
  my $sip_name = undef; 
  my $role = undef; 

  eval {
      ($sip_name, $role, $crypted) = pearlpbx_db()->selectrow_array (
          "select sip_peers_name, roles, passwd_hash from auth.sysusers where login=" .
          pearlpbx_db()->quote($username));
  };

  if ( $@ ) {
    Errf("%s , %s", $@, pearlpbx_db()->errstr );
    return { result => FAIL, reason => "Invalid password" };
  }

  if ( $crypted ) {
    $crypted =~ s/\s+//gs;
    if ( crypt( $password,$crypted ) eq $crypted) {
      my $user_params = {
        username => $username,
        role     => $role,
        sip_name => $sip_name,
      };
      return { result => OK, params => $user_params };
    } else {
      return { result => FAIL, reason => 'Invalid password'};
    }
  }
  Err("User does not exists");
  return { result => FAIL, reason => 'Invalid password'};

}

sub action_login {

    my $env     = shift;
    my $req     = Plack::Request->new($env);
    my $session = $req->session;
    my $params  = $req->parameters;

    my $email    = trim( $params->{log_username} // '' );
    my $password = trim( $params->{log_password} // '' );

    my $user = _webuser_authenticate( $email, $password );

    # we waiting for { result = OK | FAIL, [ reason, user_params e.g. role, sip_name, etc. ]}
    if ( !defined($user) || !defined( $user->{result} ) ) {
        # Something goes wrong
        MessageBox( $env, MSG_SERVER_ERROR, "error" );
        return page_login($env);
    }
    elsif ( $user->{result} ne OK ) {
        MessageBox( $env, $user->{reason}, "error" );
        return page_login($env);
    }
    else {
        $session->{'account'}     = $email;
        $session->{'user_params'} = $user->{params};
        my $res = $req->new_response( 302, [ 'Location' => '/' ] );
        $res->body('Authenticated');
        return $res->finalize($env);
    }
    MessageBox ($env, MSG_SERVER_ERROR, "error");
    Err(MSG_SERVER_ERROR);
    return page_login($env);
}

sub action_logout {
    my $env = shift;
    my $req = Plack::Request->new($env);

    # clear session
    my $session_options = $req->session_options;
    $session_options->{expire} = 1;

    # Redirect to page_login.
    my $res = $req->new_response( 302, [ 'Location' => '/login' ] );
    $res->body('Log Out');
    return $res->finalize();

}

