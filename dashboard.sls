include:
  - openstack.repo

httpd:
  service:
    - running
    - enable: True
    - require:
      - pkg.installed: python-django-horizon

dashboard-pkgs:
    pkg.installed:
      - fromreo: private-openstack-repo
      - names:
        - apache2
        - apache2-utils
        - python-django-horizon
