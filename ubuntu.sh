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

# Define the path to the sshd_config file
sshd_config="/etc/ssh/sshd_config"

# Check if the sshd_config file exists
if [ ! -f "$sshd_config" ]; then
    echo "Error: sshd_config file not found at $sshd_config"
    exit 1
fi

# Function to enable or update SSH config options
enable_ssh_option() {
    local option_name=$1
    local option_value=$2

    # Check if the option is already enabled
    if grep -q "^$option_name $option_value" "$sshd_config"; then
        echo "$option_name is already set to $option_value."
    else
        # Add or update the option
        if ! grep -q "^$option_name" "$sshd_config"; then
            echo "$option_name $option_value" >> "$sshd_config"
        else
            sed -i "s/^$option_name.*/$option_name $option_value/" "$sshd_config"
        fi
        echo "$option_name has been set to $option_value."
    fi
}

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

# Enable ChallengeResponseAuthentication
enable_ssh_option "ChallengeResponseAuthentication" "yes"

# Enable PasswordAuthentication
enable_ssh_option "PasswordAuthentication" "yes"

# Restart SSH service to apply changes
sudo systemctl restart ssh

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
