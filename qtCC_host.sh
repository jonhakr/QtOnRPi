#!/usr/bin/env bash

#################################################################################
# Cross compilation of Qt for the Raspberry Pi, using official source tarball	#
# - Host script																	#
#################################################################################

set -eu

### Directories
RPIDEV_ROOT=~/raspi		# Select root directory (moving this post-build/install will brake qmake for cross-compiling)
RPIDEV_TOOLS=${RPIDEV_ROOT}/tools
RPIDEV_TAR=${RPIDEV_ROOT}/tar
RPIDEV_SRC=${RPIDEV_ROOT}/src
RPIDEV_BUILD=${RPIDEV_ROOT}/build
RPIDEV_INSTALL=${RPIDEV_ROOT}/install
RPIDEV_SYSROOT=${RPIDEV_ROOT}/sysroot

RPIDEV_JOBS=$(grep -c "^processor" /proc/cpuinfo)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RUN_DIR=$(pwd)

### Target device
RPIDEV_DEVICE_VERSION=pi3            	# pi1 pi2 pi3 (only tested pi3)
RPIDEV_DEVICE_ADDRESS=192.168.XXX.XX	# ip of device
RPIDEV_DEVICE_USER=pi                	# username
RPIDEV_DEVICE_PW=raspberry           	# password

### Decide target mkspec
TARGET_DEVICE="linux-rpi3-g++"
if [ "$RPIDEV_DEVICE_VERSION" == "pi1" ]; then
	TARGET_DEVICE="linux-rasp-pi-g++"
elif [ "$RPIDEV_DEVICE_VERSION" == "pi2" ]; then
	TARGET_DEVICE="linux-rasp-pi2-g++"
elif [ "$RPIDEV_DEVICE_VERSION" == "pi3" ]; then
	TARGET_DEVICE="linux-rpi3-g++"
else
	echo "${BASH_SOURCE[1]}: line ${BASH_LINENO[0]}: ${FUNCNAME[1]}: Unknown device $RPIDEV_DEVICE_VERSION." >&2
	exit 1
fi

### Qt paths
QT_VER=5.9			# Select version to download and install
QT_SUBVER=5.9.1		# Select subversion to download and install
QT_INSTALL_DIR=${RPIDEV_INSTALL}/qt${QT_VER}
QT_INSTALL_DIR_HOST=${RPIDEV_INSTALL}/qt${QT_VER}-host
QT_DEVICE_DIR=/usr/local/qt${QT_VER}

### Synchronization Options
RSH_OPT="/usr/bin/sshpass -p ${RPIDEV_DEVICE_PW} ssh -o StrictHostKeyChecking=no -l ${RPIDEV_DEVICE_USER}"

### Configuration Options
CONF_OPT=""
CONF_OPT+=" -v"
CONF_OPT+=" -opensource"
CONF_OPT+=" -confirm-license"
CONF_OPT+=" -opengl es2"
CONF_OPT+=" -device ${TARGET_DEVICE}"
CONF_OPT+=" -device-option CROSS_COMPILE=${RPIDEV_TOOLS}/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-"
CONF_OPT+=" -sysroot ${RPIDEV_SYSROOT}"
CONF_OPT+=" -prefix ${QT_DEVICE_DIR}"
CONF_OPT+=" -extprefix ${QT_INSTALL_DIR}"
CONF_OPT+=" -hostprefix ${QT_INSTALL_DIR_HOST}"
#CONF_OPT+=" -optimized-qmake"
#CONF_OPT+=" -reduce-exports"
CONF_OPT+=" -release"
CONF_OPT+=" -make libs"	# Only make libraries (no tests, examples etc)
CONF_OPT+=" -skip qtserialbus"	# Get error when compiling this package
CONF_OPT+=" -skip qtwayland"	# Get error when compiling this package
CONF_OPT+=" -skip qtscript"		# Get error when compiling this package
#CONF_OPT+=" -skip qtwebengine"	# Large (save time by skipping)
#CONF_OPT+=" -skip qtwebkit"	# Large (save time by skipping)
CONF_OPT+=" -no-pch" # Some users have reported issues with using precomiled headers
CONF_OPT+=" -no-use-gold-linker" # Seems to have issues with ARMv8

echo
echo "===== Creating root directory ====="
echo
mkdir -p ${RPIDEV_ROOT}

do_sysroot(){
	echo "===== Creating sysroot directories ====="
	mkdir -p ${RPIDEV_SYSROOT}/usr
	mkdir -p ${RPIDEV_SYSROOT}/opt

	echo
	echo "===== Syncing sysroot with ${RPIDEV_DEVICE_ADDRESS} ====="
	set +e # Ignore errors as there are usually some folders without read permission
	
	echo "== Sync /lib =="
	echo
	rsync -avztr --delete --rsh="${RSH_OPT}" ${RPIDEV_DEVICE_ADDRESS}:/lib ${RPIDEV_SYSROOT} 2>&1 | tee ${RUN_DIR}/sysroot.out

	echo
	echo "== Sync /usr/include =="
	echo
	rsync -avztr --delete --rsh="${RSH_OPT}" ${RPIDEV_DEVICE_ADDRESS}:/usr/include ${RPIDEV_SYSROOT}/usr 2>&1 | tee -a ${RUN_DIR}/sysroot.out

	echo
	echo "== Sync /usr/lib =="
	echo
	rsync -avztr --delete --rsh="${RSH_OPT}" ${RPIDEV_DEVICE_ADDRESS}:/usr/lib ${RPIDEV_SYSROOT}/usr 2>&1 | tee -a ${RUN_DIR}/sysroot.out

	echo
	echo "== Sync /opt/vc =="
	echo
	rsync -avztr --delete --rsh="${RSH_OPT}" ${RPIDEV_DEVICE_ADDRESS}:/opt/vc ${RPIDEV_SYSROOT}/opt 2>&1 | tee -a ${RUN_DIR}/sysroot.out
	set -e # Re-enable stop on error

	echo
	echo "===== Replacing absolute symlinks with relative ones ====="
	echo
	"${SCRIPT_DIR}/sysroot-relativelinks.py" ${RPIDEV_SYSROOT}
}

do_tools(){
	echo
	echo "===== Fetching RPi toolchain ====="
	echo
	git clone https://github.com/raspberrypi/tools.git ${RPIDEV_TOOLS}
}

do_down(){
	echo
	echo "===== Downloading src tar: qt${QT_VER} ====="
	echo
	mkdir -p "${RPIDEV_TAR}"
	cd "${RPIDEV_TAR}"
	wget "http://download.qt.io/official_releases/qt/${QT_VER}/${QT_SUBVER}/single/qt-everywhere-opensource-src-${QT_SUBVER}.tar.gz"
}

do_tar(){
	echo
	echo "===== Unpacking src tar"
	echo
	mkdir -p "${RPIDEV_SRC}/qt${QT_VER}"
	cd "${RPIDEV_TAR}"
	tar xzf "qt-everywhere-opensource-src-${QT_SUBVER}.tar.gz" --strip=1 -C ${RPIDEV_SRC}/qt${QT_VER} qt-everywhere-opensource-src-${QT_SUBVER}
}

do_conf(){
	echo
	echo "===== Creating build directory ====="
	echo
	mkdir -p "${RPIDEV_BUILD}/qt${QT_VER}"
	cd "${RPIDEV_BUILD}/qt${QT_VER}"
	echo
	echo "===== Configuring shadow build ====="
	echo
	MAKEFLAGS=-j${RPIDEV_JOBS} ${RPIDEV_SRC}/qt${QT_VER}/configure ${CONF_OPT} 2>&1 | tee ${RUN_DIR}/config.out
}

do_make(){
	echo
	echo "===== Building qt${QT_VER} ====="
	echo
	cd "${RPIDEV_BUILD}/qt${QT_VER}"
	make -j${RPIDEV_JOBS} 2>&1 | tee ${RUN_DIR}/make.out
}

do_install(){
	echo
	echo "===== Installing in ${QT_INSTALL_DIR} ====="
	echo
	cd "${RPIDEV_BUILD}/qt${QT_VER}"
	sudo make install -j${RPIDEV_JOBS} 2>&1 | tee ${RUN_DIR}/install.out
	sudo cp "${QT_INSTALL_DIR_HOST}/bin/rcc" "${QT_INSTALL_DIR}/bin" # Copy missing binary
}

do_deploy(){
	echo
	echo "===== Deploying ${QT_INSTALL_DIR} to target ${RPIDEV_DEVICE_ADDRESS}:${QT_DEVICE_DIR} ====="
	echo
	rsync -avztr --delete --rsh="${RSH_OPT}" ${QT_INSTALL_DIR}/* ${RPIDEV_DEVICE_ADDRESS}:${QT_DEVICE_DIR}
}

do_all(){
	do_sysroot
	do_tools
	do_down
	do_tar
	do_conf
	do_make
	do_install
	do_deploy
}

while [ "${1+defined}" ];
do
	case $1 in
		sysroot* ) do_sysroot ;;
		tools* )   do_tools   ;;
		down* )    do_down    ;;
		tar* )     do_tar     ;;
		conf* )    do_conf    ;;
		make* )    do_make    ;;
		install* ) do_install ;;
		deploy* )  do_deploy  ;;
		all* )     do_all     ;;
		*) echo "UNKNOWN COMMAND: '$1', SKIPPING..."	;;
	esac
	shift
done


echo "DONE"

