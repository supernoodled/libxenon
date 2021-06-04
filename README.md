# libxenon
libXenon is a library for writing programs for the Xbox 360, without using any existing code as a basis.

# About
This is an attempt as to make libxenon compilable in 2021+, without having to use things like a VM of Debian 7 (Wheezy), which is horribly out of date and the APT is all gone.

*!This is a WIP!*

# What you need
- Ubuntu, or Debian. I'm currently developing this on [Windows 10 WSL2](https://docs.microsoft.com/en-gb/windows/wsl/install-win10) Debian 10 (Buster).

# Debian 10 (Buster)
- You need to get lsb-release (pointless, but still needed) for a pointless version check.
- It's not included in the default APT (anymore), so we have to modify it.
- type sudo nano /etc/apt/sources.list
- then copy paste from Debian10APT.txt, or from https://pastebin.com/raw/X9uf6Zh1
- then just CTRL+X, press Y, then press enter to save.

- finally type sudo apt-get update 
- then sudo apt-get upgrade to finish it off

# Installation
- run the libXenon-install.sh script to install libxenon

## sudo apt-get install
- libgmp3-dev
- libmpfr-dev
- libmpc-dev
- texinfo
- git-core
- gettext
- build-essential

# Usage (toolchain commands)
- git clone https://github.com/supernoodled/libxenon
- cd libxenon/toolchain
- ./build-xenon-toolchain toolchain (install toolchain + libxenon)
- ./build-xenon-toolchain libs (install libxenon + bin2s + libraries seen below)
- ./build-xenon-toolchain libxenon (install or update libxenon)
- ./build-xenon-toolchain zlib (install or update zlib)
- ./build-xenon-toolchain libpng (install or update libpng)
- ./build-xenon-toolchain bzip2 (install or update bzip2)
- ./build-xenon-toolchain freetype (install or update freetype)
- ./build-xenon-toolchain filesystems (install libxenon filesystems)
- ./build-xenon-toolchain cube (compile the cube sample)

## you may need to
- type sudo nano ~/.bashrc and add the following:
```
# libxenon
export DEVKITXENON="/usr/local/xenon"
export CC=xenon-gcc

export CFLAGS="export CFLAGS="-mcpu=cell -mtune=cell -m32 -fno-pic \
-mpowerpc64 $DEVKITXENON/usr/lib/libxenon.a -L$DEVKITXENON/xenon/lib/32/ -T$DEVKITXENON/app.lds \
-u read -u _start -u exc_base -L$DEVKITXENON/usr/lib -I$DEVKITXENON/usr/include"

export LDFLAGS=$CFLAGS

export PATH="$PATH:$DEVKITXENON/bin:$DEVKITXENON/usr/bin"
```

- then CTRL+X, press Y, then press enter to save.

## or you can just
- go into extras folder
- and replace your .bashrc with the one provided.