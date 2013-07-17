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
apache2:
  service:
    - running
    - enable: True
    - restart: True
    - require:
      - pkg.installed: dashboard-needs
    - watch:
      - pkg: dashboard-pkgs


dashboard-needs:
  pkg.installed:
    - names:
      - memcached
      - apache2
      - apache2-utils
      - libapache2-mod-wsgi

dashboard-pkgs:
    pkg.installed:
      - names:
        - python-django-horizon
      - require:
        - pkg.installed: dashboard-needs
