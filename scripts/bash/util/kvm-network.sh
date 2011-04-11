#!/bin/bash

KVMNET_UID=1000
KVMNET_GID=$(grep kvm /etc/group | cut -d ':' -f 3)

# number of TUN/TAP devices to setup
NUM_OF_DEVICES=3

case $1 in
        start)
                modprobe kvm
                modprobe kvm_intel

                modprobe tun
                echo "Setting up bridge device br0"
                brctl addbr br0
                ifconfig br0 192.168.100.254 netmask 255.255.255.0 up
                for ((i=0; i < NUM_OF_DEVICES ; i++)); do
                        echo -n "Setting up "
                        tunctl -b -g ${KVMNET_GID} -t kvmnet$i
                        #tunctl -b -u ${KVMNET_UID} -t kvmnet$i
                        brctl addif br0 kvmnet$i
                        ifconfig kvmnet$i up 0.0.0.0 promisc
                done
                #/etc/init.d/iptables restart
        ;;
        stop)
                for ((i=0; i < NUM_OF_DEVICES ; i++)); do
                        ifconfig kvmnet$i down
                        brctl delif br0 kvmnet$i
                        tunctl -d kvmnet$i
                done
                ifconfig br0 down
                brctl delbr br0
                #/etc/init.d/iptables restart

                rmmod kvm_intel
                rmmod kvm
        ;;
        *)
                echo "Usage: $(basename $0) (start|stop)"
        ;;
esac
