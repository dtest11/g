#!/bin/bash

system=$(uname -s | tr '[:upper:]' '[:lower:]')
architecture=$(uname -m)
echo "System: $system"
echo "Architecture: $architecture"

echo "**** 1.Get current stable version ****"

http_code=$(curl -sS -o /dev/null -w '%{http_code}' https://go.dev/VERSION?m=text)
if [[ $http_code -eq 200 ]]; then
    VERSION=$(curl -sS https://go.dev/VERSION?m=text | head -n 1)
    echo "**** 2.Download: $VERSION ****"

    url="https://golang.google.cn/dl/$VERSION.$system-$architecture.tar.gz"
    echo "**** 3.Download from $url"

    curl -LO $url 
    curl_result=$?
    if [[ $curl_result -eq 0 ]]; then
        sudo tar -C /usr/local/ -xzf $VERSION.$system-$architecture.tar.gz

        # Determine the current shell
        shell=$(basename "$SHELL")

        # Export GOPROXY and add Go binary path to PATH in corresponding shell configuration file
        if [[ $shell == "zsh" ]]; then
            if ! grep -q "GOPROXY" ~/.zshrc; then
            echo "export GOPROXY=https://goproxy.cn,direct" >> ~/.zshrc
            source ~/.zshrc
            fi
               

            if ! grep -q "/usr/local/go/bin" ~/.zshrc; then
               echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.zshrc
               source ~/.zshrc
            fi

           
            
        elif [[ $shell == "bash" ]]; then
            if ! grep -q "GOPROXY" ~/.bashrc; then
               echo "export GOPROXY=https://goproxy.cn,direct" >> ~/.bashrc
               source ~/.bashrc

            fi

            if ! grep -q "/usr/local/go/bin" ~/.zshrbashrcc; then
               echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
               source ~/.bashrc
            fi
        fi

        # Reload the shell configuration
        rm $VERSION.$system-$architecture.tar.gz
        echo "**** go install success******"
    else
        echo "Download failed with curl error code: $curl_result"
    fi
else
    echo "Failed to retrieve version information from https://go.dev/VERSION?m=text"
fi
