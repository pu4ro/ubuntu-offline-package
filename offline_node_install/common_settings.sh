#!/bin/bash

# 호스트 이름 설정 (RHEL/CentOS에만 적용)
echo "Setting hostname..."
hostnamectl set-hostname "$(hostname)"

# firewalld 비활성화 (RHEL/CentOS 전용)
echo "Disabling firewalld..."
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# SELinux 비활성화 (RHEL/CentOS 전용)
echo "Disabling SELinux..."
if [ -f /etc/selinux/config ]; then
  sudo setenforce 0
  sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
else
  echo "SELinux configuration file not found, skipping..."
fi

# 커널 모듈 로드 설정을 위한 디렉토리 생성
echo "Ensuring /etc/modules-load.d directory exists..."
if [ ! -d /etc/modules-load.d ]; then
  sudo mkdir -p /etc/modules-load.d
  sudo chmod 0755 /etc/modules-load.d
fi

# k8s.conf 파일에 필요한 커널 모듈 추가
echo "Adding required kernel modules to /etc/modules-load.d/k8s.conf..."
cat <<EOL | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
overlay
xt_REDIRECT
xt_owner
nf_nat
iptable_nat
iptable_mangle
iptable_filter
EOL

# 커널 모듈 로드
echo "Loading kernel modules..."
sudo modprobe br_netfilter
sudo modprobe ip_vs
sudo modprobe ip_vs_rr
sudo modprobe ip_vs_wrr
sudo modprobe ip_vs_sh
sudo modprobe overlay
sudo modprobe xt_REDIRECT
sudo modprobe xt_owner
sudo modprobe nf_nat
sudo modprobe iptable_nat
sudo modprobe iptable_mangle
sudo modprobe iptable_filter

# 타임존 설정 (Asia/Seoul)
echo "Setting timezone to Asia/Seoul..."
sudo timedatectl set-timezone Asia/Seoul

# SELinux 상태 확인 및 출력
echo "Checking SELinux status..."
getenforce

# 스왑 비활성화
echo "Disabling swap..."
sudo swapoff -a

# /etc/fstab 백업
echo "Backing up /etc/fstab..."
sudo cp /etc/fstab /etc/fstab.backup

# /etc/fstab에서 스왑 항목 비활성화
echo "Disabling swap permanently in /etc/fstab..."
sudo sed -i.bak '/\s+swap\s+/s/^/#/' /etc/fstab

# 스왑 라벨 및 UUID 제거
echo "Ensuring no swap entries in /etc/fstab..."
sudo sed -i '/^\s*UUID=\S+\s+none\s+swap\s+sw\s+0\s+0\s*$/d' /etc/fstab
sudo sed -i '/^\s*LABEL=\S+\s+none\s+swap\s+sw\s+0\s+0\s*$/d' /etc/fstab

# Chrony 패키지 설치
echo "Installing Chrony..."
sudo yum install -y chrony

# Chrony 설정 파일 생성 및 서버 추가
echo "Configuring Chrony server..."
CHRONY_SERVER1="192.10.12.20" # 필요에 따라 서버 이름을 변경하세요
CHRONY_SERVER2="192.10.9.7"  # 필요에 따라 서버 이름을 변경하세요
cat <<EOL | sudo tee /etc/chrony.conf
server $CHRONY_SERVER1 iburst
server $CHRONY_SERVER2 iburst
driftfile /var/lib/chrony/drift
makestep 1 3
logdir /var/log/chrony
EOL

# Chrony 서비스 활성화 및 시작
echo "Starting and enabling Chrony service..."
sudo systemctl enable chronyd
sudo systemctl start chronyd

echo "RHEL/CentOS setup completed."

