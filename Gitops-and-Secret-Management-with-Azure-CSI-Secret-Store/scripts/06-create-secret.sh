#!/bin/bash

az keyvault secret set --vault-name $KV_NAME --name secret-name --value "supersecret"

# print the secret
az keyvault secret show --vault-name $KV_NAME --name secret-name