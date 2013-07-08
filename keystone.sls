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
    - defaults:
        openstack_internal_address: {{ pillar['openstack']['openstack_internal_address'] }}
        openstack_public_address: {{ pillar['openstack']['openstack_public_address'] }}
        admin_password: {{ pillar['openstack']['admin_password'] }}
        service_password: {{ pillar['openstack']['service_password']}}
        service_token: {{ pillar['openstack']['admin_token'] }}
        admin_token: {{ pillar['openstack']['admin_token'] }}
        database_password: {{ pillar['openstack']['database_password'] }}
        database_host: {{ pillar['openstack']['database_host'] }}
        nova_node_availability_zone: {{ pillar['openstack']['nova_node_availability_zone'] }}
        openstack_ssl_cert: {{ pillar['openstack']['openstack_ssl_cert'] }}
        openstack_ssl_key: {{ pillar['openstack']['openstack_ssl_key'] }}

#      - file.managed: keystone_ssl_key
#      - file.managed: keystone_ssl_crt
#
#keystone_ssl_key:
#  file.managed:
#    - name: /etc/keystone/ssl/private/paas-deploy-ssl.key
#    - source: salt://openstack/templates/paas-deploy-ssl.key.jinja
#    - template: jinja
#    - mode: 400
#    - user: keystone 
#    - group: keystone 
#    - require:
#      - user: keystone 
#      - group: keystone 
#      - file: /etc/keystone
#
#keystone_ssl_crt:
#  file.managed:
#    - name: /etc/keystone/ssl/certs/paas-deploy-ssl.crt
#    - source: salt://openstack/templates/paas-deploy-ssl.crt.jinja
#    - template: jinja
#    - mode: 644
#    - user: keystone 
#    - service.restart: keystone
#    - group: keystone 
#    - require:
#      - user: keystone 
#      - group: keystone 
#      - file: /etc/keystone
