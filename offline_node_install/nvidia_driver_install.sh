#!/bin/bash

# CentOS 패키지 설치
CENTOS_PACKAGES=("kubelet" "kubeadm" "kubectl" "dnsmasq" "nfs-utils" "wget")

if [ -f /etc/redhat-release ]; then
  echo "Installing packages on CentOS..."
  for pkg in "${CENTOS_PACKAGES[@]}"; do
    sudo yum install -y "$pkg"
  done
fi

# NVIDIA 장치 체크
NVIDIA_DEVICES=$(lspci | grep -i NVIDIA)
if [ -n "$NVIDIA_DEVICES" ]; then
  echo "NVIDIA devices found, proceeding with installation..."

  # NVIDIA 컨테이너 툴킷 및 드라이버 설치
  sudo yum install -y kernel-devel kernel-tools nvidia-container-toolkit

  # disable-nouveau.conf 파일이 있는지 확인
  if [ -f /etc/modprobe.d/disable-nouveau.conf ]; then
    echo "disable-nouveau.conf already exists, skipping dracut and configuration steps."
  else
    # nouveau 비활성화 설정 파일 생성
    sudo tee /etc/modprobe.d/disable-nouveau.conf > /dev/null <<EOL
blacklist nouveau
options nouveau modeset=0
EOL

    # initramfs 재생성
    echo "Regenerating initramfs..."
    sudo dracut --force

    # NVIDIA 디바이스가 있을 경우 재부팅
    echo "Rebooting system for NVIDIA driver changes..."
    sudo reboot
  fi
else
  echo "No NVIDIA devices found."
fi

# NVIDIA 드라이버 복사 및 설치
NVIDIA_DRIVER_VERSION="535.161"
REPO_DIR="/usr/local/repo"

if [ -n "$NVIDIA_DEVICES" ]; then
  echo "Copying NVIDIA driver from local repository..."

  # 드라이버 복사
  cp "$REPO_DIR/nvidia-driver_$NVIDIA_DRIVER_VERSION.tar.gz" /tmp/

  # 압축 해제
  tar -xvzf /tmp/nvidia-driver_$NVIDIA_DRIVER_VERSION.tar.gz -C /tmp/

  # NVIDIA 설치 파일 복사
  cp "$REPO_DIR/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER_VERSION}.run" /tmp/

  # NVIDIA 설치 실행
  sudo /tmp/NVIDIA-Linux-x86_64-535.161.07/nvidia-installer --silent \
                          --install-compat32-libs \
                          --no-nouveau-check \
                          --no-nvidia-modprobe \
                          --no-rpms \
                          --no-backup \
                          --no-check-for-alternate-installs \
                          --no-libglx-indirect \
                          --no-install-libglvnd \
                          --x-prefix=/tmp/null \
                          --x-module-path=/tmp/null \
                          --x-library-path=/tmp/null \
                          --x-sysconfig-path=/tmp/null

  # 재부팅
else
  echo "Skipping NVIDIA installation as no devices are present."
fi

