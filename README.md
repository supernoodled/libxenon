# libxenon
libXenon is a library for writing programs for the Xbox 360, without using any existing code as a basis.

# About
This is an attempt as to make libxenon compilable in 2021+, without having to use things like a VM of Debian 7 (Wheezy), which is horribly out of date and the APT is all gone.

*!This is a WIP, and does not currently work!*

# What you need
- Ubuntu, or Debian. I'm currently developing this on [Windows 10 WSL2](https://docs.microsoft.com/en-gb/windows/wsl/install-win10) Debian 10 (Buster).

## sudo apt-get install
- libgmp3-dev
- libmpfr-dev
- libmpc-dev
- texinfo
- git-core
- build-essential

## Maybe need
- lsb-core
- lsb-release

- (these may require you to add extra sources to APT in Debian, such as oldoldstable, if you can't install say lsb-core or lsb-release)
- make sure to sudo apt-get update
- then sudo apt-get upgrade
- so that your APT is up to date

## type sudo nano ~/.bashrc and add the line
- export DEVKITXENON="/usr/local/xenon"

- then just CTRL+X and press Y to save

# Usage
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
