# Copyright 2012-2013 Hewlett-Packard Development Company, L.P.
# All Rights Reserved.
# Copyright 2013 Patrick Galbraith <patg@hp.com> 
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
glance-pkgs:
  pkg.installed:
    - names:
      - glance
      - glance-api
      - glance-common
      - glance-registry
      - python-glanceclient
    - require:
      - pkg.installed: python-mysqldb

glance-services:
  service:
    - running
    - enable: True
    - names:
      - glance-api
      - glance-registry
    - require:
      - pkg.installed: glance-pkgs
    - watch:
      - file.recurse: /etc/glance


/etc/glance:
  file:
    - recurse
    - source: salt://openstack/glance
    - template: jinja
    - require:
      - pkg.installed: glance-pkgs
      - file.recurse: /root/scripts
    - context:
        secrets: {{ pillar['secrets'] }}
        infra: {{ pillar['infra'] }}
        networking: {{ pillar['networking'] }}
        endpoints: {{ pillar['endpoints'] }}
        keystone: {{ pillar['keystone'] }}
        nova: {{ pillar['nova'] }}
        glance: {{ pillar['glance'] }}
        cinder: {{ pillar['cinder'] }}
        rabbit: {{ pillar['rabbit'] }}
        swift: {{ pillar['swift'] }}
        quantum: {{ pillar['quantum'] }}
