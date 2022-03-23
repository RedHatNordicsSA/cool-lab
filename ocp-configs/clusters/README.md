# OpenShift cluster definitions

Just in case, I store here couple of the clusters I've created. In case
we need to reinstall, go to bastion and do eg:

1. Add the secrets I filtered out

See CHANGEME parts from eg. vmware and pull secrets.

2. Create install dir with configs

```
mkdir rh-ocp-01
cp rh-ocp-01-install-config.yaml rh-ocp-01/install-config.yaml
```

3. Install the cluster

```
./openshift-install --dir rh-ocp-01  create cluster
```

# Adding PV for registry

In case you want to have persistent registry,
[this page describes what to do](https://docs.openshift.com/container-platform/4.10/installing/installing_vsphere/installing-vsphere-installer-provisioned-customizations.html#registry-removed_installing-vsphere-installer-provisioned-customizations).

and here are the commands roughly: [fix-registry.sh](fix-registry.sh)

# deleting the clusters

The quickest I've found is to go to vmware GUI and select VMs, do poweroff,
and then delete the folder. Remember to select to delete all resources from
the disk.
