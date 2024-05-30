#!/bin/bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
export IS_SELF_HOSTED_AGENT=true

# Constants
AZ_USER="AzDevOps"
DOCKER_GPG_KEY_URL="https://download.docker.com/linux/ubuntu/gpg"
DOCKER_APT_SOURCE="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable"
NPM_FEED_URL="pkgs.dev.azure.com/VolvoGroup-MASDCL/VCEBusInfoServLayer/_packaging/VCE-MS-PoC/npm"

# Log function
log() {
  echo "[INFO] $1"
}

# Update apt-get
log "Updating apt-get"
sudo apt-get update

# Creating AzDevOps user if not exists
if [[ "$(whoami)" != "$AZ_USER" ]]; then
  log "Setting up $AZ_USER user"
  if ! id "$AZ_USER" &>/dev/null; then
    sudo useradd -m "$AZ_USER"
    sudo usermod -aG adm,sudo "$AZ_USER"
    sudo chmod -R +r /home
    sudo apt-get install -yq acl
    setfacl -Rdm "u:$AZ_USER:rwX" /home
    setfacl -Rb /home/"$AZ_USER"
    echo "$AZ_USER ALL=NOPASSWD: ALL" | sudo tee -a /etc/sudoers
  fi

  # Running script as AzDevOps user
  su "$AZ_USER" -c "sudo cat ${BASH_SOURCE[0]} | sudo -u $AZ_USER tee /home/$AZ_USER/devops.sh"
  chmod +x /home/"$AZ_USER"/devops.sh
  su - "$AZ_USER" -c /home/"$AZ_USER"/devops.sh
  exit 0
fi

# Install essential packages
log "Installing essential packages"
sudo apt-get install -yq curl ca-certificates dnsutils jq zip wget unzip postgresql-client python3-pip

# Install Docker
log "Setting up Docker repository and installing Docker"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL "$DOCKER_GPG_KEY_URL" -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "$DOCKER_APT_SOURCE" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -yq docker-ce
sudo usermod -aG docker "$AZ_USER"

# Install Node LTS
log "Installing Node.js LTS"
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PowerShell
log "Installing PowerShell"
sudo apt-get install -y apt-transport-https software-properties-common
# shellcheck disable=SC1091
source /etc/os-release
wget -q https://packages.microsoft.com/config/ubuntu/"${VERSION_ID:?}"/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell

# Install Azure CLI
log "Installing Azure CLI"
curl -sSL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Azure CLI Login
log "Logging into Azure CLI"
az login --identity --username /subscriptions/d2e4cd6f-ef6e-476a-a6d7-ef1965d9f557/resourcegroups/rg-vce-devops-agents/providers/Microsoft.ManagedIdentity/userAssignedIdentities/sp-devops-agents

# Setup npm configuration
log "Setting up npm configuration"
npm_feed_url="$NPM_FEED_URL"
pat_base64=$(az keyvault secret show --vault-name kv-vce-agents --name AzDevopsPatTokenBase64 --query "value" --output tsv)
npm config --user set "//${npm_feed_url:?}/registry/:username" "VolvoGroup-MASDCL"
npm config --user set "//${npm_feed_url:?}/registry/:_password" "${pat_base64:?}"
npm config --user set "//${npm_feed_url:?}/registry/:email" "npm requires email to be set but doesn't use the value"
npm config --user set registry "https://${npm_feed_url:?}/registry"

# Install vsu
log "Installing vsu"
npx -y @volvo/vce-service-util@latest --version
