tar:
	rm -rf /tmp/Pearl-PBX-1.4 
	mkdir -p /tmp/Pearl-PBX-1.4 
	cp -av * /tmp/Pearl-PBX-1.4
	cd /tmp && tar cvf ./Pearl-PBX-1.4.tar --exclude ./Pearl-PBX-1.4/.git ./Pearl-PBX-1.4

update_sounds: 
	cp -av sounds/* /usr/share/asterisk/sounds/


