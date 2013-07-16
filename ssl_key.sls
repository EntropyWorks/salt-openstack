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
keystone_ssl_key:
  file.managed:
    - name: /etc/keystone/ssl/private/paas-deploy-ssl.key
    - source: salt://openstack/templates/paas-deploy-ssl.key.jinja
    - template: jinja
    - mode: 400
    - user: keystone 
    - group: keystone 
    - require:
        - user: keystone 
        - group: keystone 
