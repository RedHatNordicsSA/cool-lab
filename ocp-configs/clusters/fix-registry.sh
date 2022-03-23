cat << EOF | oc create -f-
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: image-registry-storage
  namespace: openshift-image-registry
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
EOF
oc patch config.imageregistry.operator.openshift.io/cluster \
 --type=merge -p \
 {"spec":{"rolloutStrategy":"Recreate","replicas":1,"managementState":"Managed","storage":{"pvc":{"claim":"image-registry-storage"}}}}
