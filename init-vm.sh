#!/usr/bin/env bash

set -euo pipefail

# update apt-get
sudo DEBIAN_FRONTEND=noninteractive apt-get update

# install dig & jq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq dnsutils jq zip unzip

# needed for dpkg to work
source ~/.bashrc

# Install docker and other prerequisites
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq docker-ce

# run docker command without sudo
sudo usermod -aG docker azureuser

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc

# install PowerShell
mkdir -p powershell
cd powershell
wget -q "https://github.com/PowerShell/PowerShell/releases/download/v7.3.9/powershell_7.3.9-1.deb_amd64.deb"
sudo dpkg -i powershell_7.3.9-1.deb_amd64.deb
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yf
sudo ln -s /usr/bin/pwsh /usr/local/bin/pwsh

# install Azure CLI
curl -sSL https://aka.ms/InstallAzureCLIDeb | sudo bash

# install VSU CLI
mkdir -p /usr/local/lib/vsu-cli && cd /usr/local/lib/vsu-cli

# install node lts with latest npm
nvm install --lts --latest-npm
nvm use --lts

# install vsu
az login --identity --username /subscriptions/d2e4cd6f-ef6e-476a-a6d7-ef1965d9f557/resourcegroups/rg-vce-devops-agents-prd/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sp-vce-devops-agents
az storage blob download --account-name savceterraformagentsprd --container-name vsu --name vsu.zip --file ./vsu.zip --auth-mode login
unzip -q ./vsu.zip -d .

npm pkg delete scripts.prepare
npm install -g --omit=dev

# pull base images to speed up docker build
# docker pull node:18.16-alpine
