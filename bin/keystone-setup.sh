#!/bin/bash

if [ -f /root/scripts/stackrc ] ; then
	source /root/scripts/stackrc
else
	echo "ERROR!!! Failed to load /root/scripts/stackrc"
	exit 1
fi

set -x
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

export KEYSTONE_CONF="${KEYSTONE_CONF:-/etc/keystone/keystone.conf}"
export EC2RC="$KEYSTONE_CONF/ec2rc"

export ADMIN_PASSWORD="{{ pillar['openstack']['admin_password'] }}"
export SERVICE_PASSWORD="{{ pillar['openstack']['service_password'] }}"
# Need to create passwords for each of theses eventually.
export GLANCE_PASSWORD="${GLANCE_PASSWORD:-${SERVICE_PASSWORD:-glance}}"
export EC2_PASSWORD="${EC2_PASSWORD:-${SERVICE_PASSWORD:-ec2}}"
export SWIFT_PASSWORD="${SWIFT_PASSWORD:-${SERVICE_PASSWORD:-swiftpass}}"
set +x


if [ ! -f /etc/setup-done-keystone ] ; then 
	echo " Restart Keystone"
	service keystone restart
	
	echo " Running keystone-manage db_sync"
	keystone-manage --config-file /etc/keystone/keystone.conf db_sync

	echo " Setting up Keystone Users"
#	/root/scripts/keystone_basic.sh

	echo " Setting up Keystone Endpoints"
#	/root/scripts/keystone_endpoints_basic.sh
#	/root/scripts/sample_data.sh
	/root/scripts/reset-keystone

	touch "/etc/setup-done-keystone"

else
	echo " >>>>>>>>>>>>> Already setup Keystone <<<<<<<<<<< "
	exit 1
fi
