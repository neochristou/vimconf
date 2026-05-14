#!/usr/bin/env bash

OK_MSG="[+]"

install_brew() {
    if command -v brew > /dev/null; then
        echo -e "${OK_MSG} Homebrew already installed"
    else
        echo -e "${OK_MSG} Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

brew_install() {
    if brew ls --versions "$1" > /dev/null 2>&1; then
        echo -e "\tSkipping $1 -- already installed"
    else
        echo -e "\tInstalling $1"
        brew install "$1"
    fi
}

setup_mac() {
    install_brew

    echo "${OK_MSG} Installing Neovim and dependencies"
    brew_install neovim
    brew_install luarocks
    brew_install tree-sitter
    brew_install node
    brew_install fd
    brew_install bat
    brew_install corkscrew
    brew_install python@3.13
    brew_install llvm

    echo "${OK_MSG} Installing tree-sitter CLI"
    if ! command -v tree-sitter > /dev/null; then
        npm install -g tree-sitter-cli --registry https://registry.npmjs.org
    fi

    echo "${OK_MSG} Installing clang-format"
    if ! command -v clang-format > /dev/null; then
        brew_install clang-format
    fi

    echo "${OK_MSG} Installing fonts"
    brew install --cask font-meslo-lg-nerd-font 2>/dev/null

    echo "${OK_MSG} Installing zsh plugins"
    brew_install zsh-syntax-highlighting
}

install() {
    uname="$(uname -s)"
    case "${uname}" in
        Darwin*)
            setup_mac;;
        *)
            echo "This install script is for macOS only."
            exit 1
    esac
}

install
