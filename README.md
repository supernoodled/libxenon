# libxenon
libXenon is a library for writing programs for the Xbox 360, without using any existing code as a basis.

# About
This is an attempt as to make libxenon compilable in 2021+, without having to use old OS like Debian 7.

# Usage
git clone https://github.com/supernoodled/libxenon
cd libxenon/toolchain
sudo ./build-xenon-toolchain toolchain (install toolchain + libxenon)
sudo ./build-xenon-toolchain libs (install libxenon + bin2s + libraries seen below)
sudo ./build-xenon-toolchain libxenon (install or update libxenon)
sudo ./build-xenon-toolchain zlib (install or update zlib)
sudo ./build-xenon-toolchain libpng (install or update libpng)
sudo ./build-xenon-toolchain bzip2 (install or update bzip2)
sudo ./build-xenon-toolchain freetype (install or update freetype)
sudo ./build-xenon-toolchain filesystems (install libxenon filesystems)
sudo ./build-xenon-toolchain cube (compile the cube sample)
