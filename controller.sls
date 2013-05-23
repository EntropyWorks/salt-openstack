include:
  - openstack.repo
  - openstack.nova-controller
  - openstack.glance
  - openstack.keystone
  - openstack.cinder
  - openstack.dashboard

python-eventlet:
  pkg.installed

mysql-server:
  pkg.installed

python-mysqldb:
  pkg.installed

rabbitmq-server:
 pkg.installed

mysql:
  service:
    - running
  require:
    - pkg.installed: mysql-server

rabbitmq:
  service:
    - running
  require:
    - pkg.installed: rabbitmq-server

sed-mysql-conf:
  file.sed:
    - name: /etc/mysql/my.cnf
    - before: '127.0.0.1'
    - after: '0.0.0.0'
    - limit: '^bind-address'
  service:
    - restart
  require:
    - service: mysql

openstack-pkgs:
  pkg.installed:
    - fromreo: private-openstack-repo
    - require:
      - pkg.installed: mysql-server
      - pkg.installed: python-mysqldb
      - pkg.installed: rabbitmq-server
    - names:
      - keystone
      - nova-api
      - nova-cert
      - nova-common
      - nova-network
      - nova-scheduler
      - nova-console
      - nova-consoleauth
      - glance
      - glance-api
      - glance-common
      - glance-registry
      - cinder-api
      - cinder-common
      - cinder-scheduler
      - cinder-volume

/root/scripts:
  file:
    - recurse
    - source: salt://openstack/bin
    - file_mode: 755
    - template: jinja
    - defaults:
        openstack_internal_address: {{ pillar['openstack']['openstack_internal_address'] }}
        openstack_public_address: {{ pillar['openstack']['openstack_public_address'] }}
        admin_password: {{ pillar['openstack']['admin_password'] }} 
        service_password: {{ pillar['openstack']['service_password']}} 
        service_token: {{ pillar['openstack']['admin_token'] }}
        database_password: {{ pillar['openstack']['database_password'] }}
        database_host: {{ pillar['openstack']['database_host'] }}

