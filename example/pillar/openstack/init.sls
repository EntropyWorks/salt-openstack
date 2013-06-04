# Look for comments in here. The should get removed before you 
# actually try to use this file. This is only an example of what 
# is defined. I really need to rework this to a cleaner version
# -Yazz
# 
# Mgmnt Network: 192.0.2.0/24 (Behind your firewall, physical node IP)
# VM Private Network:  198.51.100.0/24 (VM's can see this)
# Public Network: 203.0.213.0/24 (Floating IP range and on the node too)
#
openstack:
  glance:
    default_images:
      precise-12.04.1-20130124: "http://cloud-images.ubuntu.com/releases/precise/release-20130124/ubuntu-12.04-server-cloudimg-amd64-disk1.img"
      raring-13.04-20130601: "http://cloud-images.ubuntu.com/releases/raring/release-20130601/ubuntu-13.04-server-cloudimg-amd64-disk1.img"
  databases:
    - nova
    - glance
    - keystone
    - cinder
  nova_delete_floating:
    - 203.0.113.0
    - 203.0.113.1
    - 203.0.113.0/29
  clout_mirror: "deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/grizzly main"
  nova_node_availability_zone: RegionOne  
  admin_token: PLACE_YOUR_OWN_TOKEN_HERE
  service_password: barfoo
  admin_password: secrete
  demo_password: secrete
  database_password: not_your_root_mysql_passwd
  database_host: 192.0.2.10
  rabbit_host: 192.0.2.10
  keystone_host: 192.0.2.10
  cinder_host: 192.0.2.10
  glance_host: 192.0.2.10
  quantum_host: 127.0.0.1 # Not working yet
  openstack_public_address: 203.0.213.2
  openstack_admin_address: 192.0.2.10
  openstack_internal_address: 192.0.2.10
  rabbit_password: guest
  interfaces_control: eth0
  interfaces_public: vlan100
  nova_host: 192.0.2.10
  nova_libvirt_type: kvm
  nova_compute_driver: nova.virt.libvirt.LibvirtDriver
  nova_network_floating: 203.0.113.0/24
  nova_network_public_nets: "203.0.213.2/24" # could be more 
  nova_network_private: 198.51.100.0/24
  nova_flat_network_dhcp_start: 198.51.100.10  # This doesn't work at the moment
  nova_network_private_num: 
  nova_network_private_size: 254
  nova_network_private_interface: eth0
  nova_network_public_interface: vlan100
  nova_network_flat_interface: vlan200
  nova_network_bridge_interface: br100
  nova_network_my_ip: {{ salt['network.interfaces']()['eth0']['inet'][0]['address'] }}
  nova_network_public_gateway: 203.0.113.1
  nova_network_mgmnt_net: "192.0.2.0/24"
  nova_ssh_no_host_check:
    - "192.0.2.*" 
  nova_ssh_private: |
    -----BEGIN RSA PRIVATE KEY-----
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=
   -----END RSA PRIVATE KEY-----
  nova_ssh_public: ssh-rsa XXXXXXXXXXXXXXXXXXXXXXXX nova@example.com
