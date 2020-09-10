#!/bin/bash

export AZURE_CLIENT_ID=$(az ad sp show --id http://$SERVICE_PRINCIPAL_NAME --query appId -o tsv)