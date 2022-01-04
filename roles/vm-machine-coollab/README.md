Role Name
=========

VM-Machine-coollab role is intended to create new virtual machines in the coollab environment

Requirements
------------

*** Needs to be checked ***

Role Variables
--------------

The following variable will be set if not supplied:

vm_name: delete_this_machine_anytime
state: poweredon
memory_mb: 2048
num_cpus: 2
num_cpu_cores_per_socket: 1
template: rhel_8_5_image
net_name: RH-seg-2991
net_type: dhcp       

If you want to define a static IP-address then you need to supply the following variables
net_type: static
ip: 10.128.1.256
netmask: 255.255.255.0
gateway: 10.128.1.1

Dependencies
------------

None at the moment

Example Playbook
----------------

- role: vm-machine-coollab
      # The ansible-controller-01
      memory_mb: 4096
      num_cpus: 2
      state: poweredon
      net_name: RH-seg-2991
      net_type: dhcp
      vm_name: rh-ansible-controller-01
      update_inventory: true
      inventory_groups:
        - aapcontroller
        - ansibleautomationplatform

License
-------

GPL-3.0 License

Author Information
------------------

Michael Bang
Jens Boivie
