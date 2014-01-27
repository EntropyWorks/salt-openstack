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
pm-utils:
  pkg.installed

libvirt-bin:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - restart: True
    - require:
      - pkg.installed: libvirt-bin
      - file.sed: /etc/init/libvirt-bin.conf
      - file.managed: /etc/libvirt/libvirtd.conf
      - file.managed: /etc/libvirt/qemu.conf
    - watch:
      - file.sed: /etc/init/libvirt-bin.conf
      - file.managed: /etc/libvirt/libvirtd.conf
      - file.managed: /etc/libvirt/qemu.conf

/etc/libvirt/qemu.conf:
  file.managed:
    - source: salt://openstack/dependancy/libvirt/qemu.conf
    - required:
      - pkg: libvirt-bin

/etc/apparmor.d/usr.sbin.libvirtd:
  file.managed:
    - source: salt://openstack/dependancy/libvirt/usr.sbin.libvirtd
    - stateful: True
    - required:
      - pkg: libvirt-bin

libvirt-apparmor:
  cmd:
    - wait
    - name: service apparmor reload
    - watch:
      - file.managed: /etc/apparmor.d/usr.sbin.libvirtd

/etc/libvirt/libvirtd.conf:
  file.managed:
    - source: salt://openstack/dependancy/libvirt/libvirtd.conf
    - required:
      - pkg: libvirt-bin

/etc/init/libvirt-bin.conf:
  file.sed:
    - before: 'env libvirtd_opts="-d"'
    - after: 'env libvirtd_opts="-d -l"'
    - required:
      - pkg.installed: libvirt-bin
      - file.managed: /etc/libvirt/libvirtd.conf
      - file.managed: /etc/libvirt/qemu.conf

virsh net-undefine default:
  cmd.run:
    - onlyif: "virsh net-destroy default"
    - watch:
      - service.restart: libvirt-bin
