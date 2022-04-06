Role Name
=========

aap2-installation role is intended to do an installation of Ansible Automation Platform 2.1

Requirements
------------

*** Needs to be checked ***

Role Variables
--------------

The following variable will be set if not supplied:

ansible_install_file: /tmp/ansible-automation-platform-setup-bundle-2.1.1-2.tar.gz
aap_setup_base_dir: /tmp/aap2-setup
aap_exnode_server: exnode-01
aap_controller_server: controller-01
aap_database_server: database-01
aap_admin_password: password
aap_database_name: awx
aap_database_username: awx
aap_database_password: password
aap_registry_username: username
aap_registry_password: password

Known limitations
-----------------

The does currently not download the aap2 installation bundle fron access.redhat.com.
This needs to be done manually and the path to the downloaded bundle needs to be defined in the
ansible_install_file variable.

Dependencies
------------

None at the moment

Example Playbook
----------------

    - role: aap2-installation
      ansible_install_file: "/root/ansible-automation-platform-setup-bundle-2.1.1-2.tar.gz"
      aap_setup_base_dir: "~/aap21install"
      aap_exnode_server: "{{ groups['execution_nodes'][0] }}"
      aap_controller_server: "{{ groups['automationcontroller'][0] }}"
      aap_database_server: "{{ groups['database'][0] }}"
      aap_admin_password: "password"
      aap_database_name: "awx"
      aap_database_username: "awx"
      aap_database_password: "password"
      aap_registry_username: "{{ rh_subs_username }}"
      aap_registry_password: "{{ rh_subs_password }}"

License
-------

GPL-3.0 License

Author Information
------------------

Michael Bang
Jens Boivie
