install-ubuntu-depends: 
	sudo apt-get install libtemplate-perl 

tar: 
	cd .. && tar zcvf ./PearlPBX-0.8.0.tar.gz --exclude ./Pearl-PBX/.git ./Pearl-PBX



