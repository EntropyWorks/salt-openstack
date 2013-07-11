include:
  - openstack.mysql
  - openstack.keystone
  - openstack.nova-controller
  - openstack.glance
  - openstack.cinder
  - openstack.dashboard
  - openstack.root-scripts

debconf-utils:
  pkg.installed

python-eventlet:
  pkg.installed

python-mysqldb:
  pkg.installed

rabbitmq-server:
 pkg.installed

ubuntu-cloud-keyring:
  pkg.installed

