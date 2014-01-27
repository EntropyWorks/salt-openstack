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
# dirty check to see if things are actually HA. This may not work for you as-is
# because of the bond0 interface.
#
my_ip=$(ip addr show bond0 | grep "inet "| awk '{print $2}')
cluster="{% for key, args in pillar['endpoints']['rabbit']['servers'].iteritems() %}{{ args }} {% endfor %}"
ports="5671 3306 9200"
for port in ${ports} ; do
        echo "-------------------------------------------"
        echo "Testing: ${cluster}"
        echo "Port: ${port}"
        echo "From: ${my_ip} "
        echo "-------------------------------------------"
        for ip in ${cluster}; do
                nc -vz -w1 ${ip} ${port} ;
        done
done
