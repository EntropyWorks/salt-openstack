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
      - service.running: mysql
      - pkg.installed: python-mysqldb
      - pkg.installed: rabbitmq-server
      - mysql_database.present: nova
      - mysql_grants.present: nova
      - mysql_user.present: nova
      - cmd.run: nova-grant-wildcard
      - cmd.run: nova-grant-localhost
      - cmd.run: nova-grant-star

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

#- source: salt://openstack/scripts/nova-setup.sh
#- template: jinja
nova-setup:
  cmd:
    - run
    - name: /root/scripts/nova-setup.sh
    - unless: test -f /etc/setup-done-nova
    - require:
      - service.running: mysql
      - file.recurse: /root/scripts
      - file.recurse: /etc/nova
      - pkg.installed: nova-pkgs

/etc/nova:
  file:
    - recurse
    - source: salt://openstack/nova
    - template: jinja
    - required:
      - pkg.installed: nova-pkgs
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

