#!/bin/bash

if [ -f /root/scripts/stackrc ] ; then
	source /root/scripts/stackrc
else
	echo "ERROR!!! Failed to load /root/scripts/stackrc"
	exit 1
fi


if [ ! -f /etc/setup-done-cinder ] ; then 

	echo " Nova DB sync"
	sed -i 's/false/true/g' /etc/default/iscsitarget
	cinder-manage --config-dir /etc/cinder --debug --verbose  db sync
	cd /etc/init.d/; for i in $( ls cinder-* ); do sudo service $i restart; done
	cd /etc/init.d/; for i in $( ls cinder-* ); do sudo service $i status; done
	touch "/etc/setup-done-cinder"
else
	echo " >>>>>>>>>>>>> Already setup Cinder <<<<<<<<<<< "
	exit 1
fi
