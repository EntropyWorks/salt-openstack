include:
  - openstack.root-scripts

/etc/nova:
  file:
    - recurse
    - source: salt://openstack/nova
    - template: jinja
    - required:
      - pkg.installed: nova-pkgs
    - context:
        secrets: {{ pillar['secrets'] }}
        infra: {{ pillar['infra'] }}
        networking: {{ pillar['networking'] }}
        endpoints: {{ pillar['endpoints'] }}
        keystone: {{ pillar['keystone'] }}
        nova: {{ pillar['nova'] }}
        glance: {{ pillar['glance'] }}
        cinder: {{ pillar['cinder'] }}
        rabbit: {{ pillar['rabbit'] }}
        swift: {{ pillar['swift'] }}
        quantum: {{ pillar['quantum'] }}
