### offline node install 진행하기
ssh 불가한 상태로 `로컬에서 스크립트 실행하는 로직으로 변경`

먼저 패키징 된 파일을 `/root` 디렉토리 아래 이동


mount 진행 하기 `mount -t nfs 192.168.134.102:/volume1/delta_package/ /mnt`
아래 경로 통해서 repo.tar.gz 파일을 다운로드 받을 수 있다.
`/mnt/kidi_devel_server/240925_node_install/`


디렉토리 명은 `offline_node_install`

```jsx
offline_node_install/
├── common_settings.sh
├── docker_install.sh
├── nvidia_driver_install.sh
├── repo.tar.gz
├── rhel_ansible_install.sh
└── sysctl_install.sh

```

스크립트 돌리는 순서

- rhel_ansible_install.sh repo.tar.gz
- common_settings.sh - `swap`  있을 경우 직접 제거 실행
- sysctl_install.sh
- nvidia_driver_install.sh - `kernel 쪽 설정 부분 떄문에 재부팅이 있어 두번 돌리면 됨`
- docker_install.sh

이 후 master node에서 token create 실행

```jsx
$ kubeadm token create --print-join-command
```

print 된 join command를 통해 worker 노드 추가 진행

이 후 master node에서 확인 하면 node가 추가 된 것을 확인 가능