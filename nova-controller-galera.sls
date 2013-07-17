debconf-utils:
  pkg.installed

python-eventlet:
  pkg.installed

python-mysqldb:
  pkg.installed

rabbitmq-server:
 pkg.installed

ubuntu-cloud-keyring:
  pkg.installed

nova-pkgs:
  pkg.installed:
    - names:
      - nova-api
      - nova-common
      - nova-network
      - nova-cert
      - nova-consoleauth
      - nova-scheduler
      - nova-novncproxy
      - nova-conductor
      - nova-network
      - dnsmasq
      - dnsmasq-base
      - dnsmasq-utils
    - require:
      - pkg.installed: python-mysqldb

nova-services:
  service:
    - running
    - enable: True
    - restart: True
    - names:
      - nova-api
      - nova-cert
      - nova-conductor
      - nova-consoleauth
      - nova-network
      - nova-novncproxy
      - nova-scheduler
    - require:
      - pkg.installed: nova-pkgs
    - watch:
      - file: /etc/nova

keystone-pkgs:
  pkg:
    - name: keystone
    - installed
  service:
    - name: keystone
    - running
    - enable: True
    - restart: True
    - watch:
      - file: /etc/keystone

/etc/keystone:
  file:
    - recurse
    - source: salt://openstack/keystone
    - template: jinja
    - watch:
      - pkg.installed: keystone
    - context:
        infra: {{ pillar['infra'] }}
        secrets: {{ pillar['secrets'] }}
        networking: {{ pillar['networking'] }}
        endpoints: {{ pillar['endpoints'] }}
        keystone: {{ pillar['keystone'] }}
        nova: {{ pillar['nova'] }}
        glance: {{ pillar['glance'] }}
        cinder: {{ pillar['cinder'] }}
        rabbit: {{ pillar['rabbit'] }}
        swift: {{ pillar['swift'] }}
        quantum: {{ pillar['quantum'] }}


glance-pkgs:
  pkg.installed:
    - names:
      - glance
      - glance-api
      - glance-common
      - glance-registry
      - python-glanceclient
    - require:
      - pkg.installed: python-mysqldb


glance-services:
  service:
    - running
    - enable: True
    - names:
      - glance-api
      - glance-registry
    - require:
      - pkg.installed: glance-pkgs
    - watch:
      - file.recurse: /etc/glance


/etc/glance:
  file:
    - recurse
    - source: salt://openstack/glance
    - template: jinja
    - require:
      - pkg.installed: glance-pkgs
      - file.recurse: /root/scripts
    - context:
        secrets: {{ pillar['secrets'] }}
        infra: {{ pillar['infra'] }}
        networking: {{ pillar['networking'] }}
        endpoints: {{ pillar['endpoints'] }}
        keystone: {{ pillar['keystone'] }}
        nova: {{ pillar['nova'] }}
        glance: {{ pillar['glance'] }}
        cinder: {{ pillar['cinder'] }}
        rabbit: {{ pillar['rabbit'] }}
        swift: {{ pillar['swift'] }}
        quantum: {{ pillar['quantum'] }}


cinder-pkgs:
  pkg.installed:
    - names:
      - cinder-api
      - cinder-common
      - cinder-scheduler
      - cinder-volume
      - open-iscsi 
      - iscsitarget
      - iscsitarget-dkms
    - require:
      - pkg.installed: python-mysqldb

cinder-services:
  service:
    - running
    - enable: True
    - restart: True
    - names:
      - cinder-api
      - cinder-scheduler
      - cinder-volume
    - require:
      - pkg.installed: cinder-pkgs
    - watch:
      - file: /etc/cinder

/etc/cinder:
  file:
    - recurse
    - source: salt://openstack/cinder
    - template: jinja
    - context:
        secrets: {{ pillar['secrets'] }}
        infra: {{ pillar['infra'] }}
        networking: {{ pillar['networking'] }}
        endpoints: {{ pillar['endpoints'] }}
        keystone: {{ pillar['keystone'] }}
        nova: {{ pillar['nova'] }}
        glance: {{ pillar['glance'] }}
        cinder: {{ pillar['cinder'] }}
        rabbit: {{ pillar['rabbit'] }}
        swift: {{ pillar['swift'] }}
        quantum: {{ pillar['quantum'] }}


/root/scripts:
  file:
    - recurse
    - source: salt://openstack/bin
    - file_mode: 755
    - template: jinja
    - context:
        infra: {{ pillar['infra'] }}
        networking: {{ pillar['networking'] }}
        endpoints: {{ pillar['endpoints'] }}
        keystone: {{ pillar['keystone'] }}
        nova: {{ pillar['nova'] }}
        glance: {{ pillar['glance'] }}
        cinder: {{ pillar['cinder'] }}
        rabbit: {{ pillar['rabbit'] }}
        secrets: {{ pillar['secrets'] }}
        swift: {{ pillar['swift'] }}
        quantum: {{ pillar['quantum'] }}
    
/etc/nova:
  file:
    - recurse
    - source: salt://openstack/nova
    - template: jinja
    - required:
      - pkg.installed: nova-pkgs
    - context:
        infra: {{ pillar['infra'] }}
        secrets: {{ pillar['secrets'] }}
        networking: {{ pillar['networking'] }}
        endpoints: {{ pillar['endpoints'] }}
        keystone: {{ pillar['keystone'] }}
        nova: {{ pillar['nova'] }}
        glance: {{ pillar['glance'] }}
        cinder: {{ pillar['cinder'] }}
        rabbit: {{ pillar['rabbit'] }}
        swift: {{ pillar['swift'] }}
        quantum: {{ pillar['quantum'] }}
