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
if [ -f /root/scripts/stackrc ] ; then
	source /root/scripts/stackrc
else
	echo "ERROR!!! Failed to load /root/scripts/stackrc"
	exit 1
fi

function install_image {
  local name=$1
  local url=$2

  if [ ! -f /root/images/$name.qcow2 ]; then
    mkdir -p /root/images/
    http_proxy="http://{{ infra.proxy.host }}:{{ infra.proxy.port }}/"
    https_proxy="http://{{ infra.proxy.host }}:{{ infra.proxy.port }}/"
    curl -L -o /root/images/$name.qcow2 "$url"
    unset http_proxy https_proxy
  fi

  glance-manage db_sync

  if ! glance index | grep "$name"; then
    glance --verbose add name=$name is_public=True protected=True disk_format=qcow2 container_format=bare < /root/images/$name.qcow2
  fi
}



if [ ! -f /etc/setup-done-glance ] ; then 

	echo " Nova Glance sync"
	glance-manage --config-dir /etc/glance db_sync

{% for name, url in pillar['glance']['default_images'].iteritems() %}
	echo " Adding: {{ name }} : {{ url }}"
	install_image "{{ name }}" "{{ url }}"
{% endfor %}

	touch /etc/setup-done-glance
else
	echo " >>>>>>>>>>>>> Already setup Nova <<<<<<<<<<<"
	echo " >>>>>>>>> rm /etc/setup-done-glance <<<<<<<<"
	exit 1
fi
