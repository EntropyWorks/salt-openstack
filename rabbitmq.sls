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
rabbitmq-server:
  pkg.installed:
    - name: rabbitmq-server

/etc/rabbitmq/rabbitmq.config:
  file.managed:
    - source: salt://openstack/rabbitmq/config/rabbitmq.config
    - template: jinja
    - require:
      - file: /etc/rabbitmq/ssl
      - pkg: rabbitmq-server

/etc/rabbitmq/ssl:
  file.recurse:
    - source: salt://openstack/rabbitmq/config/ssl
    - template: jinja
    - clean: True
    - template: jinja
    - require:
      - pkg: rabbitmq-server

{% for server_hostname, server_ip in pillar['endpoints']['rabbit']['servers'].iteritems() %}
{% if server_hostname != grains['host'] %}
host_add_{{ server_hostname }}:
  host.present:
    - names:
      - {{ server_hostname }}.localdomain
      - {{ server_hostname }}
    - ip: {{ server_ip }}
    - require_in:
      - pkg: rabbitmq-server

{% else %}
host_remove_{{ server_hostname }}:
  host.absent:
    - names:
      - {{ server_hostname }}.localdomain
      - {{ server_hostname }}
    - ip: {{ server_ip }}
    - require_in:
      - pkg: rabbitmq-server

{% endif %}

{% endfor %}

sleep_before_stop:
  cmd.run:
    - name: sleep 30
    - user: root
    - require:
      - pkg: rabbitmq-server

stop_rabbitmq_service:
  cmd.run:
    - name: /etc/init.d/rabbitmq-server stop
    - require:
      - pkg: rabbitmq-server
      - file: /etc/rabbitmq/rabbitmq.config
      - cmd: sleep_before_stop

/var/lib/rabbitmq/.erlang.cookie:
  file.managed:
    - source: salt://openstack/rabbitmq/dot-erlang.sls
    - template: jinja
    - user: rabbitmq
    - group: rabbitmq
    - mode: 400
    - require:
      - cmd: stop_rabbitmq_service

sleep_before_start:
  cmd.run:
    - name: sleep 30
    - user: root
    - require:
      - cmd: stop_rabbitmq_service

start_rabbit_service:
  cmd.run:
    - name: /etc/init.d/rabbitmq-server start
    - require:
      - pkg: rabbitmq-server
      - cmd: stop_rabbitmq_service
      - cmd: sleep_before_start
      - file: /var/lib/rabbitmq/.erlang.cookie

{% if pillar['endpoints']['rabbit']['master_node']  == grains['host'] %}
{% for rabbit_username, rabbit_password in pillar['secrets']['rabbit_users'].iteritems() -%}

rabbit_user_{{ rabbit_username }}:
  rabbitmq_user.present:
    - name: {{ rabbit_username }}
    - password: {{ rabbit_password }}
    - force: True
    - require:
      - pkg: rabbitmq-server
      - cmd: start_rabbit_service

rabbit_user_permissions_{{ rabbit_username }}:
  rabbitmq_vhost.present:
    - name: /
    - user:  {{ rabbit_username }}

{% endfor %}

enable_queue_mirroring:
  cmd.run:
    - name: rabbitmqctl set_policy ha-all '.*' '{"ha-mode":"all", "ha-sync-mode":"automatic"}'
    - require:
      - pkg: rabbitmq-server
      - cmd: start_rabbit_service

{% else %}
stop_rabbit_app:
  cmd.run:
    - name: rabbitmqctl stop_app
    - user: root
    - require:
      - cmd: start_rabbit_service
      - file: /var/lib/rabbitmq/.erlang.cookie

rabbit_reset:
  cmd.run:
    - name: rabbitmqctl reset
    - user: root
    - require:
      - cmd: stop_rabbit_app
      - cmd: start_rabbit_service
      - file: /var/lib/rabbitmq/.erlang.cookie

join_rabbit_cluster:
  cmd.run:
    - name: rabbitmqctl join_cluster rabbit@{{ pillar['endpoints']['rabbit']['master_node'] }}
    - user: root
    - require:
      - cmd: rabbit_reset
      - cmd: start_rabbit_service
      - file: /var/lib/rabbitmq/.erlang.cookie

start_rabbit_app:
  cmd.run:
    - name: rabbitmqctl start_app
    - user: root
    - require:
      - cmd: join_rabbit_cluster
      - cmd: start_rabbit_service
      - file: /var/lib/rabbitmq/.erlang.cookie

{% endif %}

