#!/bin/bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export IS_SELF_HOSTED_AGENT=true

# update apt-get
sudo apt-get update

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

# install dig, jq, and other utils
sudo apt-get install -yq curl ca-certificates dnsutils jq zip wget unzip postgresql-client python3-pip

# install docker and other prerequisites (https://docs.docker.com/engine/install/ubuntu/)
# Add Docker's official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
# shellcheck disable=SC1091
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -yq docker-ce
sudo usermod -a -G docker AzDevOps

# install node lts
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - &&
  sudo apt-get install -y nodejs

# install PowerShell
sudo apt-get install -y apt-transport-https software-properties-common

# shellcheck disable=SC1091
source /etc/os-release
wget -q https://packages.microsoft.com/config/ubuntu/"${VERSION_ID:?}"/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell

# install Azure CLI
curl -sSL https://aka.ms/InstallAzureCLIDeb | sudo bash

az login --identity --username /subscriptions/d2e4cd6f-ef6e-476a-a6d7-ef1965d9f557/resourcegroups/rg-vce-devops-agents/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sp-devops-agents

declare npm_feed_url pat_base64

npm_feed_url="pkgs.dev.azure.com/VolvoGroup-MASDCL/VCEBusInfoServLayer/_packaging/VCE-MS-PoC/npm"
pat_base64=$(az keyvault secret show --vault-name kv-vce-devops-agents2 --name AzDevopsPatTokenBase64 --query "value" --output tsv)

# setup user wide .npmrc
npm config --user set "//${npm_feed_url:?}/registry/:username" "VolvoGroup-MASDCL"
npm config --user set "//${npm_feed_url:?}/registry/:_password" "${pat_base64:?}"
npm config --user set "//${npm_feed_url:?}/registry/:email" "npm requires email to be set but doesn't use the value"
npm config --user set registry "https://${npm_feed_url:?}/registry"

# install vsu
npx -y @volvo/vce-service-util@latest --version
