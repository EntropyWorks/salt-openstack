# Copyright 2012-2013 Hewlett-Packard Development Company, L.P.
# All Rights Reserved.
# Copyright 2013 Nikhil Manchanda <nikhil.manchanda@hp.com>
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

keystone-pkgs:
  pkg.installed:
    - names:
      - keystone
    - require:
      - pkg.installed: apache2
      - pkg.installed: apache2-mod-wsgi
      - pkg.installed: apache2-mod-ssl
      - file.directory: /var/www/cgi-bin/keystone
      - file.recurse: /etc/apache2
  file.symlink:
    - source: /etc/apache2/keystone.py
    - target: /var/www/cgi-bin/keystone/main
    - require:
      - file.directory: /var/www/cgi-bin/keystone
  file.symlink:
    - source: /etc/apache2/keystone.py
    - target: /var/www/cgi-bin/keystone/admin
    - require:
      - file.directory: /var/www/cgi-bin/keystone

keystone-services:
  service:
    - running
    - enable: True
    - restart: True
    - name: apache2
    - watch:
      - file: /etc/keystone
      - file: /etc/apache2
    - require:
      - pkg.installed: keystone-pkgs
      - cmd.run: a2ensite keystone

/var/www/cgi-bin/keystone:
  file.directory:
    - makedirs: True

/etc/apache2:
  file:
    - recurse
    - source: salt://openstack/apache2
    - template: jinja
    - watch:
      - pkg.installed: apache2
    - context:
        keystone: {{ pillar['keystone'] }}

/etc/keystone:
  file:
    - recurse
    - source: salt://openstack/keystone
    - template: jinja
    - watch:
      - pkg.installed: keystone
    - context:
        infra: {{ pillar['infra'] }}
        secrets: {{ pillar['secrets'] }}
        networking: {{ pillar['networking'] }}
        endpoints: {{ pillar['endpoints'] }}
        keystone: {{ pillar['keystone'] }}
        nova: {{ pillar['nova'] }}
        glance: {{ pillar['glance'] }}
        cinder: {{ pillar['cinder'] }}
        rabbit: {{ pillar['rabbit'] }}
        swift: {{ pillar['swift'] }}
        quantum: {{ pillar['quantum'] }}
