
# Copyright 2012-2013 Hewlett-Packard Development Company, L.P.
# All Rights Reserved.
# Copyright 2013 Patrick Galbraith <patg@hp.com> 
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
sync-dir-packages:
  pkg.installed:
  - names:
    - liblinux-inotify2-perl
    - libproc-daemon-perl
    - libyaml-perl

/var/lib/nova/glance/sync_test:
  file.directory:
    - user: glance
    - mode: 644
    - makedirs: True

sync_dir_restart:
  cmd.run:
    - name: service sync_dir restart
    - require:
      - pkg: sync-dir-packages
      - file: /etc/init/sync_dir.conf
      - file: /usr/local/bin/sync_dir.pl
      - file: /usr/local/bin/sync.yaml.pl

/etc/init/sync_dir.conf:
  file.managed:
    - source: salt://openstack/glance/scripts/sync_dir.conf
    - user: root
    - mode: 755 
    - require:
      - pkg.installed: sync-dir-packages
      - file: /usr/local/bin/sync_dir.pl

/usr/local/bin/sync_dir.pl:
  file.managed:
    - source: salt://openstack/glance/scripts/sync_dir.pl
    - user: root
    - mode: 755 
    - require:
      - pkg.installed: sync-dir-packages

/usr/local/bin/sync.yaml:
  file.managed:
    - source: salt://openstack/glance/scripts/sync.yaml
    - template: jinja
    - user: root
    - mode: 644 
    - require:
      - pkg.installed: sync-dir-packages
      - file: /usr/local/bin/sync_dir.pl
      - cmd: sync_dir_restart
