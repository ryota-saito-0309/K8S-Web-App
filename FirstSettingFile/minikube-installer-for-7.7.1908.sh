#! /bin/sh

# Modify yum.conf
sed -i -e "/timeout\=/d" /etc/yum.conf
sed -i -e "13s/^/timeout=300\n/g" /etc/yum.conf
sed -i -e "/ip_resolve\=/d" /etc/yum.conf
sed -i -e "14s/^/ip_resolve=4\n/g" /etc/yum.conf

# Add .curlrc
cat <<-EOF > ~/.curlrc
ipv4
EOF

# Install conntrack
yum install -y \
  conntrack-tools-1.4.4

# Install "Docker"
yum install -y \
  yum-utils-1.1.31 \
  device-mapper-persistent-data-0.8.5 \
  lvm2-2.02.185

yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

yum install -y \
  docker-ce-19.03.8 \
  docker-ce-cli-19.03.8 \
  containerd.io-1.2.13

systemctl enable docker
systemctl start docker

# Install "kubectl"
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv -f ./kubectl /usr/local/bin

# Install "minikube"
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.9.1/minikube-linux-amd64
chmod +x minikube
install minikube /usr/local/bin

# stop firewall
systemctl disable firewalld
systemctl stop firewalld

# Add addons
minikube start --vm-driver=none
minikube addons enable heapster
minikube addons enable ingress
