#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

sudo rm /boot/grub/menu.lst

# https://github.com/hashicorp/packer/issues/2639
echo "Waiting 100 seconds for cloud-init to finish..."
sleep 100

sudo apt-get update
sudo -E apt-get dist-upgrade -y

# Install azure CLI
curl -sL https://packages.microsoft.com/keys/microsoft.asc | 
    gpg --dearmor | 
    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |  sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update
sudo apt-get install -y azure-cli