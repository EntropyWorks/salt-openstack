rabbitmq-server:
  pkg:
    - installed
    - name: rabbitmq-server
  service:
    - running
    - restart: True
    - enabled: True
    - require:
      - pkg: rabbitmq-server
    - watch:
      - file: /etc/rabbitmq

/etc/rabbitmq:
  file:
    - recurse
    - source: salt://openstack/rabbitmq
    - template: jinja

dot_erlang_cookie:
  file.managed:
    - name: /var/lib/rabbitmq/.erlang.cookie
    - source: salt://openstack/templates/dot-erlang-cookie.jinja
    - template: jinja
    - mode: 400
    - user: rabbitmq
    - group: rabbitmq
