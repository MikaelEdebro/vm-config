#!/bin/bash -e

# update apt-get
sudo DEBIAN_FRONTEND=noninteractive apt-get update

# install dig & jq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq dnsutils jq zip unzip

# needed for dpkg to work
source ~/.bashrc

# install node & npm using https://github.com/tj/n
curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | bash -s lts

# Install docker and other prerequisites
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq docker-ce
# run docker command without sudo
sudo usermod -aG docker azureuser

# Install PowerShell
mkdir -p powershell
cd powershell
wget -q "https://github.com/PowerShell/PowerShell/releases/download/v7.3.9/powershell_7.3.9-1.deb_amd64.deb"
sudo dpkg -i powershell_7.3.9-1.deb_amd64.deb
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yf
sudo ln -s /usr/bin/pwsh /usr/local/bin/pwsh

# Install Azure CLI
curl -sSL https://aka.ms/InstallAzureCLIDeb | sudo bash

# source ~/.bashrc

# install VSU CLI
az account set -s d2e4cd6f-ef6e-476a-a6d7-ef1965d9f557
patToken=$(az keyvault secret show --vault-name kv-vce-devops-agents-prd --name AzDevopsPatToken --query "value" --output tsv)

declare -R NPM_FEED_URL="pkgs.dev.azure.com/VolvoGroup-MASDCL/VCEBusInfoServLayer/_packaging/VCE-MS-PoC/npm"

declare PAT_BASE64

PAT_BASE64=$(print "${patToken:?}" | base64 -w 0)

# token as is
npm config --user set "//${NPM_FEED_URL:?}/registry/:username" "VolvoGroup-MASDCL"
npm config --user set "//${NPM_FEED_URL:?}/registry/:_password" "${PAT_BASE64:?}"
npm config --user set "//${NPM_FEED_URL:?}/registry/:email" "npm requires email to be set but doesn't use the value"
npm config --user set registry "https://${NPM_FEED_URL:?}/registry"

npm i @volvo/vce-service-util@latest -g

# pull base images to speed up docker build
docker pull node:lts-alpine
