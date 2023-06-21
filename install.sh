#!/usr/bin/env sh

printf '%b' "\033c"
printf '%s\n' '# == palera1n-c install script =='
printf '%s\n' '#'
printf '%s\n' '# Made by: Samara, Staturnz'
printf '%s\n' '#'
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

download() {
    status=$(curl --write-out '%{http_code}' -sLo $install_path "$1")

    if [ "$status" -ne 200 ]; then
        error "palera1n failed to download. Please check your internet connection and try again. (Status: $status)"
        exit 1
    fi
}

print_help() {
    cat << EOF
Usage: $0 [-hln]

Options:
    -h, --help          Print this help
    -l, --list          List release builds of palera1n 
    -n, --nightly       List nightly builds of palera1n 'Advanced users only'
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
# Release version menu
# =========

menu() {
    info "Please select the version of palera1n you want to install below."
    IFS=' '; export IFS; set -- $1; i=1; printf '%s\n' "";
    printf '%s\n' " ╭──────────────────╮ "

    while [ "$i" -ne "$(($# + 1))" ]; do
        current_option="$(eval "printf '%b' "\${$i}"")"
        printf " │ %d) %s │ \n" "$i" "$current_option"
        i=$((i + 1))
    done;
    printf '%s\n' " ╰──────────────────╯ "; printf '%s\n' ''

    printf '%s' "Select a release (1-$#): " >&2
    read -r option

    if [ "$option" -gt "$#" ] || [ "$option" -lt "1" ]; then
        error "Invalid option, please try again."
        exit 1
    else
        download_version="$(eval "printf '%b' "\${$option}"")"
    fi
}

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
# palera1n Builds and args
# =========

fetch_release_build() {
    curl -s "https://cdn.nickchan.lol/palera1n/c-rewrite/releases/" | awk -F'href="' '!/\.+\// && $2{print $2}' | awk -F'/' 'NF>1{print $1}' | awk '!/v2\.0\.0-beta\.[1-4]/' | tr '\n' ' '
}

fetch_nightly_build() {
    curl -s "https://cdn.nickchan.lol/palera1n/artifacts/c-rewrite/main/" | awk -F'href="' '!/\.+\// && $2{print $2}' | awk -F'/' 'NF>1{print $1}' | sed 's/^/\tNightly-/' | tr '\n' ' '
}

case "$1" in
    "" ) ;;
    "--list" | "-l" | "--nightly" | "-n" | "--help" | "-h" ) ;;
    * )
        error "Invalid option: \"$1\""
        exit 1
        ;;
esac

case "$1" in
    "--list" | "-l")
        release_build=$(fetch_release_build)
        menu "$release_build"
        download_version=$(printf '%s' "$download_version" | sed 's/Build-//')
        printf '%s\n' ""
        info "Using release tag ${download_version}."
    ;;
    "--nightly" | "-n")
        nightly_build=$(fetch_nightly_build)
        menu "$nightly_build"
        download_version=$(printf '%s' "$download_version" | sed 's/\tNightly-//')
        printf '%s\n' ""
        info "Using nightly build ${download_version}."
        prefix="nightly-"
    ;;
    "--help" | "-h")
        print_help
        exit 1
    ;;
    *)
        download_version="v2.0.0-beta.7"
        info "Using release tag ${download_version}."
    ;;
esac

info "Found OS type ($os_name $arch)."

# =========
# Run
# =========

info "Fetching palera1n (${prefix}${download_version}) build for ($os_name $arch)."
mkdir -p /usr/local/bin
rm /usr/local/bin/palera1n > /dev/null 2>&1

case "$os" in
    Linux)
        if [ "$1" = "--nightly" ] || [ "$1" = "-n" ]; then
            download "https://cdn.nickchan.lol/palera1n/artifacts/c-rewrite/main/${download_version}/palera1n-linux-${arch}"
        else
            download "https://github.com/palera1n/palera1n/releases/download/${download_version}/palera1n-linux-${arch}"
        fi
    ;;
    Darwin)
        if [ "$1" = "--nightly" ] || [ "$1" = "-n" ]; then
            download "https://cdn.nickchan.lol/palera1n/artifacts/c-rewrite/main/${download_version}/palera1n-macos-${arch}"
        else
            download "https://github.com/palera1n/palera1n/releases/download/${download_version}/palera1n-macos-${arch}"
        fi
    ;;
esac

if [ -f "$install_path" ]; then
    chmod +x $install_path

    if ! palera1n --version  > /dev/null 2>&1;
    then
        error "palera1n installation is corrupted. Please check your internet connection and try again."
        exit 1
    fi

    info "palera1n is now installed at ${install_path}, you can now run palera1n."
else 
    error "palera1n failed to install. Please check your internet connection and try again."
    exit 1
fi

info "For more information and steps please refer to: https://ios.cfw.guide/installing-palera1n/"
