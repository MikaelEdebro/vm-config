#!/bin/bash

set -euo pipefail

if [[ "$(whoami)" != "AzDevOps" ]]; then
  # setup AzDevOps user
  # Create our user account if it does not exist already
  if ! id AzDevOps &>/dev/null; then
    sudo apt-get update
    sudo useradd -m AzDevOps
    sudo usermod -a -G adm AzDevOps
    sudo usermod -a -G sudo AzDevOps
    sudo chmod -R +r /home
    sudo apt-get install -yq acl
    setfacl -Rdm "u:AzDevOps:rwX" /home
    setfacl -Rb /home/AzDevOps
    echo 'AzDevOps ALL=NOPASSWD: ALL' >>/etc/sudoers
  fi

  # run this script as AzDevOps
  su AzDevOps -c "sudo cat ${BASH_SOURCE[0]} | sudo -u AzDevOps tee /home/AzDevOps/devops.sh"
  chmod +x /home/AzDevOps/devops.sh
  su - AzDevOps -c /home/AzDevOps/devops.sh
  exit 0
fi

# update apt-get
sudo apt-get update

# install dig, jq, and other utils
sudo apt-get install -yq dnsutils jq zip unzip

# install docker and other prerequisites
sudo apt-get install -yq apt-transport-https ca-certificates wget curl software-properties-common

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update
sudo apt-get install -yq docker-ce
sudo usermod -a -G docker AzDevOps

# install Azure CLI
curl -sSL https://aka.ms/InstallAzureCLIDeb | sudo bash

az login --identity --username /subscriptions/d2e4cd6f-ef6e-476a-a6d7-ef1965d9f557/resourcegroups/rg-vce-devops-agents-prd/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sp-vce-devops-agents

declare npm_feed_url pat_base64

npm_feed_url="pkgs.dev.azure.com/VolvoGroup-MASDCL/VCEBusInfoServLayer/_packaging/VCE-MS-PoC/npm"
pat_base64=$(az keyvault secret show --vault-name kv-vce-devops-agents-prd --name AzDevopsPatTokenBase64 --query "value" --output tsv)

# install node lts
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - &&
  sudo apt-get install -y nodejs

# setup user wide .npmrc
npm config --user set "//${npm_feed_url:?}/registry/:username" "VolvoGroup-MASDCL"
npm config --user set "//${npm_feed_url:?}/registry/:_password" "${pat_base64:?}"
npm config --user set "//${npm_feed_url:?}/registry/:email" "npm requires email to be set but doesn't use the value"
npm config --user set registry "https://${npm_feed_url:?}/registry"

# install vsu
npx -y @volvo/vce-service-util@latest --version

# install PowerShell
sudo apt-get install -y wget apt-transport-https software-properties-common

# shellcheck disable=SC1091
source /etc/os-release
wget -q https://packages.microsoft.com/config/ubuntu/"${VERSION_ID:?}"/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell

# install Python with pip
sudo apt-get install -y python3-pip
