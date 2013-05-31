#!/bin/bash

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
        mysqladmin flush-hosts
	nova-manage --debug --verbose --config-dir /etc/nova db sync

	sysctl net.ipv4.ip_forward=1 

	echo " Creating private IP"
	nova-manage network create --label private \
	      --dns1 8.8.8.8 --dns2 8.8.4.4 \
	      --fixed_range_v4 {{ pillar['openstack']['nova_network_private'] }} \
	      --num_networks {{ pillar['openstack']['nova_network_private_num'] }} \
	      --bridge_interface {{ pillar['openstack']['nova_network_bridge_interface'] }} \
	      --network_size {{ pillar['openstack']['nova_network_private_size'] }} --multi_host=T

	echo " Creating floating IP"
	nova-manage floating create {{  pillar['openstack']['nova_network_floating'] }} --pool=nova

{% for delete_network in pillar['openstack']['nova_delete_floating'] %}	
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
