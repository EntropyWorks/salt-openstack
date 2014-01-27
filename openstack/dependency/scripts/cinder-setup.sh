#!/bin/bash
# Copyright 2012-2013 Hewlett-Packard Development Company, L.P.
# All Rights Reserved.
#
# Authored by Yazz D. Atlas <yazz.atlas@hp.com>
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#

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
