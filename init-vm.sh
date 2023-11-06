#!/bin/bash -e

mkdir -p setup-vm
cd setup-vm

# update apt-get
sudo DEBIAN_FRONTEND=noninteractive apt-get update

# install dig & jq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq dnsutils jq

source ~/.bashrc

# install node & npm using silent mode for curl and n
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
# wget -q https://github.com/PowerShell/PowerShell/releases/download/v7.3.9/powershell-7.3.9-linux-x64.tar.gz
# tar -xzf powershell-7.3.9-linux-x64.tar.gz

# # Check if 'pwsh' exists and link it to /usr/local/bin
# if [ -f "$PWD/pwsh" ]; then
#     # Set execute permissions
#     chmod +x $PWD/pwsh
#     # Link 'pwsh' to /usr/local/bin
#     sudo ln -fs $PWD/pwsh /usr/local/bin/pwsh
#     echo "PowerShell has been installed and linked."
# else
#     echo "Error: PowerShell binary 'pwsh' does not exist in the extracted directory."
#     exit 1
# fi
# Download PowerShell .deb package
wget -q "https://github.com/PowerShell/PowerShell/releases/download/v7.3.9/powershell_7.3.9-1.deb_amd64.deb"

# Install the downloaded package
sudo dpkg -i powershell_7.3.9-1.deb_amd64.deb

# Check for missing dependencies and install them
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yf

# Verify the installation
sudo ln -s /usr/bin/pwsh /usr/local/bin/pwsh

pwsh -v


# Install Azure CLI
curl -sSL https://aka.ms/InstallAzureCLIDeb | sudo bash

