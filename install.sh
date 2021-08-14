#!/bin/zsh

SHELL="/bin/zsh"
git clone https://github.com/alagroy-42/push_script.git /tmp/push >/dev/null 2>&1
cd /tmp/push
zsh install.sh
git clone https://github.com/alagroy-42/elf-extractor.git /tmp/extract >/dev/null 2>&1
cd /tmp/extract
zsh install.sh
source ~/.zshrc
echo "All utillities installed"

git rm --cached install.sh
