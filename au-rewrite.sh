#!/bin/bash

#########################################
#            au-rewrite.sh              #
# downloads and writes certain packages #
#           every 24 hours              #
#########################################

PKGDIR="/root/raspbian-addons/debian/pkgs_incoming/"
DATEA="$(date)"

# print the date to console (for logging purposes)
echo $DATEA

# ensure folder for downloads is available
mkdir -p ~/dlfiles
cd ~/dlfiles
rm -rf *

# create data directory, for storing the version.txt file
mkdir -p $HOME/dlfiles-data

# ensure armhf arch is added
sudo dpkg --add-architecture armhf

function error {
  echo -e "\e[91m$1\e[39m"
  exit 1
}

function redtext {
  echo -e "\e[91m$1\e[39m"
}

echo "Updating codium."
CODIUM_API=`curl -s https://api.github.com/repos/VSCodium/VSCodium/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
CODIUM_DATAFILE="$HOME/dlfiles-data/codium.txt"
if [ ! -f "$CODIUM_DATAFILE" ]; then
    echo "$CODIUM_DATAFILE does not exist."
    echo "Grabbing the latest release from GitHub."
    echo $CODIUM_API > $CODIUM_DATAFILE
fi
CODIUM_CURRENT="$(cat ${CODIUM_DATAFILE})"
if [ "$CODIUM_CURRENT" != "$CODIUM_API" ]; then
    echo "codium isn't up to date. updating now..."
    curl -s https://api.github.com/repos/VSCodium/VSCodium/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o codium_${CODIUM_API}_armhf.deb || error "Failed to download the codium:armhf"

    curl -s https://api.github.com/repos/VSCodium/VSCodium/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o codium_${CODIUM_API}_arm64.deb || error "Failed to download codium:arm64"

    mv codium* $PKGDIR
    echo $CODIUM_API > $CODIUM_DATAFILE
    echo "codium downloaded successfully."
fi
echo "codium is up to date."

echo "Updating goreleaser."
GORELEASER_API=`curl -s https://api.github.com/repos/goreleaser/goreleaser/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
GORELEASER_DATAFILE="$HOME/dlfiles-data/goreleaser.txt"
if [ ! -f "$GORELEASER_DATAFILE" ]; then
    echo "$GORELEASER_DATAFILE does not exist."
    echo "Grabbing the latest release from GitHub."
    echo $GORELEASER_API > $GORELEASER_DATAFILE
fi
GORELEASER_CURRENT="$(cat ${GORELEASER_DATAFILE})"
if [ "$GORELEASER_CURRENT" != "$GORELEASER_API" ]; then
    echo "goreleaser isn't up to date. updating now..."
    curl -s https://api.github.com/repos/goreleaser/goreleaser/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o goreleaser_${GORELEASER_API}_armhf.deb || error "Failed to download goreleaser:armhf"

    curl -s https://api.github.com/repos/goreleaser/goreleaser/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o goreleaser_${GORELEASER_API}_arm64.deb || error "Failed to download goreleaser:arm64"

    mv goreleaser* $PKGDIR
    echo $GORELEASER_API > $GORELEASER_DATAFILE
    echo "goreleaser downloaded successfully."
fi
echo "goreleaser is up to date."

echo "Updating hyperfine."
HYPERFINE_API=`curl -s https://api.github.com/repos/sharkdp/hyperfine/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'`
HYPERFINE_DATAFILE="$HOME/dlfiles-data/hyperfine.txt"
if [ ! -f "$HYPERFINE_DATAFILE" ]; then
    echo "$HYPERFINE_DATAFILE does not exist."
    echo "Grabbing the latest release from GitHub."
    echo $HYPERFINE_API > $HYPERFINE_DATAFILE
fi
HYPERFINE_CURRENT="$(cat ${HYPERFINE_DATAFILE})"
if [ "$HYPERFINE_CURRENT" != "$HYPERFINE_API" ]; then
    echo "hyperfine isn't up to date. updating now..."
    curl -s https://api.github.com/repos/sharkdp/hyperfine/releases/latest \
      | grep browser_download_url \
      | grep 'armhf.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o hyperfine_${HYPERFINE_API}_armhf.deb || error "Failed to download hyperfine:armhf"

    curl -s https://api.github.com/repos/sharkdp/hyperfine/releases/latest \
      | grep browser_download_url \
      | grep 'arm64.deb"' \
      | cut -d '"' -f 4 \
      | xargs -n 1 curl -L -o hyperfine_${HYPERFINE_API}_arm64.deb || error "Failed to download hyperfine:arm64"

    mv hyperfine* $PKGDIR
    echo $HYPERFINE_API > $HYPERFINE_DATAFILE
    echo "hyperfine downloaded successfully."
fi
echo "hyperfine is up to date."

echo "Updating blockbench."

echo "Writing packages."
cd /root/raspbian-addons/debian
for new_pkg in `ls pkgs_incoming`; do
    echo $new_pkg
    #reprepro_expect
    /root/reprepro.exp -- --noguessgpgtty -Vb /root/raspbian-addons/debian/ includedeb precise /root/raspbian-addons/debian/pkgs_incoming/$new_pkg
    if [ $? != 0 ]; then
        redtext "Import of $new_pkg failed!"
    else
        rm -rf pkgs_incoming/$new_pkg
    fi
done
