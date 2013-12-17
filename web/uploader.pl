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
unless ($pearl->{cgi}->param('fileupload_name_hidden') ) { 
	print str_encode('<span class="well" style="width: 100%;"> <span class="label label-important"> Важно! </span>');
	print str_encode(' Пожалуйста, выберите файл.</span>'); 
	exit(0);
}

my $module = $pearl->{cgi}->param('fileupload_module'); 
if ( defined ( $module )  and ($module =~ /^hints/i ) ) { 
	# Это таки Hints ?  
	# Получаем кастомные параметры модуля 
	my $hintupload = $pearl->{cgi}->param('hintupload'); 
	my $since = $pearl->{cgi}->param('sincehint'); 
	my $till = $pearl->{cgi}->param('tillhint'); 

	unless ( defined ( $since ) ) { 
		uploader_status('important','Пожалуйста, укажите дату начала периода подсказки.'); 
		exit(0); 
	}
	unless ( defined ( $till ) ) { 
		uploader_status('important','Пожалуйста, укажите дату окончания периода подсказки.'); 
		exit(0); 
	}

	unless ( defined ( $hintupload) ) { 
		uploader_status('important','Пожалуйста, укажите текст подсказки.'); 
		exit(0); 
	}
	if ($hintupload eq '') { 
		uploader_status('important','Пожалуйста, укажите текст подсказки.'); 
		exit(0); 
	}
	my $output = "files/" . $pearl->{cgi}->param('fileupload_name_hidden');
	my $content_type = $pearl->{cgi}->uploadInfo($filebody)->{'Content-Type'}; 

	if ( $content_type ne "text/csv") { 
		uploader_status('important','К загрузке допускаются только .CSV файлы.'); 
		exit(0);
	}

	open(OUTFILE,">$output") or die "Can't write to ". $output . ": $!"; 
	while(my $bytesread=read($filebody,$buffer,1024)) {
  		 print OUTFILE $buffer;	
	}
	close(OUTFILE);
	
	# Все проверили и успешно сохранили файл. Теперь надо запустить модуль hints и таки добавить это чудо в базу 
	my $modulename = "PearlPBX::Module::$module"; 
	eval "use $modulename;"; 
	if ( $@ ) { 
		uploader_status('important','Модуль не найден!'); 
		exit(0); 
	} 
	my $hints = $modulename->new('/etc/PearlPBX/asterisk-router.conf');
	$hints->db_connect();

	my $params = $pearl->cgi_params_to_hashref(); 
    unless ( defined ( $hints->add ( $params ) ) ) { 
    	uploader_status ('important','Произошла какая-то ошибка в модуле PearlPBX::Module::Hints');
    	print "<br/><br/><br/>";
    	uploader_status ('important',$hints->{dbh}->errstr);
    	exit(0); 
    }

	uploader_status('success','Файл успешно загружен.'); 
    exit(0);

}

my $uploadtype = $pearl->{cgi}->param('fileupload_voicetype'); ## IVR || MOH 
my $description = str_trim ($pearl->{cgi}->param('fileupload_description')); 

if ($description eq '') {
	uploader_status('important','Пожалуйста, заполните описание файла. Оно применяется в редактировании IVR.'); 
	exit(0);
}

unless ($pearl->{cgi}->param('fileupload_name_hidden') ) { 
	uploader_status('important','Пожалуйста, выберите .WAV или .MP3 файл.'); 
	exit(0);
}

my $output = "files/" . $pearl->{cgi}->param('fileupload_name_hidden');

my $content_type = $pearl->{cgi}->uploadInfo($filebody)->{'Content-Type'}; 
if ( ( $content_type ne "audio/mpeg") and ($content_type ne "audio/wav") 
	and ($content_type ne "audio/mp3") ) { 
		uploader_status('important','К загрузке допускаются только .WAV и .MP3 файлы.'); 
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

uploader_status('success','Файл успешно загружен.'); 

exit(0);

sub uploader_status { 
	my ($result, $text) = @_; 

	if ($result =~ /success/ ) { 
		print str_encode('<span class="well"> <span class="label label-success"> Успешно! </span>'); 
	}
	if ($result =~ /important/ ) { 
		print str_encode('<span class="well"> <span class="label label-important"> Важно! </span>');
	}
	print str_encode(' '.$text. ' </span>'); 
	return 1;
}


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

