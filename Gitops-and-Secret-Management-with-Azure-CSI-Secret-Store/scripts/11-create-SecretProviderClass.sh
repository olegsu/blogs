#!/bin/bash

cat <<EOF | kubectl apply -n $NS -f -
apiVersion: secrets-store.csi.x-k8s.io/v1alpha1
kind: SecretProviderClass
metadata:
  name: azure-csi
spec:
  provider: azure                   
  parameters:
    keyvaultName: "$KV_NAME"
    objects:  |
      array:
        - |
          objectName: secret-name # name was set erlier 
          objectType: secret
    resourceGroup: "$RESOURCE_GROUP_NAME"
    subscriptionId: "$SUBSCRIPTION_ID"
    tenantId: "$TENANT_ID"
EOF