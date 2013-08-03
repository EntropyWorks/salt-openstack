#!/bin/bash
pushd /etc/init.d  
for i in $(/bin/ls nova-*) ; do 
	echo $i 
	service $i stop 
	sleep 5 
	service $i start 
done  
popd
