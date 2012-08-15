install-ubuntu-depends: 
	sudo apt-get install libtemplate-perl 

tar: 
	cd .. && tar zcvf ./PearlPBX-0.4.3.tar.gz --exclude ./Pearl-PBX/.git ./Pearl-PBX



