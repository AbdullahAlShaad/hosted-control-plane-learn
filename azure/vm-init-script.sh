#!/bin/bash

# Exit immediately if a command exits with a non-zero status
# Update the package index and install required packages
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Download and add the Google Cloud public signing key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Replace 'kubernetes-xenial' with your Ubuntu version
# Change this line based on your OS version
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update the package index again to include Kubernetes packages
sudo apt-get update

# Install kubelet, kubeadm, and kubectl
sudo apt-get install -y kubelet kubeadm kubectl

# Mark them to not be upgraded
sudo apt-mark hold kubelet kubeadm kubectl

# Install containerd
sudo apt-get install -y containerd

# Configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd

# Install crictl
VERSION="v1.26.0"  # Change this to the desired version
sudo curl -L https://github.com/kubernetes-sigs/cri-tools/releases/download/${VERSION}/crictl-${VERSION}-linux-amd64.tar.gz -o /tmp/crictl.tar.gz
sudo tar -zxvf /tmp/crictl.tar.gz -C /usr/bin
sudo chmod +x /usr/bin/crictl

# Create a configuration file for crictl
cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
EOF

