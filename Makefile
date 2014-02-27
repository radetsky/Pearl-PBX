tar: 
	cd .. && tar zcvf ./PearlPBX-1.2.1.tar.gz --exclude ./Pearl-PBX/.git ./Pearl-PBX

update_sounds: 
	cp -av sounds/* /usr/share/asterisk/sounds/


