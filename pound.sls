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
pound:
  pkg:
    - installed
    - name: pound
  service:
    - running
    - restart: True
    - enabled: True
    - require:
      - pkg: pound
      - pkg: openssl 
      - file: /etc/pound/pound.pem
      - file: /etc/pound/pound.cfg

openssl:
  pkg:
    - installed
    - name: openssl


/etc/pound/pound.cfg:
  file.managed:
    - source: salt://pound/pound.cfg
    - template: jinja
    - mode: 644
    - user: root
    - group: root

/etc/default/pound:
  file.managed:
    - source: salt://pound/pound
    - template: jinja
    - mode: 644
    - user: root
    - group: root

/etc/pound/pound.pem:
  file.managed:
    - source: salt://pound/pound.pem
    - template: jinja
    - mode: 644
    - user: root
    - group: root
