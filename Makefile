tar:
	rm -rf /tmp/Pearl-PBX-1.6
	mkdir -p /tmp/Pearl-PBX-1.6
	cp -av * /tmp/Pearl-PBX-1.6
	cd /tmp && tar cvf ./Pearl-PBX-1.6.tar --exclude ./Pearl-PBX-1.6/.git ./Pearl-PBX-1.6

update_sounds:
	cp -av sounds/* /usr/share/asterisk/sounds/


