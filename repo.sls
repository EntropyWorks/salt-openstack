# Only add this if you want to override where your getting the openstack
# packages

ubuntu-cloud-keyring:
  pkg.installed

# name: "deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/grizzly main"
{% for mirror in pillar['infra']['mirror'].iteritems() }} %}
{{ mirror_name }}:
  pkgrepo.managed:
    - name: "{{ pillar['infra']['mirror']['{{ mirror_name }}']['url'] }}"
    - human_name: {{ pillar['infra']['mirror']['{{ mirror_name }}']['human_name'] }}
    - file: {{ pillar['infra']['mirror']['{{ mirror_name }}']['file'] }}
    - keyid: {{ pillar['infra']['mirror']['{{ mirror_name }}']['keyid'] }}
    - keyserver: keyserver.ubuntu.com
    - required:
      - pkg.installed: ubuntu-cloud-keyring
    - require_in:
      - pkg.installed: ubuntu-cloud-keyring
      - pkg.installed: nova-pkgs
      - pkg.installed: glance-pkgs
      - pkg.installed: cinder-pkgs
      - pkg.installed: dashboard-pkgs
      - pkg.installed: keystone-pkgs
{% endfor %}
