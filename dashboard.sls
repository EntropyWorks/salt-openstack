include:
  - openstack.repo

apache2:
  service:
    - running
    - enable: True
    - restart: True
    - require:
      - pkg.installed: python-django-horizon
    - watch:
      - pkg: python-django-horizon

dashboard-pkgs:
    pkg.installed:
      - fromreo: private-openstack-repo
      - names:
        - apache2
        - apache2-utils
        - python-django-horizon
