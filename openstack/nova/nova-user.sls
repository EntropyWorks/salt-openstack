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
nova:
  group.present:
    - name: nova
    - system: True
  user.present:
    - fullname: Nova OpenStack User
    - shell: /bin/bash
    - home: /var/lib/nova
    - system: True
    - gid_from_name: True
    - require:
      - group: nova

nova_ssh_private_key:
  file.managed:
    - name: /var/lib/nova/.ssh/id_rsa
    - source: salt://openstack/dependency/templates/id_rsa.jinja
    - template: jinja
    - mode: 600
    - user: nova
    - group: nova
    - require:
        - user: nova
        - group: nova

nova_ssh_authorized_keys:
  file.managed:
    - name: /var/lib/nova/.ssh/authorized_keys
    - source: salt://openstack/dependency/templates/authorized_keys.jinja
    - template: jinja
    - mode: 600
    - user: nova
    - group: nova
    - require:
        - user: nova
        - group: nova

nova_ssh_fix_perm:
  file.directory:
    - name: /var/lib/nova/.ssh
    - mode: 700
    - user: nova
    - group: nova
    - require:
      - user: nova
      - group: nova

nova_run_openstack:
  file.directory:
    - name: /var/run/openstack
    - mode: 700
    - user: nova
    - group: nova
    - require:
      - user: nova
      - group: nova

nova_ssh_config:
  file.managed:
    - name: /var/lib/nova/.ssh/config
    - source: salt://openstack/dependency/templates/ssh_config.jinja
    - template: jinja
    - mode: 644
    - user: nova
    - group: nova
    - require:
      - user: nova
      - group: nova
