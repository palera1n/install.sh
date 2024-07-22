#!/usr/bin/env sh

printf '%b' "\033c"
printf '%s\n' '#'
printf '%s\n' '# palera1n install script'
printf '%s\n' '#'
printf '%s\n' '# ========  Made by  ======='
printf '%s\n' '# Samara, Staturnz'
printf '%s\n' '# =========================='
printf '%s\n' ''

RED='\033[0;31m'
YELLOW='\033[0;33m'
DARK_GRAY='\033[90m'
LIGHT_CYAN='\033[0;96m'
DARK_CYAN='\033[0;36m'
NO_COLOR='\033[0m'
BOLD='\033[1m'

# =========
# Logging
# =========

error() {
    printf '%b\n' " - [${DARK_GRAY}$(date +'%m/%d/%y %H:%M:%S')${NO_COLOR}] ${RED}${BOLD}<Error>${NO_COLOR}: ${RED}$1${NO_COLOR}"
}

info() {
    printf '%b\n' " - [${DARK_GRAY}$(date +'%m/%d/%y %H:%M:%S')${NO_COLOR}] ${DARK_CYAN}${BOLD}<Info>${NO_COLOR}: ${DARK_CYAN}$1${NO_COLOR}"

}

warning() {
    printf '%b\n' " - [${DARK_GRAY}$(date +'%m/%d/%y %H:%M:%S')${NO_COLOR}] ${YELLOW}${BOLD}<Warning>${NO_COLOR}: ${YELLOW}$1${NO_COLOR}"
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
os_name="$os"
install_path="/usr/local/bin/palera1n"
china="$(echo $LANG | grep -q CN && echo 1)"

download() {
    status=$(curl --progress-bar --write-out '%{http_code}' -Lo $install_path "$1")

    if [ "$status" -ne 200 ]; then
        error "palera1n failed to download. Please check your internet connection and try again. (Status: $status)"
        exit 1
    fi
}

remove_palera1n() {
    if [ -e "${install_path}" ]; then
        rm ${install_path}
        info "palera1n was successfully removed from ${install_path}."
    else
        error "palera1n is not installed at ${install_path}."
        exit 1
    fi
}

print_help() {
    cat << EOF
Usage: $0 [-hlnr]

Options:
    -h, --help          Print this help
    -r, --remove        Uninstall palera1n
EOF
}

# =========
# Dependancies
# =========

case "$os" in
    Linux)
        if ! command -v curl >/dev/null 2>&1; then
            error "If you want to use this script, please install curl."
            exit 1
        fi
    ;;
esac

# =========
# OS and Architecture
# =========

case "$os" in
    Linux)
        arch_check=$(uname -m)
        os_name="Linux"
    ;;
    Darwin)
        if [ "$(uname -r | cut -d. -f1)" -gt "15" ]; then
            os_name="macOS"
        elif [ "$(uname -m | head -c2)" = "iP" ]; then
            error "palera1n install script is not meant to used on iOS devices. Please use on a PC."
            exit 1
        else
            os_name="Mac OS X"
        fi
        arch_check=$(uname -m)
    ;;
    *)
        error "Unknown or unsupported OS ($os)."
        exit 1
    ;;
esac

[ "$os" = "Linux" ] && {
    grep -qi Microsoft /proc/version > /dev/null 2>&1 && {
        error "palera1n is not supported on WSL. Please use another supported platform."
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
        error "Unknown or unsupported architecture ($arch_check)."
        exit 1
    ;;
esac

# =========
# Args
# =========

case "$1" in
    "" ) ;;
    "-r" | "--remove" | "--help" | "-h" ) ;;
    * )
        error "Invalid option: \"$1\""
        exit 1
        ;;
esac

case "$1" in
    "--remove" | "-r")
        remove_palera1n
        exit 0
    ;;
    "--help" | "-h")
        print_help
        exit 1
    ;;
    *)
	if [ "$china" = "1" ]; then
	        download_version=$(curl -s https://cdn.nickchan.lol/palera1n/c-rewrite/releases/ | grep 'a href="v' | grep -v beta | tail -n1 | cut -d'>' -f2 | cut -d/ -f1)
	else
                download_version=$(curl -s https://api.github.com/repos/palera1n/palera1n/releases | grep -m 1 -o '"tag_name": "[^"]*' | sed 's/"tag_name": "//')
	fi
        info "Using release tag ${download_version}."
    ;;
esac

info "Found OS type ($os_name $arch)."

# =========
# Run
# =========

if [ "$china" = "1" ]; then
	download_suffix="binaries/"
	download_prefix="https://cdn.nickchan.lol/palera1n/c-rewrite/releases"
else
	download_prefix="https://github.com/palera1n/palera1n/releases/download"
fi

info "Fetching palera1n (${prefix}${download_version}) build for ($os_name $arch)."
mkdir -p /usr/local/bin
rm /usr/local/bin/palera1n > /dev/null 2>&1

case "$os" in
    Linux)
        download "${download_prefix}/${download_version}/${download_suffix}palera1n-linux-${arch}"
    ;;
    Darwin)
        download "${download_prefix}/${download_version}/${download_suffix}palera1n-macos-${arch}"
    ;;
esac

if [ -f "$install_path" ]; then
    chmod +x $install_path

    if ! palera1n --version  > /dev/null 2>&1;
    then
        error "palera1n installation is corrupted. Please check your internet connection and try again."
        exit 1
    fi

    info "palera1n is now installed at ${install_path}."
else 
    error "palera1n failed to install. Please check your internet connection and try again."
    exit 1
fi
