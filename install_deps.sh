#!/usr/bin/env bash

EDITOR=neovim
WITH_GO=false
WITH_PYTHON=false
WITH_RUST=false
WITH_NPM=false
WITH_ELM=false

shopt -s expand_aliases

OK_MSG="[+]"

install_vimplug() {
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

reload_env(){
    for envf in ~/.profile ~/.bash_profile ~/.bash_aliases ~/.bashrc; do
        if [ -f ${envf} ]; then
            source ${envf}
        fi
    done
}

python_deps() {
    echo -e "${OK_MSG} Installing Python dependencies"
    uname="$(uname -s)"
    case "${uname}" in
        Linux*)
            sudo apt-get -y install python-jedi python3-jedi pylint pylint3 \
                1>/dev/null 2>/dev/null;;
    esac

    for pipv in pip pip3; do
        if [ ! `command -v ${pipv}` ]; then
            echo -e "${RED}[+] pip not found! Please install pip (and/or pip3)."
            echo -e "    Once pip is up, re-run this script ${BW}"
            exit
        else
            ${pipv} install -U setuptools
            ${pipv} install -U python-language-server
            for pkg in jedi neovim python-language-server; do
                if ${pipv} list --format=columns | grep ${pkg} > /dev/null; then
                    echo -e "\t ${pipv}: skipping ${pkg} -- already installed"
                else
                    ${pipv} install --user ${pkg} 2>/dev/null
                fi
            done
        fi
    done
}

npm_deps() {
    echo -e "${OK_MSG} Installing npm dependencies"
    uname="$(uname -s)"
    case "${uname}" in
        Linux*)
            sudo apt-get -y install node 1>/dev/null 2>/dev/null
            sudo apt-get -y install npm 1>/dev/null 2>/dev/null;;
        Darwin*)
            brew install node 1>/dev/null 2>/dev/null;;
    esac
    reload_env
}

typescript_deps() {
    echo -e "${OK_MSG} Installing typescript dependencies"
    npm -g install typescript
    reload_env
}

elm_deps() {
    echo -e "${OK_MSG} Installing elm dependencies"
    npm install -g elm
    npm install -g elm-oracle
    npm install -g elm-format
}

#
# MAC OS X (brew)
#
install_brew() {
    BREW=https://raw.githubusercontent.com/Homebrew/install/master/install
    if command -v brew > /dev/null; then
        echo -e "${OK_MSG} Using brew package manager"
    else
        echo -e "${OK_MSG} Brew package manager not found."
        while true; do
            read -p "Install brew to continue automatic install?" yn
            case $yn in
                [Yy]* )
                    if [ ! `command -v xcode-select` ]; then
                        echo "[+] Installing xcode command line tools."
                        xcode-select --install;
                    fi
                    ruby -e "$(curl -fsSL ${BREW})"
                    break;;
                [Nn]* )
                    echo "[+] Please perform a manual installation"
                    exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi
}

setup_mac() {
    install_brew
    reload_env

    local vim
    case "$EDITOR" in
        vim)
            vim=macvim
            ;;
        neovim)
            vim=neovim
            ;;
        *)
            vim=macvim;;
    esac

    echo "${OK_MSG} Setting things up"
    for pkg in ${vim} ctags cscope; do
        if brew ls --versions ${pkg} > /dev/null; then
            echo -e "\t Skipping $pkg -- already installed"
        else
            echo -e "\t Installing $pkg"
            brew install $pkg > /dev/null 2>/dev/null
        fi
    done
}

get_linux_dist() {
    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        # Older Debian/Ubuntu/etc.
        OS=Debian
        VER=$(cat /etc/debian_version)
    elif [ -f /etc/SuSe-release ]; then
        # Older SuSE/etc.
        OS=SUSE
    elif [ -f /etc/redhat-release ]; then
        # Red Hat
        OS=$(sudo cat /etc/redhat-release | awk '{print $1 $2}')
        VER=$(sudo cat /etc/redhat-release | \
            awk '{n=split($0,a," "); print a[n-1]}')
    else
        # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
        OS=$(uname -s)
        VER=$(uname -r)
    fi
}

setup_linux() {
    echo "${OK_MSG} Setting things up"
    reload_env
    get_linux_dist

    if [ "${OS}" == "Ubuntu" ] || [ "${OS}" == "Debian GNU/Linux" ] ; then
        local vim
        case "$EDITOR" in
            vim)
                vim=vim-athena
                ;;
            neovim)
                vim=neovim
                ;;
            *)
                vim=vim-athena;;
        esac

        echo "${OK_MSG} Running apt -y update"
        if [ "$vim" == "neovim" ]; then
            sudo add-apt-repository -y ppa:neovim-ppa/stable
            sudo apt-get -y update >/dev/null 2>/dev/null
        fi
        echo "${OK_MSG} Installing required packages"
        sudo apt-get -y install $vim exuberant-ctags curl cscope ctags \
             1>/dev/null 2>/dev/null
    elif [ "${OS}" == "CentOS" ] || \
        [ "${OS}" == "RedHat" ] || \
        [ "${OS}" == "Red Hat Enterprise Linux Server" ]; then
        sudo yum install vim cscope ctags
    elif [ "${OS}" == "SLES" ]; then
        sudo zypper install vim cscope ctags
    elif [ "${OS}" == "Fedora" ]; then
        sudo dnf install vim cscope ctags
    fi
}

install() {
    uname="$(uname -s)"
    case "${uname}" in
        Linux*)
            setup_linux;;
        Darwin*)
            setup_mac;;
        *)
            echo "Default installer may not work for you!"
            echo "Please attempt a manual installation"
            exit 1
    esac
    reload_env
}

usage() {
    echo -e "Usage: $0 [-v <vim or neovim>] [-p <go|python>"]
    echo -e "\t -v: editor version to install. Choose between 'vim' or 'neovim'"
    echo -e "\t -p: language-specific packages to install passed as a string."
    echo -e "\t     E.g., [-p "go python"] will install packages for both Go "
    echo -e "\t     and Python, respecting the system installed versions. If "
    echo -e "\t     If the respective programming language is not present,"
    echo -e "\t     only the editor without the respective features will be"
    echo -e "\t     installed. Supported: go python npm elm"
    exit 1;
}

while getopts ":v:p:" opt; do
    case "${opt}" in
        v)
            v=$(echo ${OPTARG} | awk '{print tolower($0)}')
            [ "$v" == "vim" ] || [ "$v" == "neovim" ] || usage
            EDITOR=$v
            ;;
        p)
            packages=( $(echo ${OPTARG} | awk '{print tolower($0)}') )
            for p in "${packages[@]}"
            do
                if [ "$p" == "python" ] ; then
                    WITH_PYTHON=true
                fi
                if [ "$p" == "go" ] ; then
                    WITH_GO=true
                fi
                if [ "$p" == "npm" ] ; then
                    WITH_NPM=true
                fi
                if [ "$p" == "elm" ] ; then
                    WITH_ELM=true
                fi
            done
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${v}" ]; then
    usage
fi

install_vimplug
install

if [[ ! -f ~/.vim/config/vimrc.user ]]; then
    touch ~/.vim/config/vimrc.user;
fi

vim +PlugInstall +qall
