rabbitmq-server:
  pkg.installed:
    - name: rabbitmq-server
    - skip_verify: True
    - require:
      - file: /etc/apt/sources.list

/etc/rabbitmq:
  file:
    - recurse
    - source: salt://rabbitmq/config
    - template: jinja

enable_mgmt_plugin:
  cmd.run:
    - name: rabbitmq-plugins enable rabbitmq_management
    - user: root
    - require:
      - pkg: rabbitmq-server

{% for server_ip, server_hostname in pillar['openstack']['rabbit_servers_hostname'].iteritems() -%}
#{% if server_hostname != grains['host'] %}
host_add_{{ server_hostname }}:
  host.present:
    - names:
      - {{ server_hostname }}.localdomain
      - {{ server_hostname }}
    - ip: {{ server_ip }}
    - require_in:
      - pkg: rabbitmq-server

#{% endif %}
{% endfor %}

stop_rabbitmq_service:
  cmd.run:
    - name: /etc/init.d/rabbitmq-server stop
    - require:
      - pkg: rabbitmq-server
      - file: /etc/rabbitmq

/var/lib/rabbitmq/.erlang.cookie:
  file.managed:
    - source: salt://rabbitmq/dot-erlang.sls
    - require:
      - cmd: stop_rabbitmq_service

start_rabbit_service:
  cmd.run:
    - name: /etc/init.d/rabbitmq-server start
    - require:
      - cmd: stop_rabbitmq_service
      - file: /var/lib/rabbitmq/.erlang.cookie

{% if grains['host'] ==  pillar['openstack']['rabbit_master_node'] %}
{% for rabbit_username, rabbit_password in pillar['openstack']['rabbit_users'].iteritems() -%}

rabbit_user_{{ rabbit_username }}:
  rabbitmq_user.present:
    - name: {{ rabbit_username }}
    - password: {{ rabbit_password }}
    - force: True
    - require:
      - pkg: rabbitmq-server

rabbit_user_permissions_{{ rabbit_username }}:
  rabbitmq_vhost.present:
    - name: /
    - user:  {{ rabbit_username }}

{% endfor %}
{% endif %}

{% if grains['host'] !=  pillar['openstack']['rabbit_master_node'] %}

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
    - name: rabbitmqctl join_cluster rabbit@{{pillar['openstack']['rabbit_master_node']}}
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
