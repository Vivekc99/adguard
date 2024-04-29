#!/bin/bash

# Install Cockpit
sudo apt update
sudo apt install cockpit -y

# Change Cockpit default port to 5000
sudo sed -i 's/ListenStream=9000/ListenStream=5000/g' /lib/systemd/system/cockpit.socket

# Reload systemd daemon to apply changes
sudo systemctl daemon-reload

# Restart Cockpit service
sudo systemctl restart cockpit

# Cleanup apt cache
sudo apt clean

# Set root password
echo "root:p@ssw0rd123" | sudo chpasswd

# Define the lines to add
lines_to_add="ChallengeResponseAuthentication yes
PermitRootLogin yes
PasswordAuthentication yes"

# Path to the sshd_config file
sshd_config_file="/etc/ssh/sshd_config"

# Add the lines to the sshd_config file
echo "$lines_to_add" | sudo tee -a "$sshd_config_file" > /dev/null


# Restart SSH service
sudo service ssh restart

# Create root directories with appropriate permissions
sudo mkdir -p /IN /temp
sudo chmod 755 /IN /temp
sudo chown root:root /IN
sudo chown root:root /temp

# Clean cloud-init logs and disable cloud-init
sudo cloud-init clean --logs
sudo touch /etc/cloud/cloud-init.disabled

# Purge cloud-init and remove residual configurations
sudo apt purge cloud-init -y
sudo apt autoremove -y

# Ensure /tmp is not cleared on reboot
sudo sed -i 's/D \/tmp 1777 root root -/#D \/tmp 1777 root root -/g' /usr/lib/tmpfiles.d/tmp.conf

# Adjust open-vm-tools service to start after dbus
sudo sed -i 's/Before=cloud-init-local.service/After=dbus.service/g' /lib/systemd/system/open-vm-tools.service

# Cleanup SSH keys and regenerate them on reboot
sudo rm -f /etc/ssh/ssh_host_*
sudo tee /etc/rc.local >/dev/null <<EOL
#!/bin/sh -e
test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server
exit 0
EOL
sudo chmod +x /etc/rc.local

# Reset machine-id for DHCP leases
echo "" | sudo tee /etc/machine-id >/dev/null

# Disable swap for Kubernetes
sudo swapoff --all
sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

# Cleanup shell history
history -c
history -w

# Shutdown the system
#sudo shutdown -h now
