#!/bin/sh
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  kubelet \
  kubeadm \
  kubectl \
  nfs-common \
  nfs-kernel-server \
  bash-completion \
  dnsmasq \
  jq \
  openssh-server \
  net-tools \
  ca-certificates \
  containerd \
  chrony \
  apache2 \
  dkms \
  libgl1-mesa-glx \
  mesa-utils \
  vim-tiny \
  zstd \
  helm \
  build-essential 
