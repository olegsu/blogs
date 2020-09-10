#!/bin/bash

export SERVICE_PRINCIPAL_NAME=csi-sp-test-drive
az ad sp create-for-rbac --skip-assignment --name $SERVICE_PRINCIPAL_NAME