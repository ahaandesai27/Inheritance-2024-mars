#!/bin/bash
# Ubuntu
apt-get update
apt-get install -y wget gnupg
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
apt-get update
apt-get install -y google-chrome-stable


# # Alpine
# apk update
# apk add --no-cache \
#   chromium \
#   nss \
#   freetype \
#   harfbuzz \
#   ca-certificates \
#   ttf-freefont
    