FROM cr.makina.rocks/external-hub/ubuntu:22.04.5-lts

ENV HELMFILE_VER=0.169.1
ENV KUBE_VER=1.27

WORKDIR /opt

RUN mkdir -p /opt/helmfile_deb
RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y git curl gpg
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null && apt-get install apt-transport-https --yes && echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${KUBE_VER}/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
COPY apt-get-install.sh .
RUN apt-get update && sh apt-get-install.sh
RUN mkdir -p helmfile_deb/usr/bin && mkdir -p helmfile_deb/DEBIAN && mkdir -p helmfile_deb/root
COPY control helmfile_deb/DEBIAN
RUN ARCH=$(dpkg --print-architecture) && curl -L https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VER}/helmfile_${HELMFILE_VER}_linux_${ARCH}.tar.gz | tar -xz && ./helmfile init --force && cp -a helmfile helmfile_deb/usr/bin && cp -a /root/.local helmfile_deb/root/ && mv helmfile_deb helmfile_${HELMFILE_VER}_linux_${ARCH} && dpkg-deb --build helmfile_${HELMFILE_VER}_linux_${ARCH}
RUN ARCH=$(dpkg --print-architecture) && rm -rf /root/.local && apt-get install -y ./helmfile_${HELMFILE_VER}_linux_${ARCH}.deb && cp -a ./helmfile_${HELMFILE_VER}_linux_${ARCH}.deb /var/cache/apt/archives
WORKDIR /var/cache/apt/archives
RUN dpkg-scanpackages . /dev/null | gzip -9c >/opt/Packages.gz
WORKDIR /var/cache/apt
COPY create-apt-get-install-with-version.sh .
RUN bash create-apt-get-install-with-version.sh >/opt/apt-get-install-with-version.sh
