virt-clone --connect=qemu:///system -o rhel-vm-01 -n rhel-vm-clone-01 -f rhel-vm-clone-01.img --clone-running --force -q

virt-edit -c qemu:///system mydomain -b .ori /etc/inittab -e 's/^id:.*/id:5:initdefault:/'

virt-edit -c qemu:///system mydomain -b .ori -e /etc/.ssh/know_hosts 's/.*//g'

virt-edit -c qemu:///system mydomain -b .ori -e /etc/hosts 's/vm*$/novo_host_name/g'

virt-edit -c qemu:///system mydomain -b .ori -e /etc/sysconfig/network 's/HOSTNAME=.*$/HOSTNAME=novo_host_name/g'

virt-edit -c qemu:///system mydomain -b .ori -e /etc/sysconfig/network-scripts/ifcfg-eth0 's/HWDAADDR=.*$/HWAADDR=novo_host_name/g'

/etc/libvirt/qemu/rhel-vm-01.xml 

<mac address='52:54:00:d1:69:fa'/>

