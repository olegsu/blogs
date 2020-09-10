#!/bin/bash

kubectl -n $NS exec -it nginx-secrets-store-inline ls /mnt/secrets-store/