#!/bin/bash

# Set root password
echo 'root:p@ssw0rd123' | sudo chpasswd

# Update and install Cockpit
sudo apt update
sudo apt install cockpit -y
sudo systemctl start cockpit
sudo systemctl status cockpit

# Create directories
sudo mkdir -p /IN
sudo chown root:admin /IN
sudo chmod 770 /IN
sudo mkdir /temp
sudo chmod 777 /temp

# Edit SSH config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# Clean cloud-init
sudo cloud-init clean --logs
sudo touch /etc/cloud/cloud-init.disabled
sudo rm -rf /etc/netplan/*.yaml
sudo apt purge cloud-init -y
sudo apt autoremove -y

# Modify tmp settings
sudo sed -i 's/D \/tmp 1777 root root -/#D \/tmp 1777 root root -/g' /usr/lib/tmpfiles.d/tmp.conf

# Modify open-vm-tools service
sudo sed -i 's/Before=cloud-init-local.service/After=dbus.service/g' /lib/systemd/system/open-vm-tools.service

# Cleanup SSH keys
sudo rm -f /etc/ssh/ssh_host_*

# Add SSH key check on reboot
sudo tee /etc/rc.local >/dev/null <<EOL
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#

# By default this script does nothing.
test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server
exit 0
EOL

# Make rc.local executable
sudo chmod +x /etc/rc.local

# Clean up apt
sudo apt clean

# Reset machine-id
echo "" | sudo tee /etc/machine-id >/dev/null

# Disable swap for Kubernetes
sudo swapoff --all
sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

# Cleanup shell history and shutdown
history -c
history -w
sudo shutdown -h now
