include:
  - openstack.root-scripts

cinder-pkgs:
  pkg.installed:
    - names:
      - cinder-api
      - cinder-common
      - cinder-scheduler
      - cinder-volume
      - open-iscsi 
      - iscsitarget
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
    - context:
        secrets: {{ pillar['secrets'] }}
        cinder: {{ pillar['cinder'] }}
        keystone: {{ pillar['keystone'] }}
        nova: {{ pillar['nova'] }}
        endpoints: {{ pillar['endpoints'] }}
