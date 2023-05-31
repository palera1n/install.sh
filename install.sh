#!/bin/sh
printf "\033c"
echo '# == palera1n-c install script =='
echo '#'
echo '# Made by: Samara, Staturnz'
echo '#'
echo ''

# =========
# Colors for output text
# =========

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
DARK_GRAY='\033[90m'
LIGHT_RED='\033[0;91m'
LIGHT_GREEN='\033[0;92m'
LIGHT_YELLOW='\033[0;93m'
LIGHT_BLUE='\033[0;94m'
LIGHT_PURPLE='\033[0;95m'
LIGHT_CYAN='\033[0;96m'
NO_COLOR='\033[0m'

# =========
# Logging
# =========

alias current_time="date +'%m/%d/%y %H:%M:%S'"

error() {
    echo " - [${DARK_GRAY}$(current_time)${NO_COLOR}] ${RED}<Error>${NO_COLOR}: ${RED}"$1"${NO_COLOR}"
}

info() {
    echo " - [${DARK_GRAY}$(current_time)${NO_COLOR}] ${LIGHT_CYAN}<Info>${NO_COLOR}: ${LIGHT_CYAN}"$1"${NO_COLOR}"
}

warning() {
    echo " - [${DARK_GRAY}$(current_time)${NO_COLOR}] ${YELLOW}<Warning>${NO_COLOR}: ${YELLOW}"$1"${NO_COLOR}"
}

# =========
# Check if id is 0
# =========

[ "$(id -u)" -ne 0 ] && {
    warning "In order to use this script, run with root or use sudo."
    exit 1
}

# =========
# Release version menu
# =========

function release_menu {
    ESC=$(printf "\033")
    on()          { printf "$ESC[?25h"; }
    off()         { printf "$ESC[?25l"; }
    to()          { printf "$ESC[$1;${2:-1}H"; }
    items()       { printf "   $1 "; }
    select_row()  { printf "  $ESC[7m $1 $ESC[27m"; }
    get_row()     { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }

    input() { 
        read -s -n3 key 2>/dev/null >&2
        if [[ $key = $ESC[A ]]; then echo up;    fi
        if [[ $key = $ESC[B ]]; then echo down;  fi
        if [[ $key = ""     ]]; then echo enter; fi; 
    }

    for opt; do printf "\n"; done
    local lastrow=`get_row`
    local startrow=$(($lastrow - $#))
    trap "on; stty echo; printf '\n'; exit" 2; off

    local selected=0
    while true; do
        local idx=0
        for opt; do
            to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then select_row "$opt"
            else items "$opt"; fi
            ((idx++))
        done

        case `input` in
            enter) break;;
            up) ((selected--)); if [ $selected -lt 0 ]; then selected=$(($# - 1));fi;;
            down) ((selected++));if [ $selected -ge $# ]; then selected=0;fi;;
        esac
    done

    to $lastrow; printf "\n"; on
    return $selected
}

# =========
# Variables
# =========

os=$(uname)
os_name="$os"

latest_build=$(curl -s "https://api.github.com/repos/palera1n/palera1n/tags" | jq -r '.[].name' | grep -E "v[0-9]+\.[0-9]+\.[0-9]+-beta\.[0-9]+(\.[0-9]+)*$" | sort -V | tail -n 1) 
download_version="$latest_build"

nightly_builds() {
    url="https://cdn.nickchan.lol/palera1n/artifacts/c-rewrite/main/"
    nightly_build=0
    html=$(curl -s "$url")
    nightly_build=$(echo "$html" | awk -F'href="' '!/\.+\// && $2{print $2}' | awk -F'/' 'NF>1{print $1}')
    export nightly_build
}

install_path="/usr/local/bin/palera1n"

# =========
# OS and Architecture
# =========

case "$os" in
    Linux)
        arch_check=$(arch)
        os_name="Linux"
    ;;
    Darwin)
        if [[ "$(uname -r | cut -d. -f1)" -gt "16" ]]; then
            os_name="macOS"
        elif [[ "$(uname -m)" == "iPhone"* ]] || [[ "$(uname -m)" == "iPad" ]]; then
            echo "Device seems like either an iPhone or iPad, aborting..."
            exit 1
        else
            os_name="Mac OS X"
        fi
    ;;
    *)
        error "Unknown or unsupported OS."
        exit 1
    ;;
esac

[ "$os" = "Linux" ] && {
    [[ $(grep -i Microsoft /proc/version) ]] && {
        error "Windows not really using for manipulating OSX images, compiled in mingw tool for this working unstable and incorrectly."
        exit 1
    }
}

case "$arch_check" in
    x86_64* | amd64)
        arch=x86_64
    ;;
    i?86 | x86*)
        arch=x86
    ;;
    aarch64* | arm64*)
        arch=arm64
    ;;
    arm*)
        arch=armel
    ;;
    *)
        error "Unknown or unsupported architecture."
        exit 1
    ;;
esac

info "Found OS type ($os_name $arch)."

# =========
# Run
# =========

case "$1" in
    "--list"|"-l")
        info "Use the Up/Down arrow keys to select a release, then press enter to install.\n"
        options=("v2.0.0-beta.5" "v2.0.0-beta.6.2" "v2.0.0-beta.7")
        release_menu "${options[@]}"
        choice=$?
        download_version="${options[$choice]}"
    ;;
    "--nightly"|"-n")
        nightly_builds
        info "Use the Up/Down arrow keys to select a release, then press enter to install.\n"
        options=($nightly_build)
        release_menu "${options[@]}"
        choice=$?
        download_version="${options[$choice]}"
    ;;
    *)
        download_version="${latest_build}"
    ;;
esac


info "Using release tag ${download_version}."
info "Fetching palera1n (${download_version}) build for ($os_name $arch)."

mkdir -p /usr/local/bin
case "$os" in
    Linux)
        mkdir -p /usr/local/bin
        if [[ $1 == "--nightly" || $1 == "-n" ]]; then
            curl -Lo $install_path "https://cdn.nickchan.lol/palera1n/artifacts/c-rewrite/main/${download_version}/palera1n-linux-${arch}" > /dev/null 2>&1
        else
            curl -Lo $install_path "https://github.com/palera1n/palera1n/releases/download/${download_version}/palera1n-linux-${arch}" > /dev/null 2>&1
        fi
        chmod +x $install_path
    ;;
    Darwin)
        mkdir -p /usr/local/bin
        if [[ $1 == "--nightly" || $1 == "-n" ]]; then
            curl -Lo /usr/local/bin/palera1n "https://cdn.nickchan.lol/palera1n/artifacts/c-rewrite/main/${download_version}/palera1n-macos-${arch}" > /dev/null 2>&1
        else
            curl -Lo /usr/local/bin/palera1n "https://github.com/palera1n/palera1n/releases/download/${download_version}/palera1n-macos-${arch}" > /dev/null 2>&1
        fi
        chmod +x $install_path
    ;;
esac


if [ -f "$install_path" ]; then
    info "palera1n is now installed at ${install_path}"
else 
    error "palera1n failed to install. Please check your internet connection and try again."
    exit 1
fi
