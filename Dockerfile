FROM jrei/systemd-ubuntu:20.04
MAINTAINER oleg.fominykh@worldinfolinks.com

# ARG DEBIAN_FRONTEND noninteractive
# RUN echo 'Acquire::http::Proxy "http://192.168.2.69:3142";'  > /etc/apt/apt.conf.d/01proxy
RUN apt-get update && apt-get install -y wget apt-transport-https


RUN apt-get install -y language-pack-en
RUN update-locale LANG=en_US.UTF-8

RUN apt-get update && apt-get install -y wget software-properties-common

RUN apt-get install -y apt-utils
RUN apt-get install -y iputils-ping
RUN apt-get install -y stun-client

RUN apt-get update && apt-get -y dist-upgrade

#Install Docker
RUN apt-get install -y docker.io
RUN dpkg-query -L docker.io

RUN apt-get install -y curl

RUN apt-get install -y ca-certificates 
RUN apt-get install -y software-properties-common 
RUN apt-get install -y gnupg2
RUN apt-get install -y apt-transport-https 
#RUN apt-get install -y aufs-tools   # Locks up
RUN apt-get install -y debootstrap 
RUN apt-get install -y docker-doc 
RUN apt-get install -y rinse 
RUN apt-get install -y zfs-fuse
RUN apt-get install -y net-tools

RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get autoremove -y

RUN echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list 

RUN chmod 644 /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update

RUN apt-get install -y libip4tc2 libip6tc2 libxtables12 libiptc0
RUN apt-get install -y iptables ebtables  --allow-downgrades
RUN apt-get install -qy kubelet kubectl kubeadm --reinstall
RUN apt-mark hold kubelet kubeadm kubectl

RUN apt-get install -y iptables ufw

RUN apt-get install -y net-tools
RUN apt-get install -y openvpn
RUN apt-get install -y nfs-common
RUN apt-get install -y vim

# -- Finish startup
RUN sed -i "s/root:\*/root:U6aMy0wojraho/" /etc/shadow

RUN mkdir /var/lib/kubelet
ADD setup.sh /root/setup.sh
ADD moresetup.sh /root/moresetup.sh
ADD join_cluster.sh /root/join_cluster.sh

RUN systemctl set-default multi-user.target

ENTRYPOINT ["/root/setup.sh"]

CMD []
