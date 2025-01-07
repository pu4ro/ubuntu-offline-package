pvcreate /dev/sdb
vgcreate cephvg /dev/sdb
lvcreate -n cephlv_0 -l 100%FREE cephvg
