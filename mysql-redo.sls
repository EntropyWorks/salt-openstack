# Copyright 2012-2013 Hewlett-Packard Development Company, L.P.
# All Rights Reserved.
# Copyright 2013 Yazz D. Atlas <yazz.atlas@hp.com>
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
mysql:
  pkg:
    - installed
    - name: mysql-server
  file.sed:
    - name: /etc/mysql/my.cnf
    - before: '127.0.0.1'
    - after: '0.0.0.0'
    - limit: '^bind-address'
    - require:
      - pkg.installed: mysql-server
  service:
    - running
    - restart: True
    - enabled: True
    - require:
      - pkg: mysql-server
    - watch:
      - file.sed: /etc/mysql/my.cnf

{% set accounts = ['keystone', 'nova', 'glance', 'cinder' ] %}
{% for user in accounts %}
{{ user }}:
  mysql_user.present:
    - host: "%"
    - password: {{ pillar['secrets'][{{ user }}]['db_password'] }}
    - require:
      - pkg: mysql-server
      - file.sed: /etc/mysql/my.cnf
    - watch:
      - service.restart: mysql
  mysql_database:
    - present
    - require:
      - pkg: mysql-server
      - file.sed: /etc/mysql/my.cnf
    - watch:
      - service.restart: mysql
  mysql_grants.present:
    - grant: all privileges
    - database: "{{ user }}.*"
    - user: {{ user }}
    - require:
      - pkg: mysql-server
      - file.sed: /etc/mysql/my.cnf
      - mysql_database.present: {{ user }}
    - watch:
      - service.restart: mysql

{{ user }}-grant-wildcard:
  cmd.run:
    - name: mysql -e "GRANT ALL ON {{ user }}.* TO '{{ user }}'@'%' IDENTIFIED BY '{{ pillar['secrets'][{{ user }}]['db_password'] }}';"
    - unless: mysql -e "select Host,User from user Where user='{{ user }}' AND  host='%';" | grep {{ user }}
    - require:
      - pkg: mysql-server
      - file.sed: /etc/mysql/my.cnf
    - watch:
      - cmd.run: {{ user }}-grant-star
      - cmd.run: {{ user }}-grant-localhost

{{ user }}-grant-localhost:
  cmd.run:
    - name: mysql -e "GRANT ALL ON {{ user }}.* TO '{{ user }}'@'localhost' IDENTIFIED BY '{{ pillar['secrets'][{{ user }}]['db_password'] }}';"
    - unless: mysql -e "select Host,User from user Where user='{{ user }}' AND  host='localhost';" | grep {{ user }}
    - require:
      - pkg: mysql-server
      - file.sed: /etc/mysql/my.cnf
    - watch:
      - cmd.run: {{ user }}-grant-star

{{ user }}-grant-star:
  cmd.run:
    - name: mysql -e "GRANT ALL ON {{ user }}.* TO '{{ user }}'@'*' IDENTIFIED BY '{{ pillar['secrets'][{{ user }}]['db_password'] }}';"
    - unless: mysql -e "select Host,User from user Where user='{{ user }}' AND  host='*';" | grep {{ user }}
    - require:
      - pkg: mysql-server
      - file.sed: /etc/mysql/my.cnf
    - watch:
      - mysql_database.present: {{ user }}

{% endfor %}
