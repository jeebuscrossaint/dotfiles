#!/usr/bin/env bash

# check if bash exist

bash_exist() {
    if [ -z "$(which bash)" ]; then
        echo "bash is not installed"
        exit 1
    fi
}

# check if git exist

git_exist() {
    if [ -z "$(which git)" ]; then
        echo "git is not installed"
        exit 1
    fi
}

determine_distro() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        distro=$NAME
    elif [ -f /etc/lsb-release ]; then
        source /etc/lsb-release
        distro=$DISTRIB_ID
    elif [ -f /etc/debian_version ]; then
        distro="Debian"
    elif [ -f /etc/redhat-release ]; then
        distro="Red Hat"
    else
        distro="Unknown"
    fi

    echo "Linux distribution: $distro"
}

# check if sudo or doas exist or running as root

root_privilege() {
    if [ -z "$(which sudo)" ] && [ -z "$(which doas)" ]; then
        if [ "$(id -u)" -ne 0 ]; then
            echo "Please run as root"
            exit 1
        fi
    fi
}

# install basic packages w/ quick setup

update_sys() {
    sudo xbps-install -Su
    sudo xbps-remove -Oo
    printf "Make sure to see if you have a new kernel and config and initramfs and whatnot in your /boot directory\n"
}

# setup environment (basics)

setup_env() {
    sudo ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
    sudo ln -s /etc/sv/ntpd /var/service
    sudo ln -s /etc/sv/dhcpcd /var/service
    sudo ln -s /etc/sv/polkitd /var/service
    sudo ln -s /etc/sv/dbus /var/service
    
}