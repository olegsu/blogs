#!/bin/bash

export KV_NAME=csi-kv
az keyvault create --name $KV_NAME --resource-group $RESOURCE_GROUP_NAME