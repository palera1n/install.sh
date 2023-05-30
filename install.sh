#!/bin/sh

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
# Variables
# =========

os=$(uname)

latest_build=$(curl -s "https://api.github.com/repos/palera1n/palera1n/tags" | jq -r '.[].name' | grep -E "v[0-9]+\.[0-9]+\.[0-9]+-beta\.[0-9]+(\.[0-9]+)*$" | sort -V | tail -n 1)
info "Using release tag ${latest_build}."

# =========
# OS and Architecture
# =========

case "$os" in
    Linux)
        arch_check=$(arch)
    ;;
    Darwin)
        arch_check=$(uname -m)
    ;;
    *)
        error "Unknown or unsupported OS."
        exit 1
    ;;
esac

[ "$os" = "Linux" ] && {
    [[ $(grep -i Microsoft /proc/version) ]] && {
        error "WSL is not supported in this install script."
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

info "Found OS type ($os $arch)."

# =========
# Run
# =========

show_menu() {
    echo
    echo " ╭────────────────╮ "
    echo " │ 1) Latest      │ "
    echo " │ 2) Nightly     │ "
    echo " │ 3) Experiments │ "
    echo " ├────────────────┤ "
    echo " │ 0) Exit        │ "
    echo " ╰────────────────╯ "
}

handle_choice() {
    case $key in
        1)
            echo "You selected Option 1."
            # ...
            ;;
        2)
            echo "You selected Option 2."
            # ...
            ;;
        3)
            echo "You selected Option 3."
            # ...
            ;;
        0)
            echo "Exiting..."
            exit 1
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
}

show_menu
read -n 1 -s -r -p "Press a key to select an option: " key
handle_choice
echo

case $key in
    1) handle_choice 1 ;;
    2) handle_choice 2 ;;
    3) handle_choice 3 ;;
    0) handle_choice 0 ;;
    *) handle_choice ;;
esac

# echo " - [${DARK_GRAY}$(current_time)${NO_COLOR}] ${LIGHT_CYAN}<Info>${NO_COLOR}: ${LIGHT_CYAN}Fetching palera1n (${latest_build}) build for $os.${NO_COLOR}"
# case "$os" in
#     Linux)
#         mkdir -p /usr/local/bin
#         curl -Lo /usr/local/bin/palera1n "https://github.com/palera1n/palera1n/releases/download/${latest_build}/palera1n-linux-${arch}" > /dev/null 2>&1
#         chmod +x /usr/local/bin/palera1n
#     ;;
#     Darwin)
#         mkdir -p /usr/local/bin
#         curl -Lo /usr/local/bin/palera1n "https://github.com/palera1n/palera1n/releases/download/${latest_build}/palera1n-macos-${arch}" > /dev/null 2>&1
#         chmod +x /usr/local/bin/palera1n
#     ;;
# esac