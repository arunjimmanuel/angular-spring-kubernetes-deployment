#!/bin/bash

set -e  # Exit immediately on error

echo ">>> Creating 2G swap file..."
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

echo ">>> Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo ">>> Installing k3s with selected components disabled..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --disable metrics-server --disable servicelb" sh -

echo ">>> Setting up kubeconfig..."
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
echo 'export KUBECONFIG=$HOME/.kube/config' >> ~/.bashrc
export KUBECONFIG=$HOME/.kube/config  # for immediate use

echo ">>> Installing Helm 3..."
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

echo ">>> Setting up GitHub Actions runner..."
mkdir -p actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.323.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.323.0/actions-runner-linux-x64-2.323.0.tar.gz
tar xzf ./actions-runner-linux-x64-2.323.0.tar.gz
rm -f ./actions-runner-linux-x64-2.323.0.tar.gz

echo ">>> Encoding kubeconfig in base64:"
base64 -w 0 ~/.kube/config
echo -e "\n>>> Script complete!"
