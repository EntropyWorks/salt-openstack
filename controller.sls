include:
  - openstack.repo

python-eventlet:
  pkg.installed

mysql-server:
  pkg.installed

python-mysqldb:
  pkg.installed

rabbitmq-server:
 pkg.installed

mysql:
  service:
    - running
  require:
    - pkg.installed: mysql-server

rabbitmq:
  service:
    - running
  require:
    - pkg.installed: rabbitmq-server

sed-mysql-conf:
  file.sed:
    - name: /etc/mysql/my.cnf
    - before: 127.0.01
    - after: 0.0.0.0
    - limit: ^bind-address\s?\*=
  service:
    - restart
  require:
    - service: mysql

openstack-pkgs:
  pkg.installed:
    - fromreo: private-openstack-repo
    - require:
      - pkg.installed: mysql-server
      - pkg.installed: python-mysqldb
      - pkg.installed: rabbitmq-server
    - names:
      - keystone
      - nova-api
      - nova-cert
      - nova-common
      - nova-network
      - nova-scheduler
      - nova-console
      - nova-consoleauth
      - glance
      - glance-api
      - glance-common
      - glance-registry
      - cinder-api
      - cinder-common
      - cinder-scheduler
      - cinder-volume
      - python-django-horizon

nova-support:
  service:
    - running
    - enable: True
    - names:
      - mysql
      - rabbitmq


/root/scripts:
  file:
    - recurse
    - source: salt://openstack/scripts
    - file_mode: 755
    - template: jinja
    - defaults:
        openstack_internal_address: {{ pillar['openstack']['openstack_internal_address'] }}
        openstack_public_address: {{ pillar['openstack']['openstack_public_address'] }}
        admin_password: {{ pillar['openstack']['admin_password'] }} 
        service_password: {{ pillar['openstack']['service_password']}} 
        service_token: {{ pillar['openstack']['admin_token'] }}
        database_password: {{ pillar['openstack']['database_password'] }}
        database_host: {{ pillar['openstack']['database_host'] }}

keystone-db-init:
  cmd:
    - run
    - name: /root/scripts/create-db.sh keystone keystone {{ pillar['openstack']['database_password'] }}
    - unless: echo '' | mysql keystone
    - require:
      - file.recurse: /root/scripts
      - pkg.installed: keystone
      - service.running: mysql

nova-db-init:
  cmd:
    - run
    - name: /root/scripts/create-db.sh nova nova {{ pillar['openstack']['database_password'] }}
    - unless: echo '' | mysql nova
    - require:
      - file.recurse: /root/scripts
      - pkg.installed: nova-api
      - service.running: mysql

glance-db-init:
  cmd:
    - run
    - name: /root/scripts/create-db.sh glance glance {{ pillar['openstack']['database_password'] }}
    - unless: echo '' | mysql glance
    - require:
      - file.recurse: /root/scripts
      - pkg.installed: glance-api
      - pkg.installed: glance-registry
      - service.running: mysql

cinder-db-init:
  cmd:
    - run
    - name: /root/scripts/create-db.sh cinder cinder {{ pillar['openstack']['database_password'] }}
    - unless: echo '' | mysql cinder
    - require:
      - file.recurse: /root/scripts
      - pkg.installed: cinder-volume
      - pkg.installed: cinder-api
      - pkg.installed: cinder-scheduler
      - service.running: mysql


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
      - cmd.run: glance-db-init

nova-services:
  service:
    - running
    - enable: True
    - names:
      - nova-api
      - nova-scheduler
      - nova-cert
    - require:
      - cmd.run: nova-db-init
      - cmd.run: keystone-db-init
      - service.running: glance-api

nova-db-sync:
  cmd:
    - run
    - name: nova-manage db sync
    - require:
      - pkg.installed: nova-api
      - pkg.installed: nova-scheduler
      - pkg.installed: nova-cert
      - pkg.installed: nova-network
      - pkg.installed: mysql-server
    - watch_in:
      - service.running: nova-services


nova-add-private-network:
  cmd:
    - run
    - name: "nova-manage network create --label internal \
      --dns1 8.8.8.8 --dns2 8.8.4.4 \
      --fixed_range_v4 {{pillar['openstack']['nova_network_private']}} \
      --num_networks {{pillar['openstack']['nova_network_private_num']}} \
      --network_size {{pillar['openstack']['nova_network_private_size']}} --multi_host=T"
    - unless: nova-manage network list | grep -q "{{pillar['openstack']['nova_network_private']}}"
    - require:
      - pkg.installed: nova-api
      - pkg.installed: nova-scheduler
      - pkg.installed: nova-cert
      - pkg.installed: nova-network
      - pkg.installed: mysql-server


#- watch_in:
#- service.running: nova-services

keystone:
  service:
    - running
    - enable: True
    - require:
      - pkg.installed: keystone
      - pkg.installed: mysql-server
    - watch:
      - cmd.run: keystone-db-init

keystone-db-sync:
  cmd:
    - run
    - name: keystone-manage db_sync
    - require:
      - pkg.installed: keystone
    - watch_in:
      - service.running: keystone


httpd:
  service:
    - running
    - enable: True
    - require:
      - pkg.installed: python-django-horizon

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

/etc/keystone:
  file:
    - recurse
    - source: salt://openstack/keystone
    - template: jinja
    - defaults:
        openstack_internal_address: {{ pillar['openstack']['openstack_internal_address'] }}
        openstack_public_address: {{ pillar['openstack']['openstack_public_address'] }}
        admin_password: {{ pillar['openstack']['admin_password'] }} 
        service_password: {{ pillar['openstack']['service_password']}} 
        service_token: {{ pillar['openstack']['admin_token'] }}
        admin_token: {{ pillar['openstack']['admin_token'] }}
        database_password: {{ pillar['openstack']['database_password'] }}
        database_host: {{ pillar['openstack']['database_host'] }}

/etc/glance:
  file:
    - recurse
    - source: salt://openstack/glance
    - defaults:
        openstack_internal_address: {{ pillar['openstack']['openstack_internal_address'] }}
        openstack_public_address: {{ pillar['openstack']['openstack_public_address'] }}
        admin_password: {{ pillar['openstack']['admin_password'] }} 
        service_password: {{ pillar['openstack']['service_password']}} 
        service_token: {{ pillar['openstack']['admin_token'] }}
        database_password: {{ pillar['openstack']['database_password'] }}
        database_host: {{ pillar['openstack']['database_host'] }}


