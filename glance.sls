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
    - watch:
      - cmd.run: glance-db-init

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
