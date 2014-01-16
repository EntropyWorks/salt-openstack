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
include:
  - openstack.root-scripts
  - openstack.memcached

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
    - source: salt://openstack/cinder/cinder-cfg
    - template: jinja
    - defaults:
    - context:
        secrets: {{ pillar['secrets'] }}
        cinder: {{ pillar['cinder'] }}
        keystone: {{ pillar['keystone'] }}
        nova: {{ pillar['nova'] }}
        endpoints: {{ pillar['endpoints'] }}
