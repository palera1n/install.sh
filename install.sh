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

# =========
# Check if id is 0
# =========

[ "$(id -u)" -ne 0 ] && {
    current_time=$(date +"%m/%d/%y %H:%M:%S")
    echo " - [${YELLOW}$current_time${NO_COLOR}] ${YELLOW}<Warning>${NO_COLOR}: ${YELLOW}In order to use this script, run with root or use sudo.${NO_COLOR}"
    exit 1
}

# =========
# Run
# =========
