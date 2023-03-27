# The Red Hat Nordics SA lab

Documentation to Red Hat Nordics Lab

![Alt text](cool_lab_transparent_background_logos.png?raw=true "Cool Lab")

## Communication

See: https://github.com/mglantz/cool-lab/blob/main/communication.md

## Generic Rules

1. Remember, no private stuff into github. There is vault for that.
2. All VMs created by Red Hat personnel should start with `rh-` prefix
   and and with two digit number. E.g. `rh-bastion-01`
3. We have four VLANs in use, see
   [miro](https://miro.com/app/board/uXjVOd3rE1I=/).
4. Add any permanent services to miro board "Arrow lab architecture facts" table
   for others to find them.
5. If creating permanent services, consider static ip. Otherwise dhcp is fine.
6. Consider that anything you do with ansible for the infra bits should work
   both from command line and AAP. Secrets are in secrets.yml, from where they
   are populated to AAP as credentials where needed.

## Development

It is agreed we don't manually do anything. Of course you can play around
freely with demos and such, but anything persistent should be written
as code. We use
[github kan-ban table](https://github.com/orgs/RedHatNordicsSA/projects/1)
to track issues. Definiton of done is that:

- Implementation is automated
- Anyone can run automation based on instructions here.

### Git branching

The main branch should always be in working state. So any half done stuff should
be on your presonal feature branch.

Here's good blog about such
[better git flow](https://render.com/blog/git-organized-a-better-git-flow).
Instead of `git reset` I prefer `git rebasei -i origin/main`.

### AAP developement

Now that we have AAP, and it's configs are here in [./aap_configs](./aap_configs)
you need to think about branching git. So create your own branch for development
and add a temporary project to AAP to point there. That gives you opportunity
to push new playbooks and changes to your branch, and for the time of testing,
the temporary project pulls from there. Once feature is ready, do PR to main
and switch the tasks to point to project for main branch.

## Private matters

Secrets like keys, passwords etc. sensitive stuff get's stored into the
[private repo](https://github.com/RedHatNordicsSA/private-lab/).
Ask an admin for the vault key.

## Ansible preparations

First, fix the local ansible config:

```
cp example-ansible.cfg ansible.cfg
```

Many of the playbooks here create stuff from the scratch. So we ansible will
ask for host key verification. We don't want to stop there, so you can
either change the config file, or just set the environment variable for
time of first time creation of host:

```
[defaults]
host_key_checking = False
```

or

```
export ANSIBLE_HOST_KEY_CHECKING=False
```

We use ansible roles and collections (some of them are from Red Hat Ansible Automation Hub, and hence need subscriptions). When starting work from scratch you need to download dependencies. To be able to download subscription based dependencies/collections from Red Hat Ansible Automation Hub you need to have the auth_server_url, server_url and token in place. The URLs are specified in the example-ansible.cfg file. The token is available in the secrets file in vault. ansible-galaxy client can unfortunately not read vault, but in the secrets.yml file there is a comment line you can copy to export the token as a variable. If you do that, content from ansible automation hub can be used with your ansible command line client. If you don't do this your ansible-galaxy collention install will fail.

To get collections and roles to your workstation, do:

```
ansible-galaxy role install -r roles/requirements.yml -p roles
ansible-galaxy collection install -r collections/requirements.yml -p collections
```

This will download you the requirements.

Should you end up having an error message similar to this:

```
ERROR! Failed to resolve the requested dependencies map. Could not satisfy the following requirements:
* redhat.rhel_system_roles:* (direct request)
```

You are probably having issues with authentication to Red Hat Automation Hub.
Follow this [documentation](https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/1.2/html-single/getting_started_with_red_hat_ansible_automation_hub/index) to generate a `token`for you and add that to your `ansible.cfg` file.

```
...

[galaxy_server.automation_hub_saas]
url=https://console.redhat.com/api/automation-hub/
auth_url=https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/token
# use variable ANSIBLE_GALAXY_SERVER_AUTOMATION_HUB_SAAS_TOKEN from vault

token = <your-personal-token>

...
```

## Building of RHEL base image with Packer

We start with chicken and egg problem. We can't start a RHEL VM in VMware
until we have RHEL template image in VMware. To solve this, we use
Ansible playbook to command Packer to a) upload RHEL install CD along
with customized kickstart CD to VMware and b) command VMware to build
and store a new VM template out of the incredients.

To build a new template one needs to do:

1. Download RHEL install DVD
2. Put the value into
   [build-rhel-template-packer-vmware.yml](build-rhel-template-packer-vmware.yml)

```
iso:
  rhel_8_5:
    url: "file:///home/itengval/VirtualMachines/rhel-8.5-x86_64-dvd.iso"
    checksum: sha256:1f78e705cd1d8897a05afa060f77d81ed81ac141c2465d4763c0382aa96cadd0
```

3. Run the playbook:

```
ansible-playbook -i localhost, -c local -e do_cleanup=false build-rhel-template-packer-vmware.yml
```

4. Wait for it....

Ten points for someone who figures out how to avoid the upload. There should
be a way to make packer find it from the VMware datastore directly, but I
haven't figured it out yet. Here are the official
[packer instructions](https://www.packer.io/docs/builders/vsphere/vsphere-iso).

Image can be built with Red Hat image builder, but there is a catch. Red Hat
only supports VMware if template is built on VMware. So it makes sense to do
it this way. For other purposes the image builder is good.

The newly found image will be stored in storage defined in the playbook,
check the vars.

## Ensuring the bastion host

We create the bastion host using the playbook
[setup-bastion.yml](setup-bastion.yml). It creates it from the rhel template,
and does basic configs. The other playbook removes it, or let's you control the
power state.

Create:

```
ansible-playbook  -u root -e "rh_subs_username=$subs_username rh_subs_password=$subs_pw" setup-bastion.yml
```

## Create / Delete / power off / power on VM

There is [generic playbook](ensure-vm-state.yml) to create VMs from given
template. If you want RHEL you run this:

```
ansible-playbook -i localhost, -c local -e short_name=rh-test-net ensure-vm-state.yml
```

For power state commands:

```
ansible-playbook -i localhost, -c local -e vm_state=poweredoff -e short_name=rh-test-net ensure-vm-state.yml
```

And to delete it nicely, unregistering from all places like subs and idm:

```
ansible-playbook  -u root -e "short_name=rh-test-01" -l rh-idm-01.cool.lab  nuke-vm.yml
```

And bluntly just delete VM, leave subscriptions, insights and idm think it still exists:

```
ansible-playbook -i localhost, -c local -e vm_state=absent -e short_name=rh-test-net ensure-vm-state.yml
```

There are different values in vars, check them out. Like mem, cpu, network etc tunings.

## Add more disk space to VM

Create and attach new disk to VM. Pass the size of the disk in format of e.g. 5GB.
This will only create and attach the disk, there is no filesystem yet.

```
VMWARE_VALIDATE_CERTS=no ansible-playbook -e @../private-lab/secrets.yml \
-i hosts -l rh-disks-01.cool.lab -e vm_disksize=25GB  vmware_add_disk_to_vm.yml
```

This playbook finds the above created empty disk from VM, and creates PV to it and
extends the given LV to include the new PV. E.g. if you have LV for logs, extend the
logs space by giving `vm_lv_name=logs`.

```
VMWARE_VALIDATE_CERTS=no ansible-playbook -e @../private-lab/secrets.yml \
-u root -i hosts -l rh-disks-01.cool.lab -e vm_vg_name=rhel -e vm_lv_name=root \
vm_extend_lv_with_new_disk.yml
```

Alternatively you can attach the disk as totally new VG and LV, or old VG and new LV, with
new mount point. For size you can use absolute size like 5G or percentage of PV, like 100%.

```
VMWARE_VALIDATE_CERTS=no ansible-playbook -e @../private-lab/secrets.yml \
-u root -i hosts -l rh-disks-01.cool.lab \
-e vm_new_vg=new -e vm_new_lv=disk -e vm_disksize='100%' \
vm_attach_unused_disk_as_lv.yml
```

# IdM - Identity Management

We control identity by using Red Hat Identity Manager. We have it in
replication mode. It manages the following

- Users and Groups
- Sudo rules
- Host groups and RBAC
- SSH key management
- Certificate management

## Setup IdM hosts

We create one IdM server and a replica. They will be name rh-idm-01.coollab and
rh-idm-02.coollab.

```
ansible-playbook  -u root -e "rh_subs_username=$subs_username rh_subs_password=$subs_pw" setup-idm.yml
```

## Setup IdM clients

To sign a host into IdM, one needs to add the client to [inventory](hosts) into group called
ipaclients. After inventory is ok, run:

```
ansible-playbook -i hosts -u root -l rh-test-01.cool.lab -e short_name=rh-test-01 setup-idmclient.yml
```

This will ensure the VM hosts are all in IdM.

## Populate Users and Groups to IdM

To add/remove users, update the user list in file
[group_vars/ipaservers/users.yml](group_vars/ipaservers/users.yml)
and run:

```
 ansible-playbook -i hosts -u root idm_provision_users.yml
```

## Manage host groups

Make sure your VM ends up into one of the groups in hostgroups variable in
[group_vars/all/main.yml](group_vars/all/main.yml). E.g:

```
hostgroups:
  - name: infra
    hosts:
      - rh-idm-01.cool.lab
      - rh-idm-02.cool.lab
      - rh-bastion-01.cool.lab
```

and run:

```
ansible-playbook -i hosts -u root  idm_ensure_host_groups.yml
```

For future, we want this to be in add/remove host functionality

## Install (and update) Ansible Automation Platform 2.3+

### Controllers, database, execution nodes

1. Make sure you have the `infra.aap_utilities` collection installed

```
ansible-galaxy collection install -r collections/requirements.yml
```

2. Configure the variables in playbook `install-aap-controller.yml`

```yaml
---
- name: Install Automation Controller(s)
  hosts: bastions
  vars:
    aap_setup_down_version: "2.3"
    aap_setup_down_type: "setup-bundle"

    aap_setup_prep_inv_nodes:
      automationcontroller:
        rh-ansiblecontroller-01.cool.lab:
      execution_nodes:
        rh-exnode-01.cool.lab:
      database:
        rh-ansibledatabase-01.cool.lab:

    aap_setup_prep_inv_vars:
      all:
        ansible_become: true
        admin_password: "{{ aap_admin_password }}"

        pg_host: "rh-ansibledatabase-01.cool.lab"
        pg_port: "5432"
        pg_database: "awx"
        pg_username: "awx"
        pg_password: "{{ aap_database_password }}"
        pg_sslmode: "prefer"  # set to 'verify-full' for client-side enforced SSL

        registry_username: "{{ vault_rh_subs_username }}"
        registry_password: "{{ vault_rh_subs_password }}"

        receptor_listener_port: 27199
      automationcontroller:
        peers: execution_nodes

  roles:
    - infra.aap_utilities.aap_setup_download
    - infra.aap_utilities.aap_setup_prepare
    - infra.aap_utilities.aap_setup_install
```

3. Run the playbook

If running from bastion, use local connection.

```
ansible-playbook -i hosts -c local -e @../private-lab/secrets.yml install-aap-controller.yml
```

### Configuring AAP platofrm post install

There is playbook
[aap_configure_controller.yml](./aap_configure_controller.yml) which
configures all settings into controller. It is utilizing the role
[tower configuration](https://github.com/redhat-cop/tower_configuration)
that reads config files from [aap_configs](./aap_configs/) directory.
To add configuration files, see examples from
[examples](https://github.com/redhat-cop/tower_configuration/tree/devel/examples/configs)

Once you create or change the configs, do run the following playbook:

```
ansible-playbook aap_configure_controller.yml
```

### Adding community execution environment for AAP

I had to add some community modules and python libraries to my env. So I
created an EE for AAP. To rebuild it, get token from
[https://console.redhat.com/ansible/automation-hub/token](automation hub)
and add it to [./aap_ee_community/ansible.cfg](EE ansible config).

Make sure you have podman, and then build image:

```
pip install ansible-builder
podman login registry.redhat.io
cd aap_ee_community
ansible-builder build -t community -f execution-enviroment.yml
podman save localhost/community -o community.img
```

Better to upload it to some registry, now I manually loaded it into AAP.

### Install (and update) Automation Hub 2.3+

1. Create an offline token at https://access.redhat.com/management/api/

2. Configure variables in playbook `install-aap-automationhub.yml` and run it.

```
ansible-playbook -i hosts -l rh-automation-hub-01.cool.lab -e aap_setup_down_offline_token="<token>" -e @../private-lab/secrets.yml install-aap-automationhub.yml
```

## Install Satellite

Satellite will be installed on fixed IP address. Installation takes run of
three playbooks:

1. Create or verify satellite VM exists according to minimum requirements
2. Set up the VM to IdM management
3. Install and configure the satellite

```
ansible-playbook -e @../private-lab/secrets.yml -e "short_name=rh-satellite-01" -e ansible_python_interpreter=/usr/bin/python3 ensure-satellite.yml
ansible-playbook -i hosts -u root -e @../private-lab/secrets.yml -l rh-satellite-01.cool.lab setup-idmclient.yml
ansible-playbook -i hosts -u root -e @../private-lab/secrets.yml satellite-install.yml
```

Once Satellite is installed, the configuration is updated by modifying and
running the satellite-install.yml playbook
