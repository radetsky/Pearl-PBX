tar:
	rm -rf /tmp/Pearl-PBX-1.5 
	mkdir -p /tmp/Pearl-PBX-1.5 
	cp -av * /tmp/Pearl-PBX-1.5
	cd /tmp && tar cvf ./Pearl-PBX-1.5.tar --exclude ./Pearl-PBX-1.5/.git ./Pearl-PBX-1.5

update_sounds: 
	cp -av sounds/* /usr/share/asterisk/sounds/


