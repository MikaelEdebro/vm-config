#!/bin/bash -e

mkdir setup-vm
cd setup-vm

# update apt-get
sudo apt-get update

# install node, npm, dig & jq
sudo apt-get install -y dnsutils jq

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.bashrc
nvm install --lts

# install docker
#Add Docker's official GPG key:
# sudo apt-get install -y ca-certificates curl gnupg
# sudo install -m 0755 -d /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# sudo chmod a+r /etc/apt/keyrings/docker.gpg

# # Add the repository to Apt sources:
# echo \
#   "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#   "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
#   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# # install powershell
# mkdir powershell
# cd powershell
# wget https://github.com/PowerShell/PowerShell/releases/download/v7.3.9/powershell-7.3.9-linux-x64.tar.gz
# tar -xvf powershell-7.3.9-linux-x64.tar.gz -C .
# sudo ln -s ~/setup-vm/powershell/pwsh /usr/local/bin/pwsh

# # install azure cli
# curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# # reload bashrc
source ~/.bashrc
