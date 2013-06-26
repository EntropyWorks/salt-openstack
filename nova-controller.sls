include:
  - openstack.mysql
  - openstack.nova-config
  - openstack.root-scripts

nova-pkgs:
  pkg.installed:
    - names:
      - nova-api 
      - nova-common
      - nova-network
      - nova-cert
      - nova-consoleauth 
      - nova-scheduler 
      - nova-novncproxy
      - nova-conductor
      - nova-network
      - dnsmasq
      - dnsmasq-base
      - dnsmasq-utils  
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
      - nova-conductor
      - nova-consoleauth
      - nova-network
      - nova-novncproxy
      - nova-scheduler
    - require:
      - pkg.installed: nova-pkgs
    - watch:
      - file: /etc/nova

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

