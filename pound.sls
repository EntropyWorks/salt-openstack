pound:
  pkg:
    - installed
    - name: pound
  service:
    - running
    - restart: True
    - enabled: True
    - require:
      - pkg: pound
      - pkg: openssl 
      - file: /etc/pound/pound.pem
      - file: /etc/pound/pound.cfg

openssl:
  pkg:
    - installed
    - name: openssl


/etc/pound/pound.cfg:
  file.managed:
    - source: salt://pound/pound.cfg
    - template: jinja
    - mode: 644
    - user: root
    - group: root

/etc/default/pound:
  file.managed:
    - source: salt://pound/pound
    - template: jinja
    - mode: 644
    - user: root
    - group: root

/etc/pound/pound.pem:
  file.managed:
    - source: salt://pound/pound.pem
    - template: jinja
    - mode: 644
    - user: root
    - group: root
