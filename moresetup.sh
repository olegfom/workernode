#!/bin/bash

sleep 10
apt-get install -y linux-image-$(uname -r)
systemctl daemon-reload
systemctl stop supervisor
rm /var/log/supervisor/*
systemctl enable docker
systemctl restart docker
openvpn --config /data/cluster_client.ovpn --pull-filter ignore redirect-gateway &
