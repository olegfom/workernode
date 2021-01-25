# workernode
Kubernetes worker node inside docker container (work in progress)

Note: while using systemd, kubelet keeps restarting. The errors are related to /sys/fs/cgroup kubepods.
user: root, no password.

Run the container:
sudo docker run --rm -it --name systemd --security-opt seccomp=unconfined --tmpfs /run --tmpfs /run/lock --tmpfs /dev/shm --tmpfs /tmp  -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v ~/Downloads/data:/data -v /media/liveuser/usbdata/docker-containers/etc/cni:/etc/cni -v /media/liveuser/usbdata/docker-containers/etc_docker:/etc/docker -v /media/liveuser/usbdata/docker-containers/var_lib_docker:/var/lib/docker -v /media/liveuser/usbdata/docker-containers/var_lib_kubelet:/var/lib/kubelet -v /media/liveuser/usbdata/docker-containers/var_log:/var/log -p 8088:8088 --privileged --cap-add=NET_ADMIN olegfom/workernode

