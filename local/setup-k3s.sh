#!/bin/bash

set -e  # Exit immediately on error

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

