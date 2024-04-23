#!/bin/bash

set -eo pipefail

# update apt-get
sudo DEBIAN_FRONTEND=noninteractive apt-get update

# install dig, jq, and other utils
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq dnsutils jq zip unzip

# needed for dpkg to work
# shellcheck disable=SC1090
source ~/.bashrc

# install docker and other prerequisites
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq apt-transport-https ca-certificates wget curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq docker-ce

# run docker command without sudo
sudo usermod -aG docker azureuser

# install node lts
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - &&\
sudo apt-get install -y nodejs

# install PowerShell
mkdir -p powershell
cd powershell
wget -q "https://github.com/PowerShell/PowerShell/releases/download/v7.3.9/powershell_7.3.9-1.deb_amd64.deb"
sudo dpkg -i powershell_7.3.9-1.deb_amd64.deb
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yf
sudo ln -s /usr/bin/pwsh /usr/local/bin/pwsh

# install Azure CLI
curl -sSL https://aka.ms/InstallAzureCLIDeb | sudo bash

az login --identity --username /subscriptions/d2e4cd6f-ef6e-476a-a6d7-ef1965d9f557/resourcegroups/rg-vce-devops-agents-prd/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sp-vce-devops-agents

declare NPM_FEED_URL
declare PAT_BASE64

NPM_FEED_URL="pkgs.dev.azure.com/VolvoGroup-MASDCL/VCEBusInfoServLayer/_packaging/VCE-MS-PoC/npm"
PAT_BASE64=$(az keyvault secret show --vault-name kv-vce-devops-agents-prd --name AzDevopsPatTokenBase64 --query "value" --output tsv)

npm config --user set "//${NPM_FEED_URL:?}/registry/:username" "VolvoGroup-MASDCL"
npm config --user set "//${NPM_FEED_URL:?}/registry/:_password" "${PAT_BASE64:?}"
npm config --user set "//${NPM_FEED_URL:?}/registry/:email" "npm requires email to be set but doesn't use the value"
npm config --user set registry "https://${NPM_FEED_URL:?}/registry"

# add vsu function to bash
npx -y @volvo/vce-service-util@latest shell >>~/.bashrc

cp ~/.npmrc /home/AzDevOps/.npmrc
sudo chown :AzDevOps /home/AzDevOps/.npmrc
