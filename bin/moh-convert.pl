#!/usr/bin/perl 

use warnings; 
use strict; 
use 5.8.0;

my $indir = $ARGV[0];
my $outdir = $ARGV[1]; 

unless ( defined ( $indir ) )  { 
 die "Usage: $0 <input directory> <output directory>\n"; 
}

unless ( defined ( $outdir ) ) { 
 die "Usage: $0 <input directory> <output directory>\n";
}

opendir (my $dh, $indir ) or die "Can't open $indir : $!\n"; 
while (my $file = readdir $dh) {
	next if ($file =~ /^\./);

	if ($file =~ /(mp3|wav)$/ ) {
		my ($outfile,$inext) = split ('\.',$file);  
		my $result = `/usr/bin/sox $indir/$file -t ul -c 1 -r 8000 $outdir/$outfile.ul`; 
	}
}


