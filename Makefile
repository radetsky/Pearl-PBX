tar: 
	cd .. && tar cvf ./PearlPBX-1.4.tar --exclude ./Pearl-PBX/.git ./Pearl-PBX

update_sounds: 
	cp -av sounds/* /usr/share/asterisk/sounds/


