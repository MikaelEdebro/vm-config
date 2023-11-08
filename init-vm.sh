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

source ~/.bashrc

# install VSU CLI
mkdir -p ~/vsu-cli
cd ~/vsu-cli
az login --identity --username /subscriptions/50a73d67-b395-4eef-b655-9cd55a7fbbf3/resourcegroups/rg-vce-pipeline-dev/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sp-vce-pipeline-dev
az storage blob download --account-name savcepipelinedev --container-name vsu-cli --name vsu-cli-latest.zip --file ./vsu-cli-latest.zip --auth-mode login
unzip ./vsu-cli-latest.zip -d .
npm pkg delete scripts.prepare
sudo npm install -g --omit=dev --force
source ~/.bashrc
vsu --help
