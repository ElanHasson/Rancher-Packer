# Apply updates and cleanup Apt cache
# packer build --var-file=variables.json ubuntu-2004.json
apt-get update ; apt-get -y dist-upgrade
apt-get -y autoremove
apt-get -y clean
# install iscsi 
apt-get install -y open-iscsi lsscsi iscsi-initiator-utils sg3_utils device-mapper-multipath
# enable multipathing
sudo tee /etc/multipath.conf <<-'EOF'
defaults {
    user_friendly_names yes
    find_multipaths yes
}
EOF

sudo systemctl enable multipath-tools.service

sudo service multipath-tools restart

sudo systemctl status multipath-tools

sudo systemctl enable open-iscsi.service

sudo service open-iscsi start

sudo systemctl status open-iscsi
5ghf5

#apt-get install --reinstall linux-modules-5.4.0-81-generic -y

# setup  ipvs

apt-get install -y ipvsadm 
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh




# Disable swap - generally recommended for K8s, but otherwise enable it for other workloads
echo "Disabling Swap"
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Reset the machine-id value. This has known to cause issues with DHCP
#
echo "Reset Machine-ID"
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# Reset any existing cloud-init state
#
echo "Reset Cloud-Init"
rm /etc/cloud/cloud.cfg.d/*.cfg
cloud-init clean -s -l

# Prevent cloud-init from setting IP
#
# echo "Disabling cloud-init networking"
# bash -c "echo 'network: {config: disabled}' > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg"

# echo "Removing existing Netplan config file"
# rm /etc/netplan/*.yaml


# Prevent cloud-init from setting IP -- Uncomment below lines if you want static ip setup via vApp Pool
#
# echo "Disabling cloud-init networking"
# bash -c "echo 'network: {config: disabled}' > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg"

# echo "Removing existing Netplan config file"
# rm /etc/netplan/*.yaml
