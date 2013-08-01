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
  - openstack.nova-config
  - openstack.nova-user
#- openstack.root-scripts

nova-driver-pkg:
  pkg.installed:
      - name: python-nova-network-drivers

nova-pkgs:
  pkg.installed:
    - names:
      - nova-common
      - nova-compute
      - nova-network
      - nova-api-metadata
      - nova-novncproxy
      - dnsmasq
      - dnsmasq-base
      - dnsmasq-utils
    - require:
      - pkg: nova-driver-pkg
  
nova-services:
  service:
    - running
    - enable: True
    - restart: True
    - names:
      - nova-compute
      - nova-network
      - nova-api-metadata
    - require:
      - pkg.installed: nova-pkgs
      - pkg: nova-driver-pkg
    - watch:
      - file: /etc/nova

/var/lib/nova/instances/_base/ephemeral:
  file.managed:
    - user: nova
    - group: nova
    - require:
      - user: nova
      - group: nova
      - pkg.installed: nova-pkgs
