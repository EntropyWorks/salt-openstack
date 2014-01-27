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
haproxy:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - restart: True
    - require:
      - pkg.installed: haproxy
    - watch:
      - file: /etc/haproxy

/etc/default/haproxy:
  file.sed:
    - before: 0
    - after: 1
    - limit: ^ENABLED=
    - require:
      - pkg.installed: haproxy


/var/lib/haproxy:
  file.directory:
    - user: haproxy
    - group: haproxy
    - mode: 755
    - makedirs: True
    - require:
      - pkg.installed: haproxy

/etc/haproxy:
  file:
    - recurse
    - source: salt://openstack/dependancy/haproxy
    - template: jinja
    - context:
        infra: {{ pillar['infra'] }}
        networking: {{ pillar['networking'] }}
        endpoints: {{ pillar['endpoints'] }}
    - require:
      - file.directory: /var/lib/haproxy
