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

source /root/scripts/stackrc

function install_image {
  local name=$1
  local url=$2

  if [ ! -e /root/images/$name.qcow2 ]; then
    mkdir -p /root/images/
    curl -L -o /root/images/$name.qcow2 "$url"
  fi

  if ! glance index | grep "$name"; then
    glance add name=$name is_public=True protected=True disk_format=qcow2 container_format=bare < /root/images/$name.qcow2
  fi
}

{% for name, url in pillar['glance']['default_images'].iteritems() %}
install_image {{ name }} "{{ url }}"
{% endfor %}
