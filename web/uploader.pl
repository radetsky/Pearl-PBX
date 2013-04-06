#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  uploader.pl
#
#        USAGE:  ./uploader.pl 
#
#  DESCRIPTION:  File Upload handler for PearlPBX
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Alex Radetsky (Rad), <rad@rad.kiev.ua>
#      COMPANY:  Net.Style
#      VERSION:  1.0
#      CREATED:  04.04.2013 13:47:04 EEST
#     REVISION:  ---
#===============================================================================

use 5.8.0;
use strict;
use warnings;

use Pearl;
use Data::Dumper; 
use NetSDS::Util::String; 
use PearlPBX::Audiofile; 

my $pearl = Pearl->new();
my $buffer; 

$pearl->htmlHeader;

my $filebody = $pearl->{cgi}->param('fileinput');
my $uploadtype = $pearl->{cgi}->param('fileupload_voicetype'); ## IVR || MOH 
my $description = str_trim ($pearl->{cgi}->param('fileupload_description')); 
if ($description eq '') {
	print str_encode('<span class="well"> <span class="label label-important"> Важно! </span>');
	print str_encode(' Пожалуйста, заполните описание файла. Оно применяется в редактировании IVR.</span>'); 
	exit(0);
}


unless ($pearl->{cgi}->param('fileupload_name_hidden') ) { 
	print str_encode('<span class="well"> <span class="label label-important"> Важно! </span>');
	print str_encode(' Пожалуйста, выберите .WAV или .MP3 файл.</span>'); 
	exit(0);
}

my $output = "files/" . $pearl->{cgi}->param('fileupload_name_hidden');

my $content_type = $pearl->{cgi}->uploadInfo($filebody)->{'Content-Type'}; 
if ( ( $content_type ne "audio/mpeg") and ($content_type ne "audio/wav") 
	and ($content_type ne "audio/mp3") ) { 
	print str_encode('<span class="well"> <span class="label label-important"> Важно! </span>');
	print str_encode(' К загрузке допускаются только .WAV и .MP3 файлы.</span>'); 
	exit(0);
}

open(OUTFILE,">$output") or die "Can't write to ". $output . ": $!"; 
while(my $bytesread=read($filebody,$buffer,1024)) {
   print OUTFILE $buffer;
}
close(OUTFILE);

my $audiofile = PearlPBX::Audiofile->new('/etc/PearlPBX/asterisk-router.conf'); 

$audiofile->db_connect();

my $file_id = $audiofile->add_or_replace ( 
	$pearl->{cgi}->param('fileupload_name_hidden'),
	$pearl->{cgi}->param('fileupload_voicetype'),
	$pearl->{cgi}->param('fileupload_description')
); 

unless ( defined ( $file_id )) { 
	print str_encode($audiofile->{dbh}->errstr); 
	exit(0);
}

$audiofile->convert(
	$pearl->{cgi}->param('fileupload_name_hidden'), 
	$file_id,
	$pearl->{cgi}->param('fileupload_voicetype')
	); 

print str_encode('<span class="well"> <span class="label label-success"> Успешно! </span>'); 
print str_encode(' Файл успешно загружен. </span>'); 

1;
#===============================================================================

__END__

=head1 NAME

uploader.pl

=head1 SYNOPSIS

uploader.pl

=head1 DESCRIPTION

FIXME

=head1 EXAMPLES

FIXME

=head1 BUGS

Unknown.

=head1 TODO

Empty.

=head1 AUTHOR

Alex Radetsky <rad@rad.kiev.ua>

=cut

