#!/bin/bash
# Copyright 2012-2013 Hewlett-Packard Development Company, L.P.
# All Rights Reserved.
#
# Authored by Yazz D. Atlas <yazz.atlas@hp.com>
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

pushd /etc/init.d/; for i in $( ls nova-* ); do sudo service $i stop; done ; popd

ifconfig br100 down
brctl delbr br100

apt-get remove --purge -y \
        nova-api-metadata \
        nova-common \
        nova-compute \
        nova-compute-kvm \
        nova-conductor \
        nova-network \
        python-nova \
        dnsmasq-utils \
        dnsmasq-base \
        dnsmasq \
        python-novaclient

apt-get -y autoremove

rm -rf /etc/nova \
        /var/log/nova \
        /var/lib/nova/buckets \
        /var/lib/nova/CA \
        /var/lib/nova/images \
        /var/lib/nova/instances \
        /var/lib/nova/keys \
        /var/lib/nova/nova.sqlite \
        /var/lib/nova/networks \
        /etc/libvirt/qemu/*.xml \
        /etc/libvirt/nwfilter/nova-instance* \
        /var/lib/nova/tmp

find /var/lib/nova -print
