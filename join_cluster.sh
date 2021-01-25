#!/bin/bash

	systemctl restart docker
	 kubeadm reset --force
	 ip link set cni0 down
	 brctl delbr cni0

      export MASTER_NODE='10.8.0.1'
      export MASTER_NODE_NAME=$(echo ${MASTER_NODE}  )
	echo "MASTER_NODE_NAME="${MASTER_NODE_NAME}

        export WORKER_NODE_NAME=$(ifconfig | grep -e "inet 10.8" | grep -o "inet 10.8.[0-9]*\.[0-9]*" | sed 's/inet /workernode-/' | sed 's/\./-/g' )

	echo "WORKER_NODE_NAME="${WORKER_NODE_NAME}
     

	#Change hostname for kubernetes 
	hostnamectl set-hostname ${WORKER_NODE_NAME}


	#Copy ~/.kube from master to worker
	umount /root/Downloads/kube-config 2>/dev/null
	rm -Rf /root/Downloads/kube-config 2>/dev/null
	mkdir -p /root/Downloads/kube-config


	export OPENVPN="True"

	mount -t nfs ${MASTER_NODE_NAME}:/media/liveuser/usbdata/kube-config /root/Downloads/kube-config
	cp /root/Downloads/kube-config/* /root/
	mkdir -p /root/.kube
	cp /root/Downloads/kube-config/.kube/config /root/.kube/config
	chown -R root:root /root/.kube
	umount /root/Downloads/kube-config 2>/dev/null
	rm -Rf /root/Downloads/kube-config 2>/dev/null
	
	mkdir -p /run/systemd/resolve
	cp /etc/resolv.conf /run/systemd/resolve/resolv.conf
	
	sed -i 's/\"--network-plugin=cni/\"--v=10 --network-plugin=cni/' /var/lib/kubelet/kubeadm-flags.env


cat <<EOF | tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "insecure-registries":[
  "${MASTER_NODE_NAME}:5000"
  ]
}
EOF


systemctl stop docker
systemctl restart docker



	cat /root/joincommand.sh |  sh
	

	
	for i in {10..1}; do echo -ne "$i"'\r'; sleep 1; done; echo
	
	
	KUBELET_EXTRA_ARGS=""
	#cleanup
	 sed -i '/Environment=\"KUBELET_EXTRA_ARGS=/d' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
	#check OpenVPN IP address
        if [ ! -z "${OPENVPN}" ] ; then
		VPN_NODE_IP=$(ifconfig tun0 2>/dev/null | grep -e "inet " | awk '{print $2}')
	 	sed -i 's/server: https:\/\/[0-9]*.[0-9]*.[0-9]*.[0-9]*/server: https:\/\/10\.8\.0\.1/' /etc/kubernetes/kubelet.conf
	fi
	if [ ! -z "${VPN_NODE_IP}" ] ; then
		KUBELET_EXTRA_ARGS=${KUBELET_EXTRA_ARGS}' --node-ip='${VPN_NODE_IP} 
	fi
        #enable Swap partition
        CHECK_IF_SWAPPING_ALLOWED=$( cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf | grep  -e "--fail-swap-on=false")
        if [ -z "${CHECK_IF_SWAPPING_ALLOWED}" ] ; then
		KUBELET_EXTRA_ARGS=${KUBELET_EXTRA_ARGS}' --fail-swap-on=false'
	fi
	KUBELET_EXTRA_ARGS=${KUBELET_EXTRA_ARGS}' --cgroup-driver=systemd '
        if [ ! -z "${KUBELET_EXTRA_ARGS}" ] ; then
		  sed -i "s/KUBELET_EXTRA_ARGS should be sourced from this file\./&\nEnvironment=\"KUBELET_EXTRA_ARGS=${KUBELET_EXTRA_ARGS}\"/" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
	fi
	
	 systemctl daemon-reload
	 systemctl restart kubelet
	 systemctl restart docker
