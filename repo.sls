ubuntu-cloud-keyring:
  pkg.installed

private-openstack-repo:
  pkgrepo.managed:
    - name: "deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/grizzly main"
    - human_name: Openstack Ubuntu Archive
    - file: /etc/apt/sources.list.d/openstack-ubuntu-archive.list
    - keyid: 5EDB1B62EC4926EA
    - keyserver: keyserver.ubuntu.com
    - required:
      - pkg.installed: ubuntu-cloud-keyring

