#!/bin/bash -e

mkdir setup-vm
cd setup-vm

# update apt-get
sudo apt-get update

# install dig & jq
sudo apt-get install -y dnsutils jq

# install node & npm
curl -fsSL https://raw.githubusercontent.com/tj/n/master/bin/n | bash -s lts

# install docker
# Add Docker's official GPG key:
# sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt update
# apt-cache policy docker-ce
# sudo apt-get install -y docker-ce
# # run docker command without sudo
# sudo usermod -aG docker ${USER}
# su - ${USER}


# # install powershell
mkdir powershell
cd powershell
wget https://github.com/PowerShell/PowerShell/releases/download/v7.3.9/powershell-7.3.9-linux-x64.tar.gz
tar -xvf powershell-7.3.9-linux-x64.tar.gz -C .
sudo ln -s ~/setup-vm/powershell/pwsh /usr/local/bin/pwsh

# install azure cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# # reload bashrc
source ~/.bashrc
