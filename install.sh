#!/bin/sh

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

case "$os" in
    Linux)
        arch_check=$(arch)
    ;;
    Darwin)
        arch_check=$(uname -m)
    ;;
    *)
        echo " - [${YELLOW}$(current_time)${NO_COLOR}] ${RED}<Error>${NO_COLOR}: ${RED}Unknown or unsupported OS.${NO_COLOR}"
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
        echo " - [${YELLOW}$(current_time)${NO_COLOR}] ${RED}<Error>${NO_COLOR}: ${RED}Unknown or unsupported architecture.${NO_COLOR}"
        exit 1
    ;;
esac

# =========
# Check if id is 0
# =========

[ "$os" = "Linux" ] && {
    [[ $(grep -i Microsoft /proc/version) ]] && {
        echo " - [${YELLOW}$(current_time)${NO_COLOR}] ${RED}<Error>${NO_COLOR}: ${RED}WSL is not supported in this install script.${NO_COLOR}"
    }
}

[ "$(id -u)" -ne 0 ] && {
    echo " - [${YELLOW}$(current_time)${NO_COLOR}] ${YELLOW}<Warning>${NO_COLOR}: ${YELLOW}In order to use this script, run with root or use sudo.${NO_COLOR}"
    exit 1
}

# =========
# Run
# =========
