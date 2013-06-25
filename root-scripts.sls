/root/scripts:
  file:
    - recurse
    - source: salt://openstack/bin
    - file_mode: 755
    - template: jinja
    - required:
      - pkgrepo.managed: private-openstack-repo
    - defaults:
      openstack_internal_address: {{ pillar['openstack']['openstack_internal_address'] }}
      openstack_public_address: {{ pillar['openstack']['openstack_public_address'] }}
      admin_password: {{ pillar['openstack']['admin_password'] }}
      service_password: {{ pillar['openstack']['service_password']}}
      service_token: {{ pillar['openstack']['admin_token'] }}
      database_password: {{ pillar['openstack']['database_password'] }}
      keystone_host: {{ pillar['openstack']['keystone_host'] }}
      glance_host: {{ pillar['openstack']['glance_host'] }}
      nova_host: {{ pillar['openstack']['openstack_public_address'] }}
      nova_network_private_interface: {{ pillar['openstack']['nova_network_private_interface'] }}
      rabbit_host: {{ pillar['openstack']['rabbit_host'] }}
      rabbit_password: {{ pillar['openstack']['rabbit_password'] }}
      nova_network_public_interface: {{ pillar['openstack']['nova_network_public_interface'] }}
      fixed_range: {{ pillar['openstack']['nova_network_private'] }}
      my_ip: {{ pillar['openstack']['openstack_internal_address'] }}
      nova_libvirt_type: {{ pillar['openstack']['nova_libvirt_type'] }}
      nova_compute_driver: {{ pillar['openstack']['nova_compute_driver'] }}
      nova_network_private: {{ pillar['openstack']['nova_network_private'] }}
      nova_node_availability_zone: {{ pillar['openstack']['nova_node_availability_zone'] }}
      quantum_host: {{ pillar['openstack']['database_host'] }}
      s3_host: {{ pillar['openstack']['database_host'] }}
      ec2_host: {{ pillar['openstack']['database_host'] }}
      ec2_dmz_host: {{ pillar['openstack']['database_host'] }}
      ec2_url: {{ pillar['openstack']['database_host'] }}
      cc_host: {{ pillar['openstack']['database_host'] }}
      database_host: {{ pillar['openstack']['database_host'] }}
      fixed_net_gw: {{ pillar['openstack']['nova_fixed_net_gw'] }}
      fixed_bridge: {{ pillar['openstack']['nova_fixed_bridge'] }}
