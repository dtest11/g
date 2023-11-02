#!/bin/bash

# Define some colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Use them in echo statements
echo -e "${RED}This is a red log message${NC}"
echo -e "${GREEN}This is a green log message${NC}"
echo -e "${YELLOW}This is a yellow log message${NC}"

system=$(uname -s | tr '[:upper:]' '[:lower:]')
architecture=$(uname -m)
url_version="https://go.dev/VERSION?m=text"
source_url=""
function rewrite_system_arch() {
    if [ "$architecture" == "aarch64" ]; then
        architecture="arm64"
    fi
}
function version() {
    echo -e "${RED} get current stable version ${VERSION}${NC}"
    http_code=$(curl -o version_text -w '%{http_code}' "$url_version")
    if [ "$http_code" != 200 ]; then
        echo "https://go.dev/VERSION?m=text response is not valid"
        exit 0
    fi
    VERSION=$(cat "version_text" | head -n 1)
    echo -e "${RED} current stable version is ${VERSION}  ${NC}"
    source_url="https://golang.google.cn/dl/$VERSION.$system-$architecture.tar.gz"
}

function download_source() {
    echo -e "${RED} download  ${VERSION} source from ${source_url}${NC}"
    http_code=$(curl -LO "$source_url" -w '%{http_code}')
    if [ "$http_code" != 200 ]; then
        echo "download source code failed"
        exit 0
    fi
}

function unzip() {
    echo -e "${RED}unzip source code to /usr/local/${NC}"
    sudo tar -C /usr/local/ -xzf $VERSION.$system-$architecture.tar.gz
}

function set_env() {
    shell=$(basename "$SHELL")
    if [ $shell == "zsh" ]; then
        if ! grep -q "GOPROXY" ~/.zshrc; then
            echo "export GOPROXY=https://goproxy.cn,direct" >>~/.zshrc
            source ~/.zshrc
        fi

        if ! grep -q "/usr/local/go/bin" ~/.zshrc; then
            echo "export PATH=$PATH:/usr/local/go/bin" >>~/.zshrc
            source ~/.zshrc
        fi
    elif [ $shell == "bash" ]; then
        if ! grep -q "GOPROXY" ~/.bashrc; then
            echo "export GOPROXY=https://goproxy.cn,direct" >>~/.bashrc
            source ~/.zshrc
        fi

        if ! grep -q "/usr/local/go/bin" ~/.bashrc; then
            echo "export PATH=$PATH:/usr/local/go/bin" >>~/.bashrc
            source ~/.zshrc
        fi
    fi
}

function clear() {
    rm $VERSION.$system-$architecture.tar.gz
    rm version_text
}

echo "System: $system"
echo "Architecture: $architecture"
rewrite_system_arch
version
download_source
unzip
set_env
clear
current_verison=$(go version)
echo -e "${RED}current version:${current_verison}${NC}"
