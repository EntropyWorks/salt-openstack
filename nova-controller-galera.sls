debconf-utils:
  pkg.installed

python-eventlet:
  pkg.installed

python-mysqldb:
  pkg.installed

rabbitmq-server:
 pkg.installed

ubuntu-cloud-keyring:
  pkg.installed

nova-pkgs:
  pkg.installed:
    - names:
      - nova-api
      - nova-common
      - nova-network
      - nova-cert
      - nova-consoleauth
      - nova-scheduler
      - nova-novncproxy
      - nova-conductor
      - nova-network
      - dnsmasq
      - dnsmasq-base
      - dnsmasq-utils
    - require:
      - pkg.installed: python-mysqldb

nova-services:
  service:
    - running
    - enable: True
    - restart: True
    - names:
      - nova-api
      - nova-cert
      - nova-conductor
      - nova-consoleauth
      - nova-network
      - nova-novncproxy
      - nova-scheduler
    - require:
      - pkg.installed: nova-pkgs
    - watch:
      - file: /etc/nova

keystone-pkgs:
  pkg:
    - name: keystone
    - installed
  service:
    - name: keystone
    - running
    - enable: True
    - restart: True
    - watch:
      - file: /etc/keystone

/etc/keystone:
  file:
    - recurse
    - source: salt://openstack/keystone
    - template: jinja
    - watch:
      - pkg.installed: keystone
    - defaults:
        openstack_internal_address: {{ pillar['openstack']['openstack_internal_address'] }}
        openstack_public_address: {{ pillar['openstack']['openstack_public_address'] }}
        admin_password: {{ pillar['openstack']['admin_password'] }}
        service_password: {{ pillar['openstack']['service_password']}}
        service_token: {{ pillar['openstack']['admin_token'] }}
        admin_token: {{ pillar['openstack']['admin_token'] }}
        database_password: {{ pillar['openstack']['database_password'] }}
        database_host: {{ pillar['openstack']['database_host'] }}
        nova_node_availability_zone: {{ pillar['openstack']['nova_node_availability_zone'] }}


glance-pkgs:
  pkg.installed:
    - names:
      - glance
      - glance-api
      - glance-common
      - glance-registry
      - python-glanceclient
    - require:
      - pkg.installed: python-mysqldb


glance-services:
  service:
    - running
    - enable: True
    - names:
      - glance-api
      - glance-registry
    - require:
      - pkg.installed: glance-pkgs
    - watch:
      - file.recurse: /etc/glance


/etc/glance:
  file:
    - recurse
    - source: salt://openstack/glance
    - template: jinja
    - require:
      - pkg.installed: glance-pkgs
      - file.recurse: /root/scripts
    - defaults:
        openstack_internal_address: {{ pillar['openstack']['openstack_internal_address'] }}
        openstack_admin_address: {{ pillar['openstack']['openstack_admin_address'] }}
        openstack_public_address: {{ pillar['openstack']['openstack_public_address'] }}
        admin_password: {{ pillar['openstack']['admin_password'] }}
        service_password: {{ pillar['openstack']['service_password']}}
        service_token: {{ pillar['openstack']['admin_token'] }}
        database_password: {{ pillar['openstack']['database_password'] }}
        keystone_host: {{ pillar['openstack']['keystone_host'] }}
        keystone_auth_port: {{ pillar['openstack']['keystone_auth_port'] }}
        keystone_auth_protocol: {{ pillar['openstack']['keystone_auth_protocol'] }}
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
        quantum_host: {{ pillar['openstack']['openstack_internal_address'] }}
        s3_host: {{ pillar['openstack']['openstack_internal_address'] }}
        ec2_host: {{ pillar['openstack']['openstack_internal_address'] }}
        ec2_dmz_host: {{ pillar['openstack']['openstack_internal_address'] }}
        ec2_url: {{ pillar['openstack']['openstack_internal_address'] }}
        cc_host: {{ pillar['openstack']['openstack_internal_address'] }}
        database_host: {{ pillar['openstack']['database_host'] }}


cinder-pkgs:
  pkg.installed:
    - names:
      - cinder-api
      - cinder-common
      - cinder-scheduler
      - cinder-volume
      - open-iscsi 
      - iscsitarget
      - iscsitarget-dkms
    - require:
      - pkg.installed: python-mysqldb

cinder-services:
  service:
    - running
    - enable: True
    - restart: True
    - names:
      - cinder-api
      - cinder-scheduler
      - cinder-volume
    - require:
      - pkg.installed: cinder-pkgs
    - watch:
      - file: /etc/cinder

/etc/cinder:
  file:
    - recurse
    - source: salt://openstack/cinder
    - template: jinja
    - defaults:
        cinder_host: {{ pillar['openstack']['cinder_host'] }}
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
        quantum_host: {{ pillar['openstack']['openstack_internal_address'] }}
        s3_host: {{ pillar['openstack']['openstack_internal_address'] }}
        ec2_host: {{ pillar['openstack']['openstack_internal_address'] }}
        ec2_dmz_host: {{ pillar['openstack']['openstack_internal_address'] }}
        ec2_url: {{ pillar['openstack']['openstack_internal_address'] }}
        cc_host: {{ pillar['openstack']['openstack_internal_address'] }}
        database_host: {{ pillar['openstack']['database_host'] }}


/root/scripts:
  file:
    - recurse
    - source: salt://openstack/bin
    - file_mode: 755
    - template: jinja
    - defaults:
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
      quantum_host: {{ pillar['openstack']['openstack_internal_address'] }}
      s3_host: {{ pillar['openstack']['openstack_internal_address'] }}
      ec2_host: {{ pillar['openstack']['openstack_internal_address'] }}
      ec2_dmz_host: {{ pillar['openstack']['openstack_internal_address'] }}
      ec2_url: {{ pillar['openstack']['openstack_internal_address'] }}
      cc_host: {{ pillar['openstack']['openstack_internal_address'] }}
      database_host: {{ pillar['openstack']['database_host'] }}
      fixed_net_gw: {{ pillar['openstack']['nova_fixed_net_gw'] }}
      fixed_bridge: {{ pillar['openstack']['nova_fixed_bridge'] }}

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
        quantum_host: {{ pillar['openstack']['openstack_internal_address'] }}
        s3_host: {{ pillar['openstack']['openstack_internal_address'] }}
        ec2_host: {{ pillar['openstack']['openstack_internal_address'] }}
        ec2_dmz_host: {{ pillar['openstack']['openstack_internal_address'] }}
        ec2_url: {{ pillar['openstack']['openstack_internal_address'] }}
        cc_host: {{ pillar['openstack']['openstack_internal_address'] }}
        database_host: {{ pillar['openstack']['database_host'] }}
        nova_dhcpbridge: {{ pillar['openstack']['nova_dhcpbridge'] }}

