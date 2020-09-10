#!/bin/bash

az role assignment create --role Reader --assignee $AZURE_CLIENT_ID --scope /subscriptions/$SUBSCRIPTION_ID/resourcegroups/$RESOURCE_GROUP_NAME/providers/Microsoft.KeyVault/vaults/$KV_NAME