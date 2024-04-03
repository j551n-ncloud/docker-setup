#!/bin/bash

# Function to uninstall old Docker version if found
uninstall_old_docker() {
    sudo apt-get purge -y docker-ce docker-ce-cli containerd.io
    sudo rm -rf /etc/apt/sources.list.d/docker.list
}

# Check if curl is installed
if ! [ -x "$(command -v curl)" ]; then
    echo "Installing curl..."
    sudo apt-get update
    sudo apt-get install -y curl
fi

# Check if Docker is already installed
if [ -x "$(command -v docker)" ]; then
    echo "Old Docker installation found. Uninstalling..."
    uninstall_old_docker
    echo "Old Docker installation removed."
fi

# Install Docker dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates gnupg-agent software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
if ! [ -x "$(command -v docker-compose)" ]; then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose is already installed."
fi

# Install Portainer
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ee:latest
