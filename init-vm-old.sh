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
mkdir -p /usr/local/lib/vsu-cli && cd /usr/local/lib/vsu-cli

az login --identity --username /subscriptions/d2e4cd6f-ef6e-476a-a6d7-ef1965d9f557/resourcegroups/rg-vce-devops-agents-prd/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sp-devops-agents
az storage blob download --account-name savceterraformagentsprd --container-name vsu --name vsu.zip --file ./vsu.zip --auth-mode login
unzip -q ./vsu.zip -d .
npm pkg delete scripts.prepare
npm install -g --omit=dev


# pull base images to speed up docker build
# docker pull node:18.16-alpine
