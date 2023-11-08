#!/bin/bash -e

az login --identity --username /subscriptions/50a73d67-b395-4eef-b655-9cd55a7fbbf3/resourcegroups/rg-vce-pipeline-dev/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sp-vce-pipeline-dev
az storage blob download --account-name savcepipelinedev --container-name vsu-cli --name vsu-cli-latest.zip --file ~/vsu-cli/vsu-cli-latest.zip --auth-mode login
