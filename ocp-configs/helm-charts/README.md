# Helm Charts for Cool-Lab

This directory is for helm charts we may create for cool-lab. In case they
take secrets, do list the secret variables in helm-values-secret.yaml file
which is stored ansible vault encrypted in private-lab repo.

To here is an example to run the helm chart:

```
ansible-vault --vault-password-file=../../../vault-password \
  decrypt --output helm-values-secret.yaml \
  ../../../private-lab/helm-values-secret.yaml
helm install -f helm-values-secret.yaml ldap-sync ./ldap-sync \
  --namespace=ldap-sync --create-namespace
cd -
```

# Chart descriptions

Describe here the charts you add.

## ldap-sync

This chart adds LDAP authentication the cluster. Red Hat IdM iss used as the
source.

```
helm install -f helm-values-secret.yaml --namespace=ldap-sync --create-namespace \
  ldap-sync ./ldap-sync
```

