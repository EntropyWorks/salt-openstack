#  galera_servers:
#    ip_01: 10.8.52.17
#    ip_02: 10.8.53.74
#    ip_03: 10.8.54.18

haproxy:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - restart: True
    - require:
      - pkg.installed: haproxy
    - watch:
      - file: /etc/haproxy

/etc/haproxy:
  file:
    - recurse
    - source: salt://openstack/haproxy
    - template: jinja
