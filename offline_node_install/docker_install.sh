#!/bin/bash

# Docker 설치
echo "Installing Docker..."
if [ -f /etc/redhat-release ]; then
  sudo yum install -y docker-ce
elif [ -f /etc/debian_version ]; then
  sudo apt-get update -y
  sudo apt-get install -y docker-ce
else
  echo "Unsupported OS. Exiting..."
  exit 1
fi

# Docker 설정 디렉토리 확인 및 생성
echo "Ensuring Docker config directory exists..."
if [ ! -d /etc/docker ]; then
  sudo mkdir -p /etc/docker
  sudo chmod 0755 /etc/docker
fi

# GPU 설치 여부 확인
echo "Checking for GPU..."
GPU_INSTALLED=$(lspci | grep -i nvidia)
GPU_ADDED=false
if [ -n "$GPU_INSTALLED" ]; then
  GPU_ADDED=true
  echo "GPU detected. Installing NVIDIA Container Toolkit..."
  # NVIDIA container toolkit 설치
  sudo yum install -y nvidia-container-toolkit
else
  echo "No GPU detected."
fi

# Docker daemon 설정 파일 생성
echo "Configuring Docker daemon..."
cat <<EOL | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m"
  },
  "storage-driver": "overlay2",
  "insecure-registries": [
    "cr.makina.rocks",
    "harbor.runway.kidi.or.kr"
  ],
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 500000,
      "Soft": 500000
    },
    "nproc": {
      "Name": "nproc",
      "Hard": 500000,
      "Soft": 500000
    }
  }
EOL

# GPU가 설치된 경우에 추가 설정
if [ "$GPU_ADDED" = true ]; then
  cat <<EOL | sudo tee -a /etc/docker/daemon.json
  ,
  "default-runtime": "nvidia",
  "runtimes": {
    "nvidia": {
      "path": "/usr/bin/nvidia-container-runtime",
      "runtimeArgs": []
    }
  }
EOL
fi

# 설정 파일 마무리
echo "}" | sudo tee -a /etc/docker/daemon.json

# Docker 서비스 재시작
echo "Reloading Docker to apply new configuration..."
sudo systemctl enable docker
sudo systemctl restart docker

# /var/lib/kubelet 디렉토리 확인 및 생성
echo "Ensuring /var/lib/kubelet directory exists..."
if [ ! -d /var/lib/kubelet ]; then
  sudo mkdir -p /var/lib/kubelet
  sudo chmod 0755 /var/lib/kubelet
fi

# config.json 파일 생성
echo "Creating config.json under /var/lib/kubelet..."
cat <<EOL | sudo tee /var/lib/kubelet/config.json
{
  "auths": {
    "cr.makina.rocks": {
      "auth": "YWRtaW46SGFyYm9yMTIzNDU="
    },
    "harbor.runway.kidi.or.kr": {
      "auth": "YWRtaW46SGFyYm9yMTIzNDU="
    }
  }
}
EOL

# kubelet 서비스 재시작
echo "Restarting kubelet service..."
sudo systemctl restart kubelet

# 60초 대기
echo "Pausing for 60 seconds..."
sleep 60

echo "Script completed."

