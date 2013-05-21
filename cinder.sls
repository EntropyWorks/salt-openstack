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
