tar: 
	cd .. && tar zcvf ./PearlPBX-1.0.tar.gz --exclude ./Pearl-PBX/.git ./Pearl-PBX

update_sounds: 
	cp -av sounds/* /usr/share/asterisk/sounds/


