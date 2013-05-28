include:
  - openstack.repo

glance-pkgs:
  pkg.installed:
    - fromreo: private-openstack-repo
    - names:
      - glance
      - glance-api
      - glance-common
      - glance-registry
    - require:
      - pkg.installed: mysql-server
      - pkg.installed: python-mysqldb
      - pkg.installed: rabbitmq-server

glance-db-sync:
  cmd:
    - run
    - name: glance-manage --config-dir=/etc/glance db_sync
    - require:
      - file.recurse: /etc/glance
      - pkg.installed: mysql-server
      - pkg.installed: glance-common
      - mysql_database.present: glance
      - cmd.run: glance-grant
    - watch:
      - service: glance-services

glance-services:
  service:
    - running
    - enable: True
    - names:
      - glance-api
      - glance-registry
    - require:
      - pkg.installed: glance-api
      - pkg.installed: glance-registry
      - mysql_database.present: glance
      - cmd.run: glance-grant
    - watch:
      - file.recurse: /etc/glance

glance-images:
  cmd.script:
    - source: salt://openstack/scripts/init-glance
    - template: jinja
    - name: init-glance
  require:
    - cmd.run: glance-grant
    - service: glance-services
    - cmd.run: glance-db-sync
    - service.running: glance-services
    

/etc/glance:
  file:
    - recurse
    - source: salt://openstack/glance
    - template: jinja
    - require:
      - pkg.installed: glance-common
    - defaults:
        openstack_internal_address: {{ pillar['openstack']['openstack_internal_address'] }}
        openstack_admin_address: {{ pillar['openstack']['openstack_admin_address'] }}
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
