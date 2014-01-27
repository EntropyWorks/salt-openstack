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
set -x
mysqladmin flush-hosts

cd /etc/init.d/; for i in $( ls nova-* ); do sudo service $i stop; done
cd /etc/init.d/; for i in $( ls keystone ); do sudo service $i stop; done
cd /etc/init.d/; for i in $( ls cinder-* ); do sudo service $i stop; done
cd /etc/init.d/; for i in $( ls glance-* ); do sudo service $i stop; done

#service rabbitmq-server stop

ifconfig br100 down
brctl delbr br100

#apt-get remove -y --purge rabbitmq-server

apt-get remove -y --purge nova-api nova-cert nova-common \
  nova-console nova-consoleauth nova-network nova-scheduler \
  nova-common \
  nova-network \
  nova-api \
  nova-cert \
  novnc \
  nova-consoleauth \
  nova-scheduler \
  nova-novncproxy \
  nova-doc \
  nova-conductor \
  python-nova \
  python-novaclient > /dev/null

rm -rf /etc/nova


apt-get remove -y --purge keystone python-keystone \
  python-keystoneclient python-openstack-auth \
  python-swiftclient > /dev/null

rm -rf /etc/keystone
rm -rf /var/lib/keystone


apt-get remove -y --purge glance glance-api glance-common \
  glance-registry python-glance python-glanceclient > /dev/null

rm -rf /etc/glance
rm -rf /var/lib/glance


apt-get remove -y --purge cinder-api cinder-common cinder-scheduler \
  cinder-volume python-cinder python-cinderclient > /dev/null

rm -rf /etc/cinder
rm -rf /var/lib/cinder

skipped(){
mysql mysql --execute='select Host,User,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv,Grant_priv from user;'
for i in nova keystone cinder glance quantum ; do
        mysqladmin -f drop ${i} &> /dev/null
        mysql mysql --execute="drop user '${i}';" &> /dev/null
        mysql mysql --execute="drop user '${i}'@'*'" &> /dev/null
        mysql mysql --execute="drop user '${i}-star'@'*'" &> /dev/null
        mysql mysql --execute="drop user '${i}'@'%'" &> /dev/null
        mysql mysql --execute="drop user '${i}'@'localhost'" &> /dev/null
done

mysql mysql --execute='select Host,User,Select_priv,Insert_priv,Update_priv,Delete_priv,Create_priv,Drop_priv,Grant_priv from user;'
mysqladmin flush-hosts
}

apt-get -y autoremove

rm -rf /var/log/cinder \
  /var/log/nova \
  /var/log/glance \
  /var/log/upstart/nova* \
  /var/log/upstart/cinder* \
  /var/log/upstart/keystone* \
  /tmp/keystone-signing-nova \
  /etc/setup-done-* \
  /var/lib/nova/nova.sqlite \
  /var/lib/rabbitmq/mnesia \
  /var/log/upstart/glance*

#/etc/apt/sources.list.d/openstack-ubuntu-archive.list \
