#===============================================================================
#
#         FILE:  Pearl.pm
#
#  DESCRIPTION:  Base class for Pearl Engine.
#
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  21.03.2012 00:26:21 EET
#===============================================================================
=head1 NAME

NetSDS::

=head1 SYNOPSIS

	use Pearl::;

=head1 DESCRIPTION

C<NetSDS> module contains superclass all other classes should be inherited from.

=cut

package Pearl;

use 5.8.0;
use strict;
use warnings;

use CGI; 

use version; our $VERSION = "1.0";
our @EXPORT_OK = qw();

#===============================================================================
#
=head1 CLASS METHODS

=over

=item B<new([...])> - class constructor

    my $object = NetSDS::SomeClass->new(%options);

=cut

#-----------------------------------------------------------------------
sub new {
  
	my $this = {};
	$this->{cgi} = CGI->new;

	bless $this;
	return $this;

};

#***********************************************************************
=head1 OBJECT METHODS

=over

=item B<user(...)> - object method

=cut

#-----------------------------------------------------------------------

sub parseDate {

	my $this = shift; 
	my $param = shift; 

	return undef unless ( $param ); 
	
  unless ( $param =~ /^(\d{4})-(\d{2})-(\d{2})$/ ) {
		return undef; 
	}

	return 1; 
};

sub parseTime { 

	my $this = shift; 
	my $param = shift; 

	return undef unless ( $param ); 
	
	unless ( $param =~ /^(\d{2}):(\d{2})$/ ) { 
		return undef; 
	}

	return 1;  
}

sub parsePhone { 

	my $this = shift; 
	my $param = shift; 

	return undef unless ( $param ); 
	
	unless ( $param =~ /^(\d{3,15})$/ ) { 
		return undef; 
	}

	return 1;  
}


sub htmlError { 
  my $this = shift; 
	my $str = shift; 

	#$this->htmlHeader; 
	my $out = "<font color=#ff0000>".$str."</font>";
	print $out; 
};

sub htmlHeader {
	my $this = shift; 
	print $this->{cgi}->header( -type => 'text/html', 
		                    			-charset => 'utf-8' );
}; 

=item B<read1stlines(directory) 

 Возвращает список уловных обозначений и наименований файлов.
 Пример: ((001-alltraffic,Весь траффик),(007-internalcalls,Внутренние звонки)) 
 Условные обозначения - это имена файлов без расширения, 
 Наименование отчета - первая строка из файла html внутри комментария. 

=cut 

sub read1stlines {
	my ($this, $dirname) = @_; 
	my @result; 

	opendir my ($dh), $dirname or return undef; 
	my @files = readdir $dh; 
	closedir $dh;

	foreach my $filename (sort @files) { 
		if ($filename =~ /\.html$/) { 
			# try to read first line 
		  	next unless ( open ( my $fh, $dirname.'/'.$filename ) ); 	
			my $firstline = <$fh>;
			close $fh; 
			# cut off comment chars
			$firstline =~ s/<!--//g; 
			$firstline =~ s/-->//g;
			$filename =~ s/\.html$//g; 
			push @result, [ $filename, $firstline ];
		}
	}
	return @result; 
}

sub readwholebodies { 
	my ($this, $dirname) = @_; 

	my $result = ''; 

	opendir my ($dh), $dirname or return undef; 
	my @files = readdir $dh; 
	closedir $dh;

	foreach my $filename (sort @files) { 
		if ($filename =~ /\.html$/) { 
			next unless ( open ( my $fh, $dirname.'/'.$filename ) ); 	
			my @body = <$fh>;
			close $fh;
			$filename =~ s/\.html$//g; 
			$result .= '<div id="'.$filename.'">';
			foreach my $line (@body) {
				$result .= $line;
			} 
			$result .= '</div>'; 
		}
	}
	return $result; 

}

=item B<listreportsnames> 

 Возвращает список (LIST) уловных обозначений и наименований отчетов. 
 Пример: ((001-alltraffic,Весь траффик),(007-internalcalls,Внутренние звонки)) 
 Условные обозначения - это имена файлов без расширения, 
 Наименование отчета - первая строка из файла html внутри комментария. 
 Читается каталог /usr/share/pearlpbx/reports

=cut 

sub listreportsnames { 
	my ($this,$rtype) = @_;

	 
    my $dirname = '/usr/share/pearlpbx/reports';

	if ( defined ( $rtype ) ) { 
		  if ($rtype =~ /sum/i ) { 
				$dirname .= '/summary'; 
			} 
	} 

	return $this->read1stlines($dirname); 

};

=item B<reportsbodies> 

	Возвращает тела всех доступных отчетов, 
	Каждый отчет в своем div-е c названием равным имени отчета 

=cut 

sub reportsbodies { 
	my ($this,$rtype) = @_; 

	my $dirname = '/usr/share/pearlpbx/reports';

	 if ( defined ( $rtype ) ) {
      if ($rtype =~ /sum/i ) {
        $dirname .= '/summary';
      }
  	}
  	return $this->readwholebodies($dirname);

};

sub cgi_params_to_hashref { 
	my $this = shift; 

	my $hash_ref = undef; 

	my @names = $this->{cgi}->param; 
	foreach my $name (@names) { 
		$hash_ref->{$name} = $this->{cgi}->param($name); 
	} 
	return $hash_ref; 
} 

sub hashref2arrayofhashes { 
	my $this = shift; 
	my $hash_ref = shift; 
	my @output; 

	foreach my $cdr_key (sort keys %$hash_ref ) { 
		push @output, %{$hash_ref->{$cdr_key}};
	}

	return @output; 
}

=item B<modulesnames(dirname,rtype)>

Возвращает список имен модулей и их человеческих названий 
из каталога /usr/share/pearlpbx/modules/$rtype

=cut 

sub modulesnames { 
	my ($this,$rtype) = @_; 

	return $this->read1stlines($this->_dirname($rtype));

}

sub modulesbodies { 
	my ($this,$rtype) = @_; 

	return $this->readwholebodies($this->_dirname($rtype));
}

sub _dirname {
    my ($this, $rtype) = @_; 

	my $dirname = "/usr/share/pearlpbx/modules/";
	if ($rtype =~ /^ivr$/) {
		$dirname .= $rtype; 
	}
	if ($rtype =~ /^katyusha$/ ) { 
		$dirname .= $rtype; 
	}
	if ($rtype =~ /^konference$/ ) { 
		$dirname .= $rtype; 
	}
	if ($rtype =~ /^backup$/ ) { 
		$dirname .= $rtype; 
	}

    if ($rtype =~ /^callback$/) {
        $dirname .= $rtype; 
    }

    return $dirname;
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


