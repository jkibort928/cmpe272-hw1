#!/usr/bin/env bash

# Source: Google Search AI / Gemini

# VM CONFIG
TEMP_CFG="/tmp/vm-data.cfg"

cat << EOF > "$TEMP_CFG"
#cloud-config
chpasswd:
  list: |
    ubuntu:ubuntu
  expire: false
users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - $(cat ~/.ssh/id_ed25519.pub)
EOF

# NET CONFIG
NET_CFG_VM1="/tmp/network-config-vm1.cfg"
NET_CFG_VM2="/tmp/network-config-vm2.cfg"

# Network config for VM 1 (IP: 192.168.122.11)
cat << EOF > "$NET_CFG_VM1"
version: 2
ethernets:
  enp1s0:
    dhcp4: false
    addresses:
      - 192.168.122.11/24
    routes:
      - to: default
        via: 192.168.122.1
    nameservers:
      addresses: [192.168.122.1, 8.8.8.8]
EOF

# Network config for VM 2 (IP: 192.168.122.12)
cat << EOF > "$NET_CFG_VM2"
version: 2
ethernets:
  enp1s0:
    dhcp4: false
    addresses:
      - 192.168.122.12/24
    routes:
      - to: default
        via: 192.168.122.1
    nameservers:
      addresses: [192.168.122.1, 8.8.8.8]
EOF


# VM 1
sudo virt-install \
  --connect qemu:///system \
  --name webserver-vm1 \
  --memory 2048 \
  --vcpus 2 \
  --disk size=20,backing_store=$(pwd)/wkdir/noble-server-cloudimg-amd64.img \
  --os-variant ubuntunoble \
  --network network=default \
  --cloud-init user-data="$TEMP_CFG",network-config="$NET_CFG_VM1" \
  --graphics none \
  --noautoconsole

# VM 2
sudo virt-install \
  --connect qemu:///system \
  --name webserver-vm2 \
  --memory 2048 \
  --vcpus 2 \
  --disk size=20,backing_store=$(pwd)/wkdir/noble-server-cloudimg-amd64.img \
  --os-variant ubuntunoble \
  --network network=default \
  --cloud-init user-data="$TEMP_CFG",network-config="$NET_CFG_VM2" \
  --graphics none \
  --noautoconsole

rm -f "$TEMP_CFG" "$NET_CFG_VM1" "$NET_CFG_VM2"
