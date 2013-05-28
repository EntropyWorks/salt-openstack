include:
  - openstack.repo
  - openstack.mysql

nova-pkgs:
  pkg.installed:
    - fromreo: private-openstack-repo
    - names:
      - nova-api
      - nova-cert
      - nova-common
      - nova-network
      - nova-scheduler
      - nova-console
      - nova-consoleauth
    - require:
      - pkg.installed: mysql-server
      - pkg.installed: python-mysqldb
      - pkg.installed: rabbitmq-server

nova-services:
  service:
    - running
    - enable: True
    - restart: True
    - names:
      - nova-api
      - nova-cert
      - nova-scheduler
      - nova-console
      - nova-consoleauth
      - nova-network
    - require:
      - pkg.installed: nova-pkgs
    - watch:
      - file: /etc/nova

nova-db-sync:
  cmd:
    - run 
    - name: nova-manage --config-dir=/etc/nova db sync
    - require:
      - file.recurse: /etc/nova
      - pkg.installed: mysql-server
      - pkg.installed: nova-common
      - mysql_database.present: nova
      - cmd.run: nova-grant
    - watch:
      - service: nova-services

nova-add-private-network:
  cmd:
    - run
    - name: "nova-manage network create --label internal \
      --dns1 8.8.8.8 --dns2 8.8.4.4 \
      --fixed_range_v4 {{pillar['openstack']['nova_network_private']}} \
      --num_networks {{pillar['openstack']['nova_network_private_num']}} \
      --bridge_interface {{pillar['openstack']['nova_network_bridge_interface']}}
      --network_size {{pillar['openstack']['nova_network_private_size']}} --multi_host=T"
    - unless: nova-manage network list | grep -q "8.8.8.8"
    - require:
      - pkg.installed: mysql-server
      - pkg.installed: nova-common
      - file: /etc/nova
    - watch:
      - cmd.run: nova-db-sync

/etc/nova:
  file:
    - recurse
    - source: salt://openstack/nova
    - template: jinja
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
        quantum_host: {{ pillar['openstack']['database_host'] }}
        s3_host: {{ pillar['openstack']['database_host'] }}
        ec2_host: {{ pillar['openstack']['database_host'] }}
        ec2_dmz_host: {{ pillar['openstack']['database_host'] }}
        ec2_url: {{ pillar['openstack']['database_host'] }}
        cc_host: {{ pillar['openstack']['database_host'] }}
        database_host: {{ pillar['openstack']['database_host'] }}

#nova-add-floating-network:
#  cmd:
#    - run
#    - name: "nova-manage floating create {{ pillar['openstack']['nova_network_floating'] }} --pool=nova"
#    - unless: nova-manage network list | grep -q "nova"
#    - require:
#      - pkg.installed: mysql-server
#      - pkg.installed: nova-common
#      - file: /etc/nova
#    - watch:
#      - cmd.wait: nova-db-sync
