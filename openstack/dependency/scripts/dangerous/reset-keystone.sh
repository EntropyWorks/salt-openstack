#!/usr/bin/env bash

# Copyright 2012 OpenStack LLC
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# Sample initial data for Keystone using python-keystoneclient
#
# This script is based on the original DevStack keystone_data.sh script.
#
# It demonstrates how to bootstrap Keystone with an administrative user
# using the SERVICE_TOKEN and SERVICE_ENDPOINT environment variables
# and the administrative API.  It will get the admin_token (SERVICE_TOKEN)
# and admin_port from keystone.conf if available.
#
# There are two environment variables to set passwords that should be set
# prior to running this script.  Warnings will appear if they are unset.
# * ADMIN_PASSWORD is used to set the password for the admin and demo accounts.
# * SERVICE_PASSWORD is used to set the password for the service accounts.
#
# Enable the Swift and Quantum accounts by setting ENABLE_SWIFT and/or
# ENABLE_QUANTUM environment variables.
#
# Enable creation of endpoints by setting ENABLE_ENDPOINTS environment variable.
# Works with Catalog SQL backend. Do not use with Catalog Templated backend
# (default).
#
# A set of EC2-compatible credentials is created for both admin and demo
# users and placed in etc/ec2rc.
#
# Tenant               User      Roles
# -------------------------------------------------------
# admin                admin     admin
# service              glance    admin
# service              nova      admin
# service              quantum   admin        # if enabled
# service              swift     admin        # if enabled
# demo                 admin     admin
# demo                 demo      Member,sysadmin,netadmin
# invisible_to_admin   demo      Member
set -eu

ENABLE_ENDPOINTS=yes
ENABLE_QUANTUM=no
ENABLE_SWIFT=no

SERVICE_PASSWORD=${SERVICE_PASSWORD:-secrete}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-secrete}
NOVA_PASSWORD=${NOVA_PASSWORD:-${SERVICE_PASSWORD:-nova}}
GLANCE_PASSWORD=${GLANCE_PASSWORD:-${SERVICE_PASSWORD:-glance}}
EC2_PASSWORD=${EC2_PASSWORD:-${SERVICE_PASSWORD:-ec2}}
SWIFT_PASSWORD=${SWIFT_PASSWORD:-${SERVICE_PASSWORD:-swiftpass}}

CONTROLLER_PUBLIC_ADDRESS=${CONTROLLER_PUBLIC_ADDRESS:-localhost}
CONTROLLER_ADMIN_ADDRESS=${CONTROLLER_ADMIN_ADDRESS:-localhost}
CONTROLLER_INTERNAL_ADDRESS=${CONTROLLER_INTERNAL_ADDRESS:-localhost}

KEYSTONE_REGION="${KEYSTONE_REGION:-RegionOne}"

KEYSTONE_CONF=${KEYSTONE_CONF:-/etc/keystone/keystone.conf}
EC2RC="ec2rc"

# Please set these, they are ONLY SAMPLE PASSWORDS!

# Extract some info from Keystone's configuration file
if [[ -r "$KEYSTONE_CONF" ]]; then
    CONFIG_SERVICE_TOKEN=$(sed 's/[[:space:]]//g' $KEYSTONE_CONF | grep ^admin_token= | cut -d'=' -f2)
    CONFIG_ADMIN_PORT=$(sed 's/[[:space:]]//g' $KEYSTONE_CONF | grep ^admin_port= | cut -d'=' -f2)
fi

export SERVICE_TOKEN=${SERVICE_TOKEN:-$CONFIG_SERVICE_TOKEN}
if [[ -z "$SERVICE_TOKEN" ]]; then
    echo "No service token found."
    echo "Set SERVICE_TOKEN manually from keystone.conf admin_token."
    exit 1
fi

export SERVICE_ENDPOINT=${SERVICE_ENDPOINT:-https://$CONTROLLER_PUBLIC_ADDRESS:${CONFIG_ADMIN_PORT:-35357}/v2.0}

function get_id () {
    echo `"$@" | grep ' id ' | awk '{print $4}'`
}


# Tenants
ADMIN_TENANT=$(get_id keystone tenant-create --name=admin)
SERVICE_TENANT=$(get_id keystone tenant-create --name=service)
DEMO_TENANT=$(get_id keystone tenant-create --name=demo)
INVIS_TENANT=$(get_id keystone tenant-create --name=invisible_to_admin)


# Users
ADMIN_USER=$(get_id keystone user-create --name=admin \
                                         --pass="$ADMIN_PASSWORD" \
                                         --email=admin@example.com)
DEMO_USER=$(get_id keystone user-create --name=demo \
                                        --pass="$ADMIN_PASSWORD" \
                                        --email=admin@example.com)
ALT_DEMO_USER=$(get_id keystone user-create --name=alt_demo \
                                        --pass="$ADMIN_PASSWORD" \
                                        --email=admin@example.com)


# Roles
ADMIN_ROLE=$(get_id keystone role-create --name=admin)
MEMBER_ROLE=$(get_id keystone role-create --name=Member)
KEYSTONEADMIN_ROLE=$(get_id keystone role-create --name=KeystoneAdmin)
KEYSTONESERVICE_ROLE=$(get_id keystone role-create --name=KeystoneServiceAdmin)
SYSADMIN_ROLE=$(get_id keystone role-create --name=sysadmin)
NETADMIN_ROLE=$(get_id keystone role-create --name=netadmin)


# Add Roles to Users in Tenants
keystone user-role-add --user-id $ADMIN_USER --role-id $ADMIN_ROLE --tenant-id $ADMIN_TENANT
keystone user-role-add --user-id $DEMO_USER --role-id $MEMBER_ROLE --tenant-id $DEMO_TENANT
keystone user-role-add --user-id $DEMO_USER --role-id $SYSADMIN_ROLE --tenant-id $DEMO_TENANT
keystone user-role-add --user-id $DEMO_USER --role-id $NETADMIN_ROLE --tenant-id $DEMO_TENANT
keystone user-role-add --user-id $DEMO_USER --role-id $MEMBER_ROLE --tenant-id $INVIS_TENANT
keystone user-role-add --user-id $ADMIN_USER --role-id $ADMIN_ROLE --tenant-id $DEMO_TENANT

# TODO(termie): these two might be dubious
keystone user-role-add --user-id $ADMIN_USER --role-id $KEYSTONEADMIN_ROLE --tenant-id $ADMIN_TENANT
keystone user-role-add --user-id $ADMIN_USER --role-id $KEYSTONESERVICE_ROLE --tenant-id $ADMIN_TENANT


# Services
NOVA_SERVICE=$(get_id \
keystone service-create --name=nova \
                        --type=compute \
                        --description="Nova Compute Service")
NOVA_USER=$(get_id keystone user-create --name=nova \
                                        --pass="$SERVICE_PASSWORD" \
                                        --tenant-id $SERVICE_TENANT \
                                        --email=nova@example.com)
keystone user-role-add --tenant-id $SERVICE_TENANT \
                       --user-id $NOVA_USER \
                       --role-id $ADMIN_ROLE
if [[ -n "$ENABLE_ENDPOINTS" ]]; then
    keystone endpoint-create --region $KEYSTONE_REGION --service-id $NOVA_SERVICE \
        --publicurl "$NOVA_PROTOCOL://$CONTROLLER_PUBLIC_ADDRESS:\$(compute_port)s/v2/\$(tenant_id)s" \
        --adminurl "$NOVA_PROTOCOL://$CONTROLLER_ADMIN_ADDRESS:\$(compute_port)s/v2/\$(tenant_id)s" \
        --internalurl "$NOVA_PROTOCOL://$CONTROLLER_INTERNAL_ADDRESS:\$(compute_port)s/v2/\$(tenant_id)s"
fi

EC2_SERVICE=$(get_id \
keystone service-create --name=ec2 \
                        --type=ec2 \
                        --description="EC2 Compatibility Layer")
if [[ -n "$ENABLE_ENDPOINTS" ]]; then
    keystone endpoint-create --region $KEYSTONE_REGION --service-id $EC2_SERVICE \
        --publicurl "$NOVA_PROTOCOL://$CONTROLLER_PUBLIC_ADDRESS:$NOVA_EC2_PORT/services/Cloud" \
        --adminurl "$NOVA_PROTOCOL://$CONTROLLER_ADMIN_ADDRESS:$NOVA_EC2_PORT/services/Admin" \
        --internalurl "$NOVA_PROTOCOL://$CONTROLLER_INTERNAL_ADDRESS:$NOVA_EC2_PORT/services/Cloud"
fi

GLANCE_SERVICE=$(get_id \
keystone service-create --name=glance \
                        --type=image \
                        --description="Glance Image Service")
GLANCE_USER=$(get_id keystone user-create --name=glance \
                                          --pass="$SERVICE_PASSWORD" \
                                          --tenant-id $SERVICE_TENANT \
                                          --email=glance@example.com)
keystone user-role-add --tenant-id $SERVICE_TENANT \
                       --user-id $GLANCE_USER \
                       --role-id $ADMIN_ROLE
if [[ -n "$ENABLE_ENDPOINTS" ]]; then
    keystone endpoint-create --region $KEYSTONE_REGION --service-id $GLANCE_SERVICE \
        --publicurl "$GLANCE_PROTOCOL://$CONTROLLER_PUBLIC_ADDRESS:$GLANCE_PORT/v1" \
        --adminurl "$GLANCE_PROTOCOL://$CONTROLLER_ADMIN_ADDRESS:$GLANCE_PORT/v1" \
        --internalurl "$GLANCE_PROTOCOL://$CONTROLLER_INTERNAL_ADDRESS:$GLANCE_PORT/v1"
fi

KEYSTONE_SERVICE=$(get_id \
keystone service-create --name=keystone \
                        --type=identity \
                        --description="Keystone Identity Service")
if [[ -n "$ENABLE_ENDPOINTS" ]]; then
    keystone endpoint-create --region $KEYSTONE_REGION --service-id $KEYSTONE_SERVICE \
        --publicurl "$KEYSTONE_AUTH_PROTOCOL://$CONTROLLER_PUBLIC_ADDRESS:\$(public_port)s/v2.0" \
        --adminurl "$KEYSTONE_AUTH_PROTOCOL://$CONTROLLER_ADMIN_ADDRESS:\$(admin_port)s/v2.0" \
        --internalurl "$KEYSTONE_AUTH_PROTOCOL://$CONTROLLER_INTERNAL_ADDRESS:\$(public_port)s/v2.0"
fi

VOLUME_SERVICE=$(get_id \
keystone service-create --name="cinder" \
                        --type=volume \
                        --description="Cinder Volume Service")
VOLUME_USER=$(get_id keystone user-create --name=cinder \
                                          --pass="$SERVICE_PASSWORD" \
                                          --tenant-id $SERVICE_TENANT \
                                          --email=cinder@example.com)
keystone user-role-add --tenant-id $SERVICE_TENANT \
                       --user-id $VOLUME_USER \
                       --role-id $ADMIN_ROLE

if [[ -n "$ENABLE_ENDPOINTS" ]]; then
    keystone endpoint-create --region $KEYSTONE_REGION --service-id $VOLUME_SERVICE \
        --publicurl "$CINDER_PROTOCOL://$CONTROLLER_PUBLIC_ADDRESS:$CINDER_PORT/v1/\$(tenant_id)s" \
        --adminurl "$CINDER_PROTOCOL://$CONTROLLER_ADMIN_ADDRESS:$CINDER_PORT/v1/\$(tenant_id)s" \
        --internalurl "$CINDER_PROTOCOL://$CONTROLLER_INTERNAL_ADDRESS:$CINDER_PORT/v1/\$(tenant_id)s"
fi

keystone service-create --name="horizon" \
                        --type=dashboard \
                        --description="OpenStack Dashboard"

if [[ -n "$ENABLE_SWIFT" ]]; then
    SWIFT_SERVICE=$(get_id \
    keystone service-create --name=swift \
                            --type="object-store" \
                            --description="Swift Service")
    SWIFT_USER=$(get_id keystone user-create --name=swift \
                                             --pass="$SERVICE_PASSWORD" \
                                             --tenant-id $SERVICE_TENANT \
                                             --email=swift@example.com)
    keystone user-role-add --tenant-id $SERVICE_TENANT \
                           --user-id $SWIFT_USER \
                           --role-id $ADMIN_ROLE
    if [[ -n "$ENABLE_ENDPOINTS" ]]; then
        keystone endpoint-create --region $KEYSTONE_REGION --service-id $SWIFT_SERVICE \
            --publicurl   "http://$CONTROLLER_PUBLIC_ADDRESS:8080/v1/AUTH_\$(tenant_id)s" \
            --adminurl    "http://$CONTROLLER_ADMIN_ADDRESS:8080/v1/AUTH_\$(tenant_id)s" \
            --internalurl "http://$CONTROLLER_INTERNAL_ADDRESS:8080/v1/AUTH_\$(tenant_id)s"
    fi
fi

if [[ -n "$ENABLE_QUANTUM" ]]; then
    QUANTUM_SERVICE=$(get_id \
    keystone service-create --name=quantum \
                            --type=network \
                            --description="Quantum Service")
    QUANTUM_USER=$(get_id keystone user-create --name=quantum \
                                               --pass="$SERVICE_PASSWORD" \
                                               --tenant-id $SERVICE_TENANT \
                                               --email=quantum@example.com)
    keystone user-role-add --tenant-id $SERVICE_TENANT \
                           --user-id $QUANTUM_USER \
                           --role-id $ADMIN_ROLE
    if [[ -n "$ENABLE_ENDPOINTS" ]]; then
        keystone endpoint-create --region $KEYSTONE_REGION --service-id $QUANTUM_SERVICE \
            --publicurl   "http://$CONTROLLER_PUBLIC_ADDRESS:9696" \
            --adminurl    "http://$CONTROLLER_ADMIN_ADDRESS:9696" \
            --internalurl "http://$CONTROLLER_INTERNAL_ADDRESS:9696"
    fi
fi


# create ec2 creds and parse the secret and access key returned
RESULT=$(keystone ec2-credentials-create --tenant-id=$ADMIN_TENANT --user-id=$ADMIN_USER)
ADMIN_ACCESS=`echo "$RESULT" | grep access | awk '{print $4}'`
ADMIN_SECRET=`echo "$RESULT" | grep secret | awk '{print $4}'`

RESULT=$(keystone ec2-credentials-create --tenant-id=$DEMO_TENANT --user-id=$DEMO_USER)
DEMO_ACCESS=`echo "$RESULT" | grep access | awk '{print $4}'`
DEMO_SECRET=`echo "$RESULT" | grep secret | awk '{print $4}'`


# write the secret and access to ec2rc
cat > $EC2RC <<EOF
ADMIN_ACCESS=$ADMIN_ACCESS
ADMIN_SECRET=$ADMIN_SECRET
DEMO_ACCESS=$DEMO_ACCESS
DEMO_SECRET=$DEMO_SECRET
EOF
