apache2:
  service:
    - running
    - enable: True
    - restart: True
    - require:
      - pkg.installed: dashboard-needs
    - watch:
      - pkg: dashboard-pkgs


dashboard-needs:
  pkg.installed:
    - names:
      - memcached
      - apache2
      - apache2-utils
      - libapache2-mod-wsgi

dashboard-pkgs:
    pkg.installed:
      - names:
        - python-django-horizon
      - require:
        - pkg.installed: dashboard-needs
