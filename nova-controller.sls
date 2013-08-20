# Copyright 2012-2013 Hewlett-Packard Development Company, L.P.
# All Rights Reserved.
# Copyright 2013 Yazz D. Atlas <yazz.atlas@hp.com>
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
#---------------------------
# Currently this setup is for simple 1 AZ deploy with one DB.
# The mysql parts should be removed if you already have a running
# DB on a different host than the controller.
#---------------------------
include:
  - openstack.mysql
  - openstack.keystone
  - openstack.glance
  - openstack.cinder
  - openstack.dashboard
  - openstack.nova-config
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

nova-driver-pkg:
  pkg.installed:
      - python-nova-network-drivers

nova-pkgs:
  pkg.installed:
    - names:
      - python-nova-network-drivers
      - nova-api
      - nova-common
      - nova-cert
      - nova-consoleauth
      - nova-scheduler
      - nova-novncproxy
      - nova-conductor
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
      - pkg: nova-driver-pkg

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
