#!/bin/bash

az keyvault set-policy -n $KV_NAME --key-permissions get --spn $AZURE_CLIENT_ID
az keyvault set-policy -n $KV_NAME --secret-permissions get --spn $AZURE_CLIENT_ID
az keyvault set-policy -n $KV_NAME --certificate-permissions get --spn $AZURE_CLIENT_ID