Output:
# Script started

# Updating package lists
sudo apt update

# Installing Cockpit
sudo apt install cockpit -y

# Changing Cockpit default port to 5000
sudo sed -i 's/ListenStream=9090/ListenStream=5000/g' /lib/systemd/system/cockpit.socket

# Reloading systemd daemon to apply changes
sudo systemctl daemon-reload

# Restarting Cockpit service
sudo systemctl restart cockpit

# Cleaning apt cache
sudo apt clean

# Setting root password
echo "root:p@ssw0rd123" | sudo chpasswd

# Adding lines to sshd_config file
lines_to_add="ChallengeResponseAuthentication yes
PermitRootLogin yes
PasswordAuthentication yes"
sshd_config_file="/etc/ssh/sshd_config"
echo "$lines_to_add" | sudo tee -a "$sshd_config_file" > /dev/null

# Generating SSH keys
ssh-keygen -A

# Restarting SSH service
sudo service ssh restart

# Creating root directories with appropriate permissions
sudo mkdir -p /IN /temp
sudo chmod 755 /IN /temp
sudo chown root:root /IN
sudo chown root:root /temp

# Cleaning cloud-init logs and disabling cloud-init
sudo cloud-init clean --logs
sudo touch /etc/cloud/cloud-init.disabled

# Purging cloud-init and removing residual configurations
sudo apt purge cloud-init -y
sudo apt autoremove -y

# Ensuring /tmp is not cleared on reboot
sudo sed -i 's/D \/tmp 1777 root root -/#D \/tmp 1777 root root -/g' /usr/lib/tmpfiles.d/tmp.conf

# Adjusting open-vm-tools service to start after dbus
sudo sed -i 's/Before=cloud-init-local.service/After=dbus.service/g' /lib/systemd/system/open-vm-tools.service

# Cleaning SSH keys and regenerating them on reboot
sudo rm -f /etc/ssh/ssh_host_*
sudo tee /etc/rc.local >/dev/null <<EOL
#!/bin/sh -e
test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server
exit 0
EOL
sudo chmod +x /etc/rc.local

# Resetting machine-id for DHCP leases
echo "" | sudo tee /etc/machine-id >/dev/null

# Disabling swap for Kubernetes
sudo swapoff --all
sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab

# Cleaning shell history
history -c
history -w

# Script finished
