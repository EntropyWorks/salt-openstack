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

apache2:
  pkg.installed:
    - name: apache2
  service.running:
    - enable: true
    - restart: True
    - watch:
      - file: /etc/apache2/apache2.conf
      - file: /etc/apache2/ports.conf
      - file: /etc/apache2/sites-enabled/*

apache2-mod-wsgi:
  pkg.installed:
    - name: libapache2-mod-wsgi
  cmd.run:
    - name: a2enmod wsgi
  require:
    - pkg: apache2

apache2-mod-ssl:
  pkg.installed:
    - name: libapache2-mod-ssl
  cmd.run:
    - name: a2enmod ssl
  require:
    - pkg: apache2
