ARCH=amd64
VER=0.169.1
cat <<EOF >control
Package: helmfile
Version: ${VER}
Architecture: ${ARCH}
Maintainer: Sangwoo Shim <sangwoo@makinarocks.ai>
Description: Helmfile package
Depends: git, helm
EOF
docker build . -t helmfile_builder --platform=linux/${ARCH}
docker run --rm --platform=linux/${ARCH} --entrypoint "/bin/bash" helmfile_builder -c 'tar -cz /var/cache/apt/archives/*.deb' | tar -xz --strip-components 3
docker run --rm --platform=linux/${ARCH} --entrypoint "/bin/bash" helmfile_builder -c 'cat /opt/Packages.gz' >archives/Packages.gz
docker run --rm --platform=linux/${ARCH} --entrypoint "/bin/bash" helmfile_builder -c 'cat /opt/apt-get-install-with-version.sh' >apt-get-install-with-version.sh
