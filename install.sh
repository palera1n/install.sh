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
# Variables
# =========
alias current_time="date +'%m/%d/%y %H:%M:%S'"

os=$(uname)
latest_build=$(curl -s "https://api.github.com/repos/palera1n/palera1n/tags" | jq -r '.[].name' | grep -E "v[0-9]+\.[0-9]+\.[0-9]+-beta\.[0-9]+(\.[0-9]+)*$" | sort -V | tail -n 1)

echo " - [${DARK_GRAY}$(current_time)${NO_COLOR}] ${LIGHT_CYAN}<Info>${NO_COLOR}: ${LIGHT_CYAN}Using release tag ${latest_build}.${NO_COLOR}"

case "$os" in
    Linux)
        arch_check=$(arch)
    ;;
    Darwin)
        arch_check=$(uname -m)
    ;;
    *)
        echo " - [${DARK_GRAY}$(current_time)${NO_COLOR}] ${RED}<Error>${NO_COLOR}: ${RED}Unknown or unsupported OS.${NO_COLOR}"
        exit 1
    ;;
esac

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
        echo " - [${DARK_GRAY}$(current_time)${NO_COLOR}] ${RED}<Error>${NO_COLOR}: ${RED}Unknown or unsupported architecture.${NO_COLOR}"
        exit 1
    ;;
esac

echo " - [${DARK_GRAY}$(current_time)${NO_COLOR}] ${LIGHT_CYAN}<Info>${NO_COLOR}: ${LIGHT_CYAN}Found OS type ($os $arch).${NO_COLOR}"

# =========
# Check if id is 0
# =========

[ "$os" = "Linux" ] && {
    [[ $(grep -i Microsoft /proc/version) ]] && {
        echo " - [${DARK_GRAY}$(current_time)${NO_COLOR}] ${RED}<Error>${NO_COLOR}: ${RED}WSL is not supported in this install script.${NO_COLOR}"
    }
}

[ "$(id -u)" -ne 0 ] && {
    echo " - [${DARK_GRAY}$(current_time)${NO_COLOR}] ${YELLOW}<Warning>${NO_COLOR}: ${YELLOW}In order to use this script, run with root or use sudo.${NO_COLOR}"
    exit 1
}

# =========
# Run
# =========

echo " - [${DARK_GRAY}$(current_time)${NO_COLOR}] ${LIGHT_CYAN}<Info>${NO_COLOR}: ${LIGHT_CYAN}Fetching palera1n (${latest_build}) build for $os.${NO_COLOR}"
case "$os" in
    Linux)
        mkdir -p /usr/local/bin
        curl -Lo /usr/local/bin/palera1n "https://github.com/palera1n/palera1n/releases/download/${latest_build}/palera1n-linux-${arch}" > /dev/null 2>&1
        chmod +x /usr/local/bin/palera1n
    ;;
    Darwin)
        mkdir -p /usr/local/bin
        curl -Lo /usr/local/bin/palera1n "https://github.com/palera1n/palera1n/releases/download/${latest_build}/palera1n-macos-${arch}" > /dev/null 2>&1
        chmod +x /usr/local/bin/palera1n
    ;;
esac