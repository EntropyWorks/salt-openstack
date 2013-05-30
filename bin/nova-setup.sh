#!/bin/bash

if [ -f /root/scripts/stackrc ] ; then
	source /root/scripts/stackrc
else
	echo "ERROR!!! Failed to load /root/scripts/stackrc"
	exit 1
fi

if [ ! -f /etc/setup-done-nova ] ; then 

	echo " Nova DB sync"
	service nova-api stop
	service nova-cert stop
	service nova-consoleauth stop
	service nova-console stop
	service nova-network stop
        rm -rf  /var/log/nova/*.log
        mysqladmin flush-hosts
	nova-manage --config-dir /etc/nova db sync

	echo " Creating private IP"
	nova-manage network create --label internal \
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

	service nova-api start
	service nova-cert start
	service nova-consoleauth start
	service nova-console start
	service nova-network start

	touch "/etc/setup-done-nova"
else
	echo " >>>>>>>>>>>>> Already setup Nova <<<<<<<<<<< "
	exit 1
fi
