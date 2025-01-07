#!/bin/bash

# sysctl 설정 파일 생성 및 적용
echo "Configuring sysctl for Kubernetes networking..."

cat <<EOL | sudo tee /etc/sysctl.d/k8s.conf
# sysctl settings for Kubernetes networking
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 512
fs.file-max = 500000

# grpc settings
net.core.wmem_max = 12582912
net.core.rmem_max = 12582912
net.ipv4.tcp_rmem = 4096 87380 12582912
net.ipv4.tcp_wmem = 4096 65536 12582912
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_keepalive_intvl = 75
net.ipv4.tcp_keepalive_probes = 9
net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_retries2 = 15
EOL

# sysctl 재적용
echo "Reloading sysctl settings..."
sudo sysctl --system

# 임시로 nofile 및 nproc 제한 적용
echo "Applying temporary ulimit settings..."
ulimit -Sn 500000
ulimit -Hn 500000

# /etc/security/limits.conf 파일에 soft/hard nofile 및 nproc 제한 추가
echo "Updating /etc/security/limits.conf with nofile and nproc limits..."
sudo sed -i '/\* soft nofile/d' /etc/security/limits.conf
sudo sed -i '/\* hard nofile/d' /etc/security/limits.conf
sudo sed -i '/\* soft nproc/d' /etc/security/limits.conf
sudo sed -i '/\* hard nproc/d' /etc/security/limits.conf

sudo tee -a /etc/security/limits.conf > /dev/null <<EOL
* soft nofile 500000
* hard nofile 500000
* soft nproc 500000
* hard nproc 500000
EOL

echo "Configuration applied successfully."

