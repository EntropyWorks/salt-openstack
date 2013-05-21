keystone-db-init:
  cmd:
    - run
    - name: /root/scripts/create-db.sh keystone keystone {{ pillar['openstack']['database_password'] }}
    - unless: echo '' | mysql keystone
    - require:
      - file.recurse: /root/scripts
      - pkg.installed: keystone
      - service.running: mysql

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
