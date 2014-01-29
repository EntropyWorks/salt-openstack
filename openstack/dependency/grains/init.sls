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
# This is very important to the deploy. Setting this grain prevents
# an accident of moving the network_top to the wrong AZ. 
{% if 'az1' in grains['host'] %}
network_topic:
  grains.present:
    - value: network_az1
{% elif 'az2' in grains['host'] %}
network_topic:
  grains.present:
    - value: network_az2
{% elif 'az3' in grains['host'] %}
network_topic:
  grains.present:
    - value: network_az3
{% endif %}

# Set a grain so set the type of physical node this
# should be. Currently there are only afew types.
{% if 'cpu' in grains['host'] %}
include:
  - grains.cpu-grain
{% elif 'dbhead0002' in grains['host'] %}
include:
  - grains.controller-grain
  - grains.keystone-grain
{% elif 'dbhead0003' in grains['host'] %}
include:
  - grains.db-grain
  - grains.rabbitmq-grain
{% endif %}

