nova:
  group.present:
    - name: nova
    - system: True
  user.present:
    - fullname: Nova OpenStack User
    - shell: /bin/bash
    - home: /var/lib/nova
    - system: True
    - gid_from_name: True
    - require:
      - group: nova

nova_ssh_private_key:
  file.managed:
    - name: /var/lib/nova/.ssh/id_rsa
    - source: salt://openstack/templates/id_rsa.jinja
    - template: jinja
    - mode: 600
    - user: nova
    - group: nova
    - require:
        - user: nova
        - group: nova

nova_ssh_authorized_keys:
  file.managed:
    - name: /var/lib/nova/.ssh/authorized_keys
    - source: salt://openstack/templates/authorized_keys.jinja
    - template: jinja
    - mode: 600
    - user: nova
    - group: nova
    - require:
        - user: nova
        - group: nova

nova_ssh_fix_perm:
  file.directory:
    - name: /var/lib/nova/.ssh
    - mode: 700
    - user: nova
    - group: nova
    - require:
      - user: nova
      - group: nova

nova_run_openstack:
  file.directory:
    - name: /var/run/openstack
    - mode: 700
    - user: nova
    - group: nova
    - require:
      - user: nova
      - group: nova

nova_ssh_config:
  file.managed:
    - name: /var/lib/nova/.ssh/config
    - source: salt://openstack/templates/ssh_config.jinja
    - template: jinja
    - mode: 644
    - user: nova
    - group: nova
    - require:
      - user: nova
      - group: nova
