# libxenon
libXenon is a library for writing programs for the Xbox 360, without using any existing code as a basis.

# About
This is an attempt as to make libxenon compilable in 2021+, without having to use things like a VM of Debian 7 (Wheezy), which is horribly out of date and the APT is all gone.

*!This is a WIP, and does not currently work!*

# What you need
- Ubuntu, or Debian. I'm currently developing this on [Windows 10 WSL2](https://docs.microsoft.com/en-gb/windows/wsl/install-win10) Debian 10 (Buster).

# Debian
- You need to get lsb-release (pointless, but still needed) for a pointless version check.
- It's not included in the default APT, so we have to modify it.
- type cd /etc/apt
- then sudo nano sources.list
- and add to your APT list

- deb [trusted=yes] https://ftp.debian.org/debian stable main
- deb [trusted=yes] https://ftp.debian.org/debian stable-updates main
- deb [trusted=yes] https://security.debian.org/debian-security/ stable/updates main
- deb [trusted=yes] https://ftp.debian.org/debian stable-backports main

- then just CTRL+X and press Y to save.

- then type sudo apt-get update 
- then sudo apt-get upgrade

## sudo apt-get install
- libgmp3-dev
- libmpfr-dev
- libmpc-dev
- texinfo
- git-core
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
- type sudo nano ~/.bashrc and add the line
- export DEVKITXENON="/usr/local/xenon"

- then CTRL+X and press Y to save.