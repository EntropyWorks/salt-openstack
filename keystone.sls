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
    - context:
        secrets: {{ pillar['secrets'] }}
        infra: {{ pillar['infra'] }}
        networking: {{ pillar['networking'] }}
        endpoints: {{ pillar['endpoints'] }}
        keystone: {{ pillar['keystone'] }}
        nova: {{ pillar['nova'] }}
