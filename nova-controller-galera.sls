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
  - openstack.memcached

debconf-utils:
  pkg.installed

python-eventlet:
  pkg.installed

python-mysqldb:
  pkg.installed

rabbitmq-server:
 pkg.installed

ubuntu-cloud-keyring:
  pkg.installed

# Custom driver for working with nova-network across multiple
# AZ's in Gizzly. The nova config option fixed_range= doesn't work
# anymore.
nova-driver-pkg:
  pkg.installed:
      - name: python-nova-network-drivers

# Custom filter for the nova scheduler to be able to filter based
# on host AZs.
nova-filter-pkg:
  pkg.installed:
      - name: python-nova-scheduler-filters

nova-pkgs:
  pkg.installed:
    - names:
      - python-nova-network-drivers
      - python-nova-scheduler-filters
      - nova-api
      - nova-common
      - nova-cert
      - nova-consoleauth
      - nova-scheduler
      - nova-novncproxy
      - nova-conductor
      - dnsmasq
      - dnsmasq-base
      - dnsmasq-utils
    - require:
      - pkg.installed: python-mysqldb
      - pkg.installed: nova-driver-pkg
      - pkg.installed: nova-filter-pkg

nova-services:
  service:
    - running
    - enable: True
    - restart: True
    - names:
      - nova-api
      - nova-cert
      - nova-conductor
      - nova-consoleauth
      - nova-novncproxy
      - nova-scheduler
    - require:
      - pkg.installed: nova-pkgs
    - watch:
      - file: /etc/nova

keystone-pkgs:
  pkg:
    - name: keystone
    - installed
  service:
    - name: keystone
    - running
    - enable: True
    - restart: True
    - watch:
      - file: /etc/keystone

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


cinder-pkgs:
  pkg.installed:
    - names:
      - cinder-api
      - cinder-common
      - cinder-scheduler
      - cinder-volume
      - open-iscsi
      - iscsitarget
      - iscsitarget-dkms
    - require:
      - pkg.installed: python-mysqldb

cinder-services:
  service:
    - running
    - enable: True
    - restart: True
    - names:
      - cinder-api
      - cinder-scheduler
      - cinder-volume
    - require:
      - pkg.installed: cinder-pkgs
    - watch:
      - file: /etc/cinder

/etc/cinder:
  file:
    - recurse
    - source: salt://openstack/cinder
    - template: jinja
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


/root/scripts:
  file:
    - recurse
    - source: salt://openstack/scripts
    - file_mode: 755
    - template: jinja
    - context:
        infra: {{ pillar['infra'] }}
        networking: {{ pillar['networking'] }}
        endpoints: {{ pillar['endpoints'] }}
        keystone: {{ pillar['keystone'] }}
        nova: {{ pillar['nova'] }}
        glance: {{ pillar['glance'] }}
        cinder: {{ pillar['cinder'] }}
        rabbit: {{ pillar['rabbit'] }}
        secrets: {{ pillar['secrets'] }}
        swift: {{ pillar['swift'] }}
        quantum: {{ pillar['quantum'] }}

/etc/nova:
  file:
    - recurse
    - source: salt://openstack/nova
    - template: jinja
    - required:
      - pkg.installed: nova-pkgs
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
    - source: salt://openstack/haproxy
    - template: jinja
    - context:
        infra: {{ pillar['infra'] }}
        networking: {{ pillar['networking'] }}
        endpoints: {{ pillar['endpoints'] }}
    - require:
      - file.directory: /var/lib/haproxy
