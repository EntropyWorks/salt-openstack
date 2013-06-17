keystone_ssl_key:
  file.managed:
    - name: /etc/keystone/ssl/private/paas-deploy-ssl.key
    - source: salt://openstack/templates/paas-deploy-ssl.key.jinja
    - template: jinja
    - mode: 400
    - user: keystone 
    - group: keystone 
    - require:
        - user: keystone 
        - group: keystone 
