#!/usr/bin/env bash

#################################################################################
# Cross compilation of Qt for the Raspberry Pi, using official source tarball	#
# - Target script																#
#################################################################################

set -eu

### Settings
QT_VER="5.9"	# Make sure this matches the QT_VER specified on the host
INST_DIR="qt${QT_VER}"
INST_DIR_FULL="/usr/local/${INST_DIR}"
SETUP_DIR="${HOME}/.qt"
SETUP_SCRIPT="setup.sh"
PHYS_WIDTH=510
PHYS_HEIGHT=290


do_prep(){
	echo
	echo "===== Installing development files ====="
	echo "== (Make sure you have uncommented deb-src in /etc/apt/sources.list before running this command) =="
	echo
	sudo apt-get update
	sudo apt-get build-dep qt4-x11
	sudo apt-get build-dep libqt5gui5
	sudo apt-get install libudev-dev libinput-dev libts-dev libxcb-xinerama0-dev libxcb-xinerama0
}

do_dirs(){
	echo
	echo "===== Creating Qt lib directory ====="
	echo
	sudo mkdir -p ${INST_DIR_FULL}
	sudo chown pi:pi ${INST_DIR_FULL}	
}

do_link(){
	echo
	echo "===== Adding Qt libs to linker ====="
	echo
	echo ${INST_DIR_FULL}/lib | sudo tee /etc/ld.so.conf.d/${INST_DIR}.conf
	sudo ldconfig
}

do_libfix(){
	echo
	echo "===== Fixing EGL/GLES library issue ====="
	echo "== (Note that if you run this twice, you might overwrite the original library) =="
	echo
	# Rename originals
	sudo mv /usr/lib/arm-linux-gnueabihf/libEGL.so.1.0.0 /usr/lib/arm-linux-gnueabihf/libEGL.so.1.0.0_orig
	sudo mv /usr/lib/arm-linux-gnueabihf/libGLESv2.so.2.0.0 /usr/lib/arm-linux-gnueabihf/libGLESv2.so.2.0.0_orig
	# Link proper ones
	sudo ln -s /opt/vc/lib/libEGL.so /usr/lib/arm-linux-gnueabihf/libEGL.so.1.0.0
	sudo ln -s /opt/vc/lib/libGLESv2.so /usr/lib/arm-linux-gnueabihf/libGLESv2.so.2.0.0
	# Link these too for QtWebEngine
	sudo ln -s /opt/vc/lib/libEGL.so /opt/vc/lib/libEGL.so.1
	sudo ln -s /opt/vc/lib/libGLESv2.so /opt/vc/lib/libGLESv2.so.2
}

do_exports(){
	echo
	echo "===== Creating setup script for exporting environmenal variables ====="
	echo "== (Note that if you run this more than once, you'll append its source multiple times in .profile and .bashrc)=="
	echo
	echo
	# Make startup script to export symbols
	mkdir -p "${SETUP_DIR}"
	cd "${SETUP_DIR}"
	> ${SETUP_SCRIPT}
	echo "export QT_QPA_EGLFS_PHYSICAL_WIDTH=${PHYS_WIDTH}" >> ${SETUP_SCRIPT}
	echo "export QT_QPA_EGLFS_PHYSICAL_HEIGHT=${PHYS_HEIGHT}" >> ${SETUP_SCRIPT}

	# Make the script executable and run it
	chmod +x ${SETUP_SCRIPT}
	./${SETUP_SCRIPT}

	# Append source to setup script in startup scripts
	echo "source ${SETUP_DIR}/${SETUP_SCRIPT}" >> ~/.profile
	echo "source ${SETUP_DIR}/${SETUP_SCRIPT}" >> ~/.bashrc
}

do_all(){
	do_prep
	do_dirs
	do_link
	do_libfix
	do_exports
}

while [ "${1+defined}" ];
do
	case $1 in
		prep* )   	do_prep   	;;
		dirs* )   	do_dirs   	;;
		link* )   	do_link   	;;
		libfix* ) 	do_libfix 	;;
		exports* ) 	do_exports 	;;
		all* )    	do_all    	;;
		*) echo "UNKNOWN COMMAND: '$1', SKIPPING..."	;;
	esac
	shift
done


echo "DONE"
