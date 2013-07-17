include:
  - openstack.nova-config

#- openstack.root-scripts

nova-pkgs:
  pkg.installed:
    - names:
      - nova-common
      - nova-compute
      - nova-network
      - nova-api-metadata
      - nova-novncproxy
      - dnsmasq
      - dnsmasq-base
      - dnsmasq-utils

nova-services:
  service:
    - running
    - enable: True
    - restart: True
    - names:
      - nova-compute
      - nova-network
      - nova-api-metadata
    - require:
      - pkg.installed: nova-pkgs
    - watch:
      - file: /etc/nova

/var/lib/nova/instances/_base/ephemeral:
  file.managed:
    - user: nova
    - group: nova
