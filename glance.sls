include:
  - openstack.mysql
  - openstack.root-scripts

glance-pkgs:
  pkg.installed:
    - fromreo: private-openstack-repo
    - names:
      - glance
      - glance-api
      - glance-common
      - glance-registry
      - python-glanceclient
    - require:
      - service.running: mysql
      - pkg.installed: python-mysqldb
      - pkg.installed: rabbitmq-server
      - mysql_database.present: glance
      - mysql_grants.present: glance
      - mysql_user.present: glance
      - cmd.run: glance-grant-wildcard
      - cmd.run: glance-grant-localhost
      - cmd.run: glance-grant-star


glance-services:
  service:
    - running
    - enable: True
    - names:
      - glance-api
      - glance-registry
    - require:
      - pkg.installed: glance-pkgs
      - service.running: mysql
    - watch:
      - file.recurse: /etc/glance

glance-setup:
  cmd.run:
    - unless: test -f /etc/setup-done-glance
    - name: /root/scripts/glance-setup.sh
    - require:
      - file.recurse: /etc/glance
      - service.running: mysql
      - pkg.installed: glance-pkgs
    
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

#glance-db-sync:
#  cmd:
#    - run
#    - name: glance-manage --config-dir=/etc/glance db_sync
#    - require:
#      - file.recurse: /etc/glance
#      - pkg.installed: glance-pkgs
#      - mysql_database.present: glance
#      - cmd.run: glance-grant
#    - watch:
#      - service: glance-services
