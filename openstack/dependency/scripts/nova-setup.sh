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

if [ ! -f /etc/setup-done-nova ] ; then 

    echo " Nova DB sync"
        rm -rf  /var/log/nova/*.log
        cd /etc/init.d/; for i in $( ls nova-* ); do sudo service $i stop; done
        cd /etc/init.d/; for i in $( ls nova-* ); do sudo service $i start; done

    if [ -f /usr/bin/mysqladmin ] ; then
        mysqladmin flush-hosts
    fi

    nova-manage --debug --verbose --config-dir /etc/nova db sync

    sysctl net.ipv4.ip_forward=1 

    echo " Creating private IP"
    nova-manage network create --label private \
          --dns1 8.8.8.8 --dns2 8.8.4.4 \
          --fixed_range_v4 {{ endpoints.nova.network.fixed_range }} \
          --num_networks {{ endpoints.nova.network_private_num }} \
          --bridge_interface {{ endpoints.nova.network.bridge_interface }} \
          --network_size {{ endpoints.nova.network_private_size }} --multi_host=T

    echo " Creating floating IP"
    nova-manage floating create {{  endpoints.nova.network_floating }} --pool="{{ endpoints.nova.availability_zone }}"

{% for delete_network in pillar['endpoints']['nova']['delete_floating'] %}  
    echo " Removing {{ delete_network }}"
    nova-manage floating delete {{ delete_network }}
{% endfor %}

    admin_id=$(keystone tenant-list | grep " admin " | awk '{ print $2 }')
 
    nova-manage project quota --project=${admin_id} --key=cores --value=-1
    nova-manage project quota --project=${admin_id} --key=floating_ips --value=-1
    nova-manage project quota --project=${admin_id} --key=instances --value=-1
    nova-manage project quota --project=${admin_id} --key=ram --value=-1
    nova-manage project quota --project=${admin_id} --key=security_group_rules --value=-1
    nova-manage project quota --project=${admin_id} --key=security_groups --value=-1
    nova-manage project quota --project=${admin_id} --key=metadata_items --value=-1
    nova-manage project quota --project=${admin_id} --key=injected_files --value=-1

    nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
    nova secgroup-add-rule default tcp  22 22 0.0.0.0/0

    cd /etc/init.d/; for i in $( ls nova-* ); do sudo service $i restart; done

    touch "/etc/setup-done-nova"
else
    echo " >>>>>>>>>>>>> Already setup Nova <<<<<<<<<<< "
    echo " >>>>>>>>>> rm /etc/setup-done-nova <<<<<<<<< "
    exit 1
fi
