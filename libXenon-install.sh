#!/bin/bash

if [ "$ID" == "0" ]; then
	echo "Don't run this script as root!!! use your regular user..." 1>&2
	exit 1
fi

LOGFILE="`echo $0 | tr "\/" "\n" | head -$(( $slashes -1 )) | tr "\n" "\/"`build.log"
rm $LOGFILE

###########################################################
# Don't touch these unless you know what you are doing... #
# Originally by Swizzy, modified by noodled 04 June 2021  #
###########################################################

LIBXENON=https://github.com/supernoodled/libxenon.git
LIBXENONBRANCH=master # OG: Swizzy

function StartMsg
{
        echo -e -n $@
        echo -e -n ": "
}


function AllOK
{
        echo -e "Done!"
        rm $LOGFILE
}

function FindDependency
{
	StartMsg Looking for \'$1\'
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1 2> /dev/null|grep "install ok installed")
	if [ "" == "$PKG_OK" ]; then
		echo -e "No '$1' Setting up '$1'..."
		sudo apt-get --force-yes --yes install $1 >> $LOGFILE 2>&1 || exit 1
	else
		echo -e "'$1' installed already... skipping..."
	fi
}

function InstallDependencies
{
	echo -e "Checking for dependencies..."
	FindDependency libgmp3-dev
	FindDependency libmpfr-dev
	FindDependency libmpc-dev
	FindDependency texinfo
	FindDependency git-core
	FindDependency gettext
	FindDependency build-essential
}

function Clone
{
	if [ ! -d $2 ]; then
		echo -e -n "Cloning... "
		git clone $1 >> $LOGFILE 2>&1 || exit 1
	else
		cd $2
		git remote update >> $LOGFILE 2>&1
		git status -uno | grep -q behind
		if [ 0 -eq $? ]; then
			echo -e -n "Updating... "
			git pull >> $LOGFILE 2>&1
                        make clean >> $LOGFILE 2>&1
		else
			echo -e -n "Already Up-To-Date... "
        fi
		cd ..
	fi
}

function CloneSpecial
{
	if [ ! -d $2 ]; then
		echo -e -n "Cloning... "
		git clone $1 >> $LOGFILE 2>&1 || exit 1
		cd $2
		git checkout $3
	else
		cd $2
		git checkout $3
		git remote update >> $LOGFILE 2>&1
		git status -uno | grep -q behind
		if [ 0 -eq $? ]; then
			echo -e -n "Updating... "
			git pull >> $LOGFILE 2>&1
                        make clean >> $LOGFILE 2>&1
		else
			echo -e -n "Already Up-To-Date... "
        fi
		cd ..
	fi
}

function Compile
{
	echo -e -n "Compiling... "
	cd $1
	make >> $LOGFILE 2>&1 || exit 1
	cd ..
}

function CompileSpecial
{
	echo -e -n "Compiling... "
	cd $1
	make -f $2 >> $LOGFILE 2>&1 || exit 1
	cd ..
}

function Install
{
	echo -e -n "Installing... "
	cd $1
	make install >> $LOGFILE 2>&1 || exit 1
	cd ..
}

function InstallSpecial
{
        echo -e -n "Installing... "
        cd $1
        make -f $2 install >> $LOGFILE 2>&1 || exit 1
        cd ..
}

function MakeLibxenon
{
	StartMsg Libxenon 
    Clone $LIBXENON libxenon
	AllOK
	cd libxenon
	if [ "" != "$LIBXENONBRANCH" ]; then
		git checkout $LIBXENONBRANCH
	fi
	cd toolchain
	UserPrimaryGroupId=`cat /etc/passwd | grep -Ew ^$USER | cut -d":" -f4`
	UserPrimaryGroup=`cat /etc/group | grep :"$UserPrimaryGroupId": | cut -d":" -f1`
	sudo chown -R $USER:$UserPrimaryGroup /usr/local/xenon
	echo -e "Building toolchain, libxenon and the libs..."
	echo -e "Building the toolchain..."
	bash build-xenon-toolchain toolchain || exit 1
	echo -e "Building libxenon..."
	bash build-xenon-toolchain libxenon || exit 1
	echo -e "Building libs..."
	bash build-xenon-toolchain libs || exit 1
	echo -e "Setting up devkitxenon script..."
	sudo bash -c "printf \"export DEVKITXENON=\\\"/usr/local/xenon\\\"\\\nexport PATH=\\\"\\\$PATH:\\\$DEVKITXENON/bin:\\\$DEVKITXENON/usr/bin\\\"\" >> /etc/profile.d/devkitxenon.sh"
	sudo chmod +x /etc/profile.d/devkitxenon.sh
	export DEVKITXENON="/usr/local/xenon"
	export PATH="$PATH:$DEVKITXENON/bin:$DEVKITXENON/usr/bin"
}

StartMsg Looking for \'sudo\'
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' sudo 2> /dev/null|grep "install ok installed") >> /dev/null 2>&1
if [ "" == "$PKG_OK" ]; then
	echo -e "sudo not found! please install it..." 1>&2
	exit 1
else
	echo -e "sudo installed... let's continue shall we?"
fi

sudo mkdir -p /usr/local/xenon
if [ "$1" != "notoolchain" ]; then
	InstallDependencies
	MakeLibxenon
fi

# I'll leave these 2 uncommented as they are
# but I'll point them to new repos
# OG master: Swizzy

# This may be a problem, as fat-xenon is now libfat.
#StartMsg libFAT-Xenon ramen Edition
#CloneSpecial https://github.com/supernoodled/libfat.git fat-xenon master
#Compile fat-xenon
#Install fat-xenon
#AllOK

#StartMsg libNTFS-Xenon ramen Edition
#CloneSpecial https://github.com/supernoodled/ntfs-xenon.git ntfs-xenon master
#Compile ntfs-xenon
#Install ntfs-xenon
#AllOK

# TODO: Add all changes people have made into a single repo
# CBA right now so it's staying as the original.
StartMsg libSDL
Clone https://github.com/supernoodled/libSDLXenon.git libSDLXenon
CompileSpecial libSDLXenon Makefile.xenon
InstallSpecial libSDLXenon Makefile.xenon
AllOK

StartMsg SDL_ttf
Clone https://github.com/supernoodled/SDL_ttf.git SDL_ttf
Compile SDL_ttf
Install SDL_ttf
AllOK

# I'll leave this uncommented
#StartMsg SDL_net
#Clone https://github.com/supernoodled/SDL_net.git SDL_net
#
#
#AllOK

StartMsg SDL_Image
Clone https://github.com/supernoodled/SDL_Image.git SDL_Image
CompileSpecial SDL_Image Makefile.xenon
InstallSpecial SDL_Image Makefile.xenon
AllOK

StartMsg SDL_Mixer
Clone https://github.com/supernoodled/SDL_Mixer.git SDL_Mixer
CompileSpecial SDL_Mixer Makefile.xenon
InstallSpecial SDL_Mixer Makefile.xenon
AllOK

# This still has active commits upto this day, so I'll leave it alone.
# I won't change the fork link till the repo's dead,
# since maybe there's an active change i haven't synced to mine.
StartMsg libxemit
Clone https://github.com/gligli/libxemit.git libxemit
Compile libxemit
Install libxemit
AllOK

# I merged Swizzy's usb fix to master on my repo.
StartMsg ZLX
Clone https://github.com/supernoodled/ZLX-Library.git ZLX-Library
CompileSpecial ZLX-Library Makefile_lib
InstallSpecial ZLX-Library Makefile_lib
AllOK