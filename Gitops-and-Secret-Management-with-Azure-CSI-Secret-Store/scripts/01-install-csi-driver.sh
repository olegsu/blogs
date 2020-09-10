#!/bin/bash

export NS=csi-test-run
kubectl create ns $NS
kubectl apply -n $NS -f https://github.com/olegsu/blogs/blob/master/Gitops-and-Secret-Management-with-Azure-CSI-Secret-Store/manifests/csi-driver/csi-driver.yaml