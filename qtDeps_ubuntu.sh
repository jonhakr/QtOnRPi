#!/usr/bin/env bash
set -exu

# Install Qt 5.8 Linux Deps
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

# X11/XCB
DEPS+=" libfontconfig1-dev"
DEPS+=" libfreetype6-dev"
DEPS+=" libx11-dev"
DEPS+=" libxext-dev"
DEPS+=" libxfixes-dev"
DEPS+=" libxi-dev"
DEPS+=" libxrender-dev"
DEPS+=" libxcb1-dev"
DEPS+=" libx11-xcb-dev"
DEPS+=" libxcb-glx0-dev"

# Without '-qt-xcb'
DEPS+=" libxcb-keysyms1-dev"
DEPS+=" libxcb-image0-dev"
DEPS+=" libxcb-shm0-dev"
DEPS+=" libxcb-icccm4-dev"
DEPS+=" libxcb-sync0-dev"
DEPS+=" libxcb-xfixes0-dev"
DEPS+=" libxcb-shape0-dev"
DEPS+=" libxcb-randr0-dev"
DEPS+=" libxcb-render-util0-dev"

# Multimedia
DEPS+=" libasound2-dev"
DEPS+=" libpulse-dev"
DEPS+=" libavcodec-dev"
DEPS+=" libavformat-dev"
DEPS+=" libswscale-dev"
DEPS+=" gstreamer-tools"
DEPS+=" libgstreamer1.0-dev"
DEPS+=" libgstreamer-plugins-base1.0-dev"
DEPS+=" gstreamer1.0-plugins-good"
DEPS+=" gstreamer1.0-plugins-bad"
DEPS+=" gstreamer1.0-plugins-ugly"
DEPS+=" gstreamer1.0-libav"
#DEPS+=" libgstreamer0.10-dev" # We don't need 0.10 in Qt 5.8
#DEPS+=" libgstreamer-plugins-base0.10-dev"
#DEPS+=" gstreamer0.10-plugins-good"
#DEPS+=" gstreamer0.10-plugins-bad"
#DEPS+=" gstreamer0.10-plugins-ugly"

# WebEngine
DEPS+=" libbz2-dev"
DEPS+=" libcap-dev"
DEPS+=" libcups2-dev"
DEPS+=" libdrm-dev"
DEPS+=" libegl1-mesa-dev"
DEPS+=" libgcrypt11-dev"
DEPS+=" libnss3-dev"
DEPS+=" libpci-dev"
DEPS+=" libudev-dev"
DEPS+=" libxtst-dev"
DEPS+=" gyp"
DEPS+=" ninja-build"
DEPS+=" libssl-dev"
DEPS+=" libxcursor-dev"
DEPS+=" libxcomposite-dev"
DEPS+=" libxdamage-dev"
DEPS+=" libxrandr-dev"
DEPS+=" libxss-dev"
DEPS+=" libsrtp0-dev"
DEPS+=" libwebp-dev"
DEPS+=" libjsoncpp-dev"
DEPS+=" libopus-dev"
DEPS+=" libminizip-dev"
DEPS+=" libavutil-dev"
DEPS+=" libevent-dev"

sudo apt-get update
sudo apt-get install -y $DEPS 2>&1 | tee deps.log

