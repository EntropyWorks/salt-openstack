include:
  - openstack.repo

apache2:
  service:
    - running
    - enable: True
    - restart: True
    - require:
      - pkg.installed: openstack-dashboard
    - watch:
      - pkg: dashboard-pkgs

dashboard-pkgs:
    pkg.installed:
      - fromreo: private-openstack-repo
      - names:
        - apache2
        - apache2-utils
        - openstack-dashboard
        - memcached
