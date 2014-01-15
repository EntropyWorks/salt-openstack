#!/bin/bash

db="keystone nova glance cinder"

for i in ${db}
do
	mysqladmin drop -f ${i}	
        mysqladmin create ${i}
done
