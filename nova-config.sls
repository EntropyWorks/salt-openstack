include:
  - openstack.root-scripts

/etc/nova:
  file:
    - recurse
    - source: salt://openstack/nova
    - template: jinja
    - required:
      - pkg.installed: nova-pkgs
    - defaults:
        nova_flat_network_dhcp_start: {{ pillar['openstack']['nova_flat_network_dhcp_start'] }}
        openstack_internal_address: {{ pillar['openstack']['openstack_internal_address'] }}
        openstack_public_address: {{ pillar['openstack']['openstack_public_address'] }}
        admin_password: {{ pillar['openstack']['admin_password'] }}
        service_password: {{ pillar['openstack']['service_password']}}
        service_token: {{ pillar['openstack']['admin_token'] }}
        database_password: {{ pillar['openstack']['database_password'] }}
        keystone_host: {{ pillar['openstack']['keystone_host'] }}
        keystone_auth_port: {{ pillar['openstack']['keystone_auth_port'] }}
        keystone_auth_protocol: {{ pillar['openstack']['keystone_auth_protocol'] }}
        glance_host: {{ pillar['openstack']['glance_host'] }}
        glance_protocol: {{ pillar['openstack']['glance_protocol'] }}
        glance_port: {{ pillar['openstack']['glance_port'] }}
        nova_host: {{ pillar['openstack']['openstack_public_address'] }}
        nova_network_private_interface: {{ pillar['openstack']['nova_network_private_interface'] }}
        nova_node_availability_zone: {{ pillar['openstack']['nova_node_availability_zone'] }}
        nova_network_flat_interface: {{ pillar['openstack']['nova_network_flat_interface'] }}
        rabbit_host: {{ pillar['openstack']['rabbit_host'] }}
        rabbit_password: {{ pillar['openstack']['rabbit_password'] }}
        nova_network_public_interface: {{ pillar['openstack']['nova_network_public_interface'] }}
        fixed_range: {{ pillar['openstack']['nova_network_private'] }}
        my_ip: {{ pillar['openstack']['openstack_internal_address'] }}
        nova_libvirt_type: {{ pillar['openstack']['nova_libvirt_type'] }}
        nova_compute_driver: {{ pillar['openstack']['nova_compute_driver'] }}
        nova_network_private: {{ pillar['openstack']['nova_network_private'] }}
        quantum_host: {{ pillar['openstack']['database_host'] }}
        s3_host: {{ pillar['openstack']['database_host'] }}
        ec2_host: {{ pillar['openstack']['database_host'] }}
        ec2_dmz_host: {{ pillar['openstack']['database_host'] }}
        ec2_url: {{ pillar['openstack']['database_host'] }}
        cc_host: {{ pillar['openstack']['database_host'] }}
        database_host: {{ pillar['openstack']['database_host'] }}
        nova_dhcpbridge: {{ pillar['openstack']['nova_dhcpbridge'] }}
