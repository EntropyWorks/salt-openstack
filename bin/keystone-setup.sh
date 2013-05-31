#!/bin/bash


export NOVA_VERSION=1.1
export OS_PASSWORD={{ pillar['openstack']['admin_password'] }}
export OS_AUTH_URL=http://{{ pillar['openstack']['openstack_public_address'] }}:5000/v2.0
export OS_USERNAME=admin
export OS_TENANT_NAME=admin
export OS_REGION_NAME={{ pillar['openstack']['nova_node_availability_zone'] }}
export COMPUTE_API_VERSION=1.1
export OS_NO_CACHE=True

export HOST_IP="{{ pillar['openstack']['openstack_admin_address'] }}"
export EXT_HOST_IP="{{ pillar['openstack']['openstack_public_address'] }}"
export MYSQL_USER=keystone 
export MYSQL_DATABASE=keystone
export MYSQL_HOST="{{ pillar['openstack']['database_host'] }}"
export MYSQL_PASSWORD="{{ pillar['openstack']['database_password'] }}"
export KEYSTONE_REGION="${KEYSTONE_REGION:-RegionOne}"
export SERVICE_TOKEN="{{ pillar['openstack']['admin_token'] }}"
export SERVICE_ENDPOINT="http://${HOST_IP}:35357/v2.0"
export SERVICE_TENANT_NAME=${SERVICE_TENANT_NAME:-service}

export CONTROLLER_PUBLIC_ADDRESS="{{ pillar['openstack']['openstack_public_address'] }}"
export CONTROLLER_ADMIN_ADDRESS="{{ pillar['openstack']['openstack_admin_address'] }}"
export CONTROLLER_INTERNAL_ADDRESS="{{ pillar['openstack']['openstack_internal_address' ] }}"
export KEYSTONE_REGION="{{ pillar['openstack']['nova_node_availability_zone'] }}"

export KEYSTONE_CONF="${KEYSTONE_CONF:-/etc/keystone/keystone.conf}"
export EC2RC="$KEYSTONE_CONF/ec2rc"
export ADMIN_PASSWORD="{{ pillar['openstack']['admin_password'] }}"
export SERVICE_PASSWORD="{{ pillar['openstack']['service_password'] }}"

# Need to create passwords for each of theses eventually.
export GLANCE_PASSWORD="${GLANCE_PASSWORD:-${SERVICE_PASSWORD:-glance}}"
export EC2_PASSWORD="${EC2_PASSWORD:-${SERVICE_PASSWORD:-ec2}}"
export SWIFT_PASSWORD="${SWIFT_PASSWORD:-${SERVICE_PASSWORD:-swiftpass}}"


if [ ! -f /etc/setup-done-keystone ] ; then 

	echo " Restart Keystone"
	service keystone restart	
        echo "--------------------------------"
	grep mysql $KEYSTONE_CONF
        echo "--------------------------------"

	echo " Running keystone-manage db_sync"
	keystone-manage --debug --verbose --config-file /etc/keystone/keystone.conf db_sync

	echo " Setting up Keystone Users and Endpoints"
	/root/scripts/reset-keystone

	touch "/etc/setup-done-keystone"

else
	echo " >>>>>>>>>>>>> Already setup Keystone <<<<<<<<<<< "
	exit 1
fi
