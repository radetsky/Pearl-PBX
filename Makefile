all: 
	cp /usr/share/perl5/Pearl.pm ./lib 
	cp /usr/share/perl5/PearlPBX/Report.pm ./lib/PearlPBX/
	cp /usr/share/perl5/PearlPBX/Report/* ./lib/PearlPBX/Report/

install-ubuntu-depends: 
	sudo apt-get install libtemplate-perl 

