include:
  - openstack.mysql
  - openstack.root-scripts

glance-pkgs:
  pkg.installed:
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
    - context:
	secrets: {{ pillar['secrets'] }}
        cinder: {{ pillar['cinder'] }}
        glance: {{ pillar['glance'] }}
        keystone: {{ pillar['keystone'] }}
        nova: {{ pillar['nova'] }}
        endpoints: {{ pillar['endpoints'] }}
