include:
  - openstack.mysql
  - openstack.root-scripts

keystone-pkgs:
  pkg:
    - name: keystone
    - installed
    - require:
      - service.running: mysql
      - mysql_database.present: keystone
      - mysql_grants.present: keystone
      - mysql_user.present: keystone
      - cmd.run: keystone-grant-wildcard
      - cmd.run: keystone-grant-localhost
      - cmd.run: keystone-grant-star
  service:
    - name: keystone
    - running
    - enable: True
    - restart: True
    - require:
      - service.running: mysql
    - watch:
      - file: /etc/keystone

keystone-setup:
  cmd.run:
    - unless: test -f /etc/setup-done-keystone
    - name: /root/scripts/keystone-setup.sh
    - require:
      - service.running: mysql
      - pkg.installed: keystone
      - file.recurse: /etc/keystone
      - file.recurse: /root/scripts
      - service.restart: keystone

/etc/keystone:
  file:
    - recurse
    - source: salt://openstack/keystone
    - template: jinja
    - watch:
      - pkg.installed: keystone
    - context:
        secrets: {{ pillar['secrets'] }}
        infra: {{ pillar['infra'] }}
        networking: {{ pillar['networking'] }}
        endpoints: {{ pillar['endpoints'] }}
        keystone: {{ pillar['keystone'] }}
        nova: {{ pillar['nova'] }}
