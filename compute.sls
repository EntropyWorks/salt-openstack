openstack-pkgs:
  pkg.installed:
    - names:
      - nova-compute
      - nova-network
      - dnsmasq-utils

nova-services:
  service:
    - running
    - enable: True
    - names:
      - nova-compute
      - nova-network
    - require:
      - pkg.installed: nova-compute
      - pkg.installed: nova-network

/etc/nova:
file:
  - recurse
  - source: salt://openstack/nova
  - template: jinja
  - require:
    - pkg.installed: nova
  - watch_in:
    - service: nova-services

