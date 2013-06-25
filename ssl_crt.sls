keystone_ssl_crt:
  file.managed:
    - name: /etc/keystone/ssl/certs/paas-deploy-ssl.crt
    - source: salt://openstack/templates/paas-deploy-ssl.crt.jinja
    - template: jinja
    - mode: 644
    - user: keystone 
    - group: keystone 
    - require:
        - user: keystone 
        - group: keystone 

