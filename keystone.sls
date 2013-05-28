include:
  - openstack.mysql
  - openstack.repo

keystone-pkg:
  pkg:
    - name: keystone
    - installed
    - fromreo: private-openstack-repo
  service:
    - name: keystone
    - running
    - enable: True
    - restart: True
    - require:
      - service.running: mysql
      - mysql_database.present: keystone
      - cmd.run: keystone-grant
      - file: /etc/keystone
    - watch:
      - cmd.run: keystone-db-sync

keystone-db-sync:
  cmd.run:
    - name: keystone-manage --config-file /etc/keystone/keystone.conf db_sync
    - require:
      - pkg.installed: keystone
      - mysql_database.present: keystone
      - cmd.run: keystone-grant
    - watch:
      - file: /etc/keystone

keystone-basic:
  cmd.run:
    - name: /root/scripts/keystone_basic.sh
    - require:
      - file: /etc/keystone
      - pkg.installed: keystone
      - mysql_database.present: keystone
      - cmd.run: keystone-grant
      - cmd.run: keystone-db-sync

keystone-endpoints:
  cmd.run:
    - name: /root/scripts/keystone_endpoints_basic.sh
    - require:
      - file: /etc/keystone
      - pkg.installed: keystone
      - mysql_database.present: keystone
      - cmd.run: keystone-grant
      - cmd.run: keystone-db-sync
      - cmd.run: keystone-basic

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
