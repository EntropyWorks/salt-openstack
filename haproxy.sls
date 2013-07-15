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

/etc/default/haproxy:
  file.sed:
    - before: 0
    - after: 1
    - limit: ^ENABLED=
    - require:
      - pkg.installed: haproxy

/etc/haproxy:
  file:
    - recurse
    - source: salt://openstack/haproxy
    - template: jinja
    - context:
        infra: {{ pillar['infra'] }}
        networking: {{ pillar['networking'] }}
        endpoints: {{ pillar['endpoints'] }}
