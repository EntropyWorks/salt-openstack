include:
  - openstack.repo
  - openstack.mysql
  - openstack.keystone
  - openstack.nova-controller
  - openstack.glance
  - openstack.cinder
  - openstack.dashboard

python-eventlet:
  pkg.installed

python-mysqldb:
  pkg.installed

rabbitmq-server:
 pkg.installed

mysql:
  pkg:
    - installed
    - name: mysql-server
  file.sed:
    - name: /etc/mysql/my.cnf
    - before: '127.0.0.1'
    - after: '0.0.0.0'
    - limit: '^bind-address'
    - require:
      - pkg.installed: mysql-server
  service:
    - running
    - restart: True
    - enabled: True
    - require:
      - pkg: mysql-server
    - watch:
      - file.sed: /etc/mysql/my.cnf

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

