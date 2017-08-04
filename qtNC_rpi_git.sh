#!/usr/bin/env bash

#####################################################
# Native compilation of Qt for the Raspberry Pi,	#
# using source from the official git repo.			#
#####################################################

set -exu

### SETTINGS
MAIN_VER="5"
VER="5.9"
REPO="git://code.qt.io/qt/qt5.git"
INST_DIR="/usr/local/qt$VER"
CORES="4"
B=$(pwd)
SETUP="setup"
SETUP_DIR=".qt"

### REPO INIT OPTIONS
INIT_OPT=""
INIT_OPT+="--module-subset=default,-qtwebkit,-qtwebkit-examples,-qtwebengine"

### CONFIGURATION OPTIONS
CONF_OPT=""
CONF_OPT+=" -v"
CONF_OPT+=" -opensource"
CONF_OPT+=" -confirm-license"
CONF_OPT+=" -opengl es2"
CONF_OPT+=" -device linux-rpi3-g++"
CONF_OPT+=" -device-option CROSS_COMPILE=/usr/bin/"
CONF_OPT+=" -sysroot /"
CONF_OPT+=" -optimized-qmake"
CONF_OPT+=" -reduce-exports"
CONF_OPT+=" -release"
CONF_OPT+=" -qpa xcb"		# Use xcb as default QPA backend
CONF_OPT+=" -qt-pcre"		# Use the PCRE library bundled with Qt.
CONF_OPT+=" -qt-libpng"	# Use the libpng bundled with Qt.
CONF_OPT+=" -qt-xcb"		# Use xcb- libraries bundled with Qt.
CONF_OPT+=" -make libs"	# Only make libraries (no tests, examples etc)
CONF_OPT+=" -skip qtserialbus"	# Get error when compiling this package
CONF_OPT+=" -skip qtwayland"	# Get error when compiling this package
CONF_OPT+=" -skip qtscript"		# Get error when compiling this package
CONF_OPT+=" -no-pch" # Some users have reported issues with using precomiled headers
CONF_OPT+=" -no-use-gold-linker" # Seems to have issues with ARMv8


### DEPENDENCIES
DEPS=""
# Build tools
DEPS+=" build-essential"
DEPS+=" perl"
DEPS+=" python"
DEPS+=" git"
DEPS+=" flex"
DEPS+=" ruby"
DEPS+=" gperf"
DEPS+=" bison"
# XCB/X11 support
DEPS+=" ^libxcb.*"
DEPS+=" libglu1-mesa-dev"
DEPS+=" libx11-xcb-dev"
DEPS+=" libxrender-dev"
DEPS+=" libfontconfig1-dev"
DEPS+=" libfreetype6-dev"
DEPS+=" libx11-dev"
DEPS+=" libxext-dev"
DEPS+=" libxfixes-dev"
DEPS+=" libxi-dev"
DEPS+=" libxcb1-dev"
DEPS+=" libxcb-glx0-dev"
DEPS+=" libxcb-keysyms1-dev"
DEPS+=" libxcb-image0-dev"
DEPS+=" libxcb-shm0-dev"
DEPS+=" libxcb-icccm4-dev"
DEPS+=" libxcb-sync0-dev"
DEPS+=" libxcb-xfixes0-dev"
DEPS+=" libxcb-shape0-dev"
DEPS+=" libxcb-randr0-dev"
DEPS+=" libxcb-render-util0-dev"
DEPS+=" libx11-xcb1"
DEPS+=" libxcb-sync1"
DEPS+=" libxcb-sync-dev"
DEPS+=" libxcb-xinerama0"
DEPS+=" libxcb-xinerama0-dev"
DEPS+=" libx11-xcb1"
DEPS+=" libxcb-sync1"
DEPS+=" libxcb-sync-dev"
# Sound support
DEPS+=" libasound2-dev"
DEPS+=" libpulse-dev"
# Media support
DEPS+=" libavcodec-dev"
DEPS+=" libavformat-dev"
DEPS+=" libswscale-dev"
DEPS+=" gstreamer-tools"
DEPS+=" libgstreamer1.0-dev"
DEPS+=" libgstreamer-plugins-base1.0-dev"
DEPS+=" gstreamer1.0-omx"
DEPS+=" gstreamer1.0-plugins-good"
DEPS+=" gstreamer1.0-plugins-bad"
DEPS+=" gstreamer1.0-plugins-ugly"
DEPS+=" gstreamer1.0-libav"
DEPS+=" gstreamer1.0-clutter"
DEPS+=" gstreamer1.0-fluendo-mp3"
#DEPS+=" gstreamer1.0-pulseaudio" # Should use alsa and not pulseaudio
#DEPS+=" libgstreamer0.10-dev" # Not needed for Qt 5.8 and later
#DEPS+=" libgstreamer-plugins-base0.10-dev"
#DEPS+=" gstreamer0.10-plugins-good"
#DEPS+=" gstreamer0.10-plugins-bad"
#DEPS+=" gstreamer0.10-plugins-ugly"
# XKB fixes for Qt5.4x
DEPS+=" libxkbfile1"
DEPS+=" x11-xkb-utils"
DEPS+=" xkb-data"
DEPS+=" libxkbfile-dev"
# SQLite 3 support
DEPS+=" libsqlite0-dev"
DEPS+=" libsqlite3-dev"
# SSL/TLS Support
DEPS+=" libssl-dev"
DEPS+=" gnutls-dev"
DEPS+=" libgnutls28-dev"
#	DEPS+=" libgnutls-openssl-dev" # Not available on debian
DEPS+=" libsslcommon2-dev"
# OpenCV support (for bottle rig)
DEPS+=" libopencv-calib3d-dev"
DEPS+=" libopencv-contrib-dev"
DEPS+=" libopencv-core-dev"
DEPS+=" libopencv-dev"
DEPS+=" libopencv-features2d-dev"
DEPS+=" libopencv-flann-dev"
DEPS+=" libopencv-gpu-dev"
DEPS+=" libopencv-highgui-dev"
DEPS+=" libopencv-imgproc-dev"
DEPS+=" libopencv-legacy-dev"
DEPS+=" libopencv-ml-dev"
DEPS+=" libopencv-objdetect-dev"
DEPS+=" libopencv-video-dev"
# Other
DEPS+=" libdrm-dev" # Kernel DRM services
DEPS+=" libgst-dev" # Smalltalk virtual machine
DEPS+=" libjpeg62-turbo-dev" # JPEG
DEPS+=" libpng12-dev" # PNG
DEPS+=" firebird-dev" # Firebird
DEPS+=" libmysqlclient-dev" # MySQL
DEPS+=" libiodbc2-dev" # iODBC
DEPS+=" libpq-dev" # PostgreSQL
DEPS+=" freetds-dev" # Tabular DataStream
DEPS+=" libcups2-dev" # Common UNIX Printing System
DEPS+=" libglib2.0-dev" # GLib
DEPS+=" libraspberrypi-dev" # EGL/GLES/OpenVG/etc. libraries for the Raspberry Pi's VideoCore IV
DEPS+=" libxslt1-dev" # XML
DEPS+=" libicu-dev" # Unicode
DEPS+=" libudev-dev" # udev
DEPS+=" libdbus-1-dev" # D-Bus

do_prep(){
	# Install depedencies
	echo "-------------------- Installing depedencies"
	sudo apt-get update
	sudo apt-get install -y $DEPS 2>&1 | tee deps.out
}

do_clone(){
	# Clone repo
	echo "-------------------- Cloning repo: qt$VER"
	git clone $REPO
	cd "$B/qt$MAIN_VER"
	git checkout $VER
}

do_init(){
	# Initialize repo
	cd "$B/qt$MAIN_VER"
	echo "-------------------- Initializing repository"
	./init-repository $INIT_OPT 2>&1 | tee init.out
}

do_conf(){
	# Configure build
	cd "$B/qt$MAIN_VER"
	echo "-------------------- Configuring build"
	MAKEFLAGS=-j$CORES ./configure $CONF_OPT -prefix $INST_DIR 2>&1 | tee config.out
}

do_make(){
	# Build
	cd "$B/qt$MAIN_VER"
	echo "-------------------- Building qt$VER"
	make -j$CORES 2>&1 | tee make.out
}

do_install(){
	# Install
	cd "$B/qt$MAIN_VER"
	echo "-------------------- Installing in $INST_DIR"
	sudo make install -j$CORES 2>&1 | tee install.out
}

do_exports(){
	# Make startup script so export symbols
	cd ~
	mkdir -p "$SETUP_DIR"
	cd "$SETUP_DIR"
	> $SETUP.sh
	echo "export LD_LIBRARY_PATH=$INST_DIR/lib" >> $SETUP.sh
	echo "export PATH=$INST_DIR/bin:\$PATH" >> $SETUP.sh
	echo "export QT_QPA_EGLFS_PHYSICAL_WIDTH=510" >> $SETUP.sh
	echo "export QT_QPA_EGLFS_PHYSICAL_HEIGHT=290" >> $SETUP.sh

	# Make the script executable and run it
	chmod +x $SETUP.sh
	./$SETUP.sh

	# Append source to setup script in startup scripts
	echo "source ~/$SETUP_DIR/$SETUP.sh" >> ~/.profile
	echo "source ~/$SETUP_DIR/$SETUP.sh" >> ~/.bashrc
}

do_all(){
	do_prep
	do_clone
	do_init
	do_conf
	do_make
	do_install
	do_exports
}

while [ "${1+defined}" ];
do
	case $1 in
		prep* )    do_prep    ;;
		clone* )   do_clone   ;;
		init* )    do_init    ;;
		conf* )    do_conf    ;;
		make* )    do_make    ;;
		install* ) do_install ;;
		exports* ) do_exports ;;
		all* )     do_all     ;;
		*) echo "UNKNOWN COMMAND: '$1', SKIPPING..."	;;
	esac
	shift
done


echo "DONE"
