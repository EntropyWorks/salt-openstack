export CONTROLLER_PUBLIC_ADDRESS="{{ endpoints.openstack_public_address }}"
export CONTROLLER_ADMIN_ADDRESS="{{ endpoints.openstack_admin_address }}"
export CONTROLLER_INTERNAL_ADDRESS="{{ endpoints.openstack_internal_address }}"
export KEYSTONE_REGION="{{ endpoints.nova.availability_zone }}"
export KEYSTONE_AUTH_PORT="{{ keystone.auth_port }}"
export KEYSTONE_AUTH_PROTOCOL="{{ keystone.auth_protocol }}"
export NOVA_PROTOCOL="{{ nova.protocol }}"
export NOVA_EC2_PORT="{{ nova.ec2_port }}"
export GLANCE_PROTOCOL="{{ glance.protocol }}"
export GLANCE_PORT="{{ glance.port }}"
export CINDER_PROTOCOL="{{ cinder.protocol }}"
export CINDER_PORT="{{ cinder.port }}"

NOVA_SERVICE = $(keystone service-get nova | grep id | awk '{ print $4 }')
EC2_SERVICE = $(keystone service-get ec2 | grep id | awk '{ print $4 }')
GLANCE_SERVICE = $(keystone service-get glance | grep id | awk '{ print $4 }')
KEYSTONE_SERVICE = $(keystone service-get keystone | grep id | awk '{ print $4 }')
VOLUME_SERVICE = $(keystone service-get cinder | grep id | awk '{ print $4 }')

echo VOLUME_SERVICE KEYSTONE_SERVICE GLANCE_SERVICE EC2_SERVICE NOVA_SERVICE

exit;

    keystone endpoint-create --region $KEYSTONE_REGION --service-id $NOVA_SERVICE \
        --publicurl "$NOVA_PROTOCOL://$CONTROLLER_PUBLIC_ADDRESS:\$(compute_port)s/v2/\$(tenant_id)s" \
        --adminurl "$NOVA_PROTOCOL://$CONTROLLER_ADMIN_ADDRESS:\$(compute_port)s/v2/\$(tenant_id)s" \
        --internalurl "$NOVA_PROTOCOL://$CONTROLLER_INTERNAL_ADDRESS:\$(compute_port)s/v2/\$(tenant_id)s"

    keystone endpoint-create --region $KEYSTONE_REGION --service-id $EC2_SERVICE \
        --publicurl "$NOVA_PROTOCOL://$CONTROLLER_PUBLIC_ADDRESS:$NOVA_EC2_PORT/services/Cloud" \
        --adminurl "$NOVA_PROTOCOL://$CONTROLLER_ADMIN_ADDRESS:$NOVA_EC2_PORT/services/Admin" \
        --internalurl "$NOVA_PROTOCOL://$CONTROLLER_INTERNAL_ADDRESS:$NOVA_EC2_PORT/services/Cloud"

    keystone endpoint-create --region $KEYSTONE_REGION --service-id $GLANCE_SERVICE \
        --publicurl "$GLANCE_PROTOCOL://$CONTROLLER_PUBLIC_ADDRESS:$GLANCE_PORT/v1" \
        --adminurl "$GLANCE_PROTOCOL://$CONTROLLER_ADMIN_ADDRESS:$GLANCE_PORT/v1" \
        --internalurl "$GLANCE_PROTOCOL://$CONTROLLER_INTERNAL_ADDRESS:$GLANCE_PORT/v1"

    keystone endpoint-create --region $KEYSTONE_REGION --service-id $KEYSTONE_SERVICE \
        --publicurl "$KEYSTONE_AUTH_PROTOCOL://$CONTROLLER_PUBLIC_ADDRESS:\$(public_port)s/v2.0" \
        --adminurl "$KEYSTONE_AUTH_PROTOCOL://$CONTROLLER_ADMIN_ADDRESS:\$(admin_port)s/v2.0" \
        --internalurl "$KEYSTONE_AUTH_PROTOCOL://$CONTROLLER_INTERNAL_ADDRESS:\$(public_port)s/v2.0"

    keystone endpoint-create --region $KEYSTONE_REGION --service-id $VOLUME_SERVICE \
        --publicurl "$CINDER_PROTOCOL://$CONTROLLER_PUBLIC_ADDRESS:$CINDER_PORT/v1/\$(tenant_id)s" \
        --adminurl "$CINDER_PROTOCOL://$CONTROLLER_ADMIN_ADDRESS:$CINDER_PORT/v1/\$(tenant_id)s" \
        --internalurl "$CINDER_PROTOCOL://$CONTROLLER_INTERNAL_ADDRESS:$CINDER_PORT/v1/\$(tenant_id)s"


nova-manage floating create --pool dbaas-aw2az2-v1 --interface vlan717  --ip_range 15.125.16.0/20
