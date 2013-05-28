{% set accounts = ['keystone', 'nova', 'glance', 'cinder' ] %}
{% for user in accounts %}
{{ user }}:
  mysql_database:
    - present

{{ user }}-grant:
  cmd.wait:
    - name: mysql -u root --execute="GRANT ALL ON {{ user }}.* TO '{{ user }}'@'%' IDENTIFIED BY '{{ pillar['openstack']['database_password'] }}';"
    - watch:
      - mysql_database.present: {{ user }}
{% endfor %}
