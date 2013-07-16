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
# Only add this if you want to override where your getting the openstack
# packages

ubuntu-cloud-keyring:
  pkg.installed

# name: "deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/grizzly main"
{% for mirror in pillar['infra']['mirror'].iteritems() }} %}
{{ mirror_name }}:
  pkgrepo.managed:
    - name: "{{ pillar['infra']['mirror']['{{ mirror_name }}']['url'] }}"
    - human_name: {{ pillar['infra']['mirror']['{{ mirror_name }}']['human_name'] }}
    - file: {{ pillar['infra']['mirror']['{{ mirror_name }}']['file'] }}
    - keyid: {{ pillar['infra']['mirror']['{{ mirror_name }}']['keyid'] }}
    - keyserver: keyserver.ubuntu.com
    - required:
      - pkg.installed: ubuntu-cloud-keyring
    - require_in:
      - pkg.installed: ubuntu-cloud-keyring
      - pkg.installed: nova-pkgs
      - pkg.installed: glance-pkgs
      - pkg.installed: cinder-pkgs
      - pkg.installed: dashboard-pkgs
      - pkg.installed: keystone-pkgs
{% endfor %}
