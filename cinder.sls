include:
  - openstack.root-scripts

cinder-pkgs:
  pkg.installed:
    - fromreo: private-openstack-repo
    - names:
      - cinder-api
      - cinder-common
      - cinder-scheduler
      - cinder-volume
      - iscsitarget 
      - open-iscsi 
      - iscsitarget-dkms
    - require:
      - service.running: mysql
      - pkg.installed: python-mysqldb
      - pkg.installed: rabbitmq-server
      - mysql_database.present: cinder
      - mysql_grants.present: cinder
      - mysql_user.present: cinder
      - cmd.run: cinder-grant-wildcard
      - cmd.run: cinder-grant-localhost
      - cmd.run: cinder-grant-star

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

cinder-setup:
  cmd.run:
    - unless: test -f /etc/setup-done-cinder
    - name: /root/scripts/cinder-setup.sh
    - require:
      - file.recurse: /etc/cinder
      - file.recurse: /root/scripts
      - pkg.installed: cinder-pkgs

/etc/cinder:
  file:
    - recurse
    - source: salt://openstack/cinder
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
