rabbitmq-server:
  pkg.installed:
    - name: rabbitmq-server

/etc/rabbitmq/rabbitmq.config:
  file.managed:
    - source: salt://openstack/rabbitmq/config/rabbitmq.config
    - template: jinja
    - require:
      - file: /etc/rabbitmq/ssl

/etc/rabbitmq/ssl:
  file.recurse:
    - source: salt://openstack/rabbitmq/config/ssl
    - clean: True

#enable_mgmt_plugin:
#  cmd.run:
#    - name: /usr/lib/rabbitmq/lib/rabbitmq_server-2.7.1/sbin/rabbitmq-plugins enable rabbitmq_management
#    - user: root
#    - require:
#      - pkg: rabbitmq-server

{% for server_ip, server_hostname in pillar['openstack']['rabbit_servers'].iteritems() -%}
{% if server_hostname not in grains['host'] %}
host_add_{{ server_hostname }}:
  host.present:
    - names:
      - {{ server_hostname }}.localdomain
      - {{ server_hostname }}
    - ip: {{ server_ip }}
    - require_in:
      - pkg: rabbitmq-server

{% endif %}

{% if server_hostname in grains['host'] %}
host_add_{{ server_hostname }}:
  host.absent:
    - names:
      - {{ server_hostname }}.localdomain
      - {{ server_hostname }}
    - ip: {{ server_ip }}
    - require_in:
      - pkg: rabbitmq-server

{% endif %}
{% endfor %}

#stop_rabbitmq_service:
#  service:
#    - name: rabbitmq_server
#    - dead
#    - require:
#      - pkg: rabbitmq-server
#      - file: /etc/rabbitmq/rabbitmq.config

/var/lib/rabbitmq/.erlang.cookie:
  file.managed:
    - source: salt://openstack/rabbitmq/dot-erlang.sls
    - template: jinja
    - user: rabbitmq
    - group: rabbitmq
    - mode: 400
#    - require:
#      - service: stop_rabbitmq_service

#start_rabbit_service:
#  service:
#    - name: rabbitmq-server
#    - running
#    - require:
#      - pkg: rabbitmq-server
#      - service: stop_rabbitmq_service
#      - file: /var/lib/rabbitmq/.erlang.cookie

{% if pillar['openstack']['rabbit_master_node'] in grains['host'] %}
{% for rabbit_username, rabbit_password in pillar['openstack']['rabbit_users'].iteritems() -%}

#rabbit_user_{{ rabbit_username }}:
#  rabbitmq_user.present:
#    - name: {{ rabbit_username }}
#    - password: {{ rabbit_password }}
#    - force: True
#    - require:
#      - pkg: rabbitmq-server
#      - service: start_rabbit_service
#
#rabbit_user_permissions_{{ rabbit_username }}:
#  rabbitmq_vhost.present:
#    - name: /
#    - user:  {{ rabbit_username }}
#
{% endfor %}
{% endif %}

{% if pillar['openstack']['rabbit_master_node'] not in grains['host'] %}

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
