#!/bin/bash

az account list -o json
export SUBSCRIPTION_ID= # SubscriptionID is .id of the account
export TENANT_ID= # TenantID is .tenantId