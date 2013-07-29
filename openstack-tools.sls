include:
  - openstack.nova-config
  - openstack.nova-user

nova-pkgs:
  pkg.installed:
    - names:
      - python-novaclient
      - python-keystoneclient
      - python-glanceclient
      - python-cinderclient

