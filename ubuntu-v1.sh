#!/bin/bash

# Remove any unique identifiers
sudo rm /etc/udev/rules.d/70-persistent-net.rules
sudo rm /etc/machine-id
sudo rm /var/lib/dbus/machine-id

# Remove any SSH host keys
sudo rm /etc/ssh/ssh_host_*

# Remove any cloud-init data
sudo rm /var/lib/cloud/*

# Remove any logs
sudo rm /var/log/* -rf

# Remove any network configuration
sudo rm /etc/netplan/*

# Remove any hostname and hosts entries
sudo sed -i '/^127.0.1.1/d' /etc/hosts
sudo hostnamectl set-hostname "ubuntu"

# Remove any user accounts and home directories
sudo userdel -r -f $(ls /home)

# Update and clean package manager
sudo apt update
sudo apt full-upgrade -y
sudo apt autoremove -y
sudo apt clean

# Zero out any free space
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm /EMPTY
