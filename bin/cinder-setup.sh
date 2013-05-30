#!/bin/bash

if [ -f /root/scripts/stackrc ] ; then
	source /root/scripts/stackrc
else
	echo "ERROR!!! Failed to load /root/scripts/stackrc"
	exit 1
fi


if [ ! -f /etc/setup-done-cinder ] ; then 

	echo " Nova DB sync"
	cinder-manage --config-dir /etc/cinder --debug --verbose  db sync

	touch "/etc/setup-done-cinder"
else
	echo " >>>>>>>>>>>>> Already setup Cinder <<<<<<<<<<< "
	exit 1
fi
