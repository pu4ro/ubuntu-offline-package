#!/bin/bash

# 변수 설정
MOVE_REPO_FILE=$1

# 필요한 변수들이 제공되지 않은 경우 오류 메시지 출력
if [ -z "$MOVE_REPO_FILE" ] ;then
  echo "Usage: $0 <move_repo_file> like ubuntu.tar.gz"
  exit 1
fi

# tar 파일 압축 해제
tar -xvf $MOVE_REPO_FILE -C ./
if [ $? -ne 0 ]; then
  echo "Failed to extract $MOVE_REPO_FILE"
  exit 1
else
  echo "Successfully extracted $MOVE_REPO_FILE"
fi

# move_repo 디렉토리를 /usr/local/repo로 이동
MOVE_REPO=./repo
sudo cp -r $MOVE_REPO /usr/local/repo
if [ $? -ne 0 ]; then
  echo "Failed to move $MOVE_REPO to /usr/local/repo"
  exit 1
else
  echo "Successfully moved $MOVE_REPO to /usr/local/repo"
fi

# 디렉토리 소유권 변경
sudo chown -R _apt: /usr/local/repo
if [ $? -ne 0 ]; then
  echo "Failed to change ownership of /usr/local/repo"
  exit 1
else
  echo "Successfully changed ownership of /usr/local/repo"
fi

# 로컬 APT 저장소 설정
echo "deb [trusted=yes] file:/usr/local/repo ./" | sudo tee /etc/apt/sources.list
if [ $? -ne 0 ]; then
  echo "Failed to set local APT repository"
  exit 1
else
  echo "Successfully set local APT repository"
fi

# 패키지 목록 업데이트
sudo apt-get update
if [ $? -ne 0 ]; then
  echo "Failed to update package list"
  exit 1
else
  echo "Successfully updated package list"
fi

# ansible 및 필요한 도구 설치
sudo apt-get install -y ansible
if [ $? -ne 0 ]; then
  echo "Failed to install ansible"
  exit 1
else
  echo "Successfully installed ansible"
fi

# 패키지 목록 다시 업데이트
sudo apt-get update
if [ $? -ne 0 ]; then
  echo "Failed to update package list again"
  exit 1
else
  echo "Successfully updated package list again"
fi

# 컬렉션 디렉토리로 이동
COLLECTION_DIR="./collections"
cd $COLLECTION_DIR
if [ $? -ne 0 ]; then
  echo "Failed to change directory to $COLLECTION_DIR"
  exit 1
else
  echo "Successfully changed directory to $COLLECTION_DIR"
fi

# Ansible Galaxy 컬렉션 설치
for file in *.tar.gz; do
  if [ -e "$file" ]; then
    ansible-galaxy collection install "$file"
    if [ $? -ne 0 ]; then
      echo "Failed to install collection $file"
      exit 1
    else
      echo "Successfully installed collection $file"
    fi
  else
    echo "No .tar.gz files found in the collection directory."
    exit 1
  fi
done

tar -xvf external_hub.tar.gz
tar -xvf makina_runway.tar.gz

echo "All tasks completed successfully."
