#!/usr/bin/env bash\
# Check if the script is running as root

function is_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "This script must be run as root"
        exit 1
    fi
}

function bash_avail() {
    if [ -f ~/.bashrc ]; then
        echo "\n"
    else
        echo "Please install bash first!"
    fi
}

function refind_avail() {
    if [ -f (which refind-install) ]; then
        echo "\n"
    else
        echo "Please install refind first!"
    fi
}

function git_avail() {
    if [ -f (which git) ]; then
        echo "\n"
    else
        echo "Please install git first!"
    fi
}

function curl_avail() {
    if [ -f (which curl) ]; then
        echo "\n"
    else
        echo "Please install curl first!"
    fi
}

function wget_avail() {
    if [ -f (which wget) ]; then
        echo "\n"
    else
        echo "Please install wget first!"
    fi
}

function xbps_avail() {
    if [ -f (which xbps-install) ]; then
        echo "\n"
    else
        echo "Please install xbps first!"
    fi
}

function remove_grub() {
    
}



