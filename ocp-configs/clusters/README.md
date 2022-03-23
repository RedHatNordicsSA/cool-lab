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

# deleting the clusters

The quickest I've found is to go to vmware GUI and select VMs, do poweroff,
and then delete the folder. Remember to select to delete all resources from
the disk.
