include:
  - openstack.repo
  - openstack.nova-compute

python-eventlet:
  pkg.installed

python-mysqldb:
  pkg.installed

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
