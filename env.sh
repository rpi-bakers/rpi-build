#!/bin/bash
# Default settings.

MANIFEST_VER="rpi-0.0.1"

REMOTE="https://github.com/rpi-bakers/rpi-manifest"
BRANCH="main"
MANIFEST="${MANIFEST_VER}.xml"

###############################################################################
# If you want to reduce disk usage, set the SSTATE_DIR and DL_DIR to a common location.
# SSTATE_DIR: When building code, cache files will be generated here.
# DL_DIR: Resources needed for building downloaded from the internet will be stored here.
SSTATE_DIR="/srv/yocto/sstate-cache"
DL_DIR="/srv/yocto/downloads"

###############################################################################
# If you want to reduce system disk usage, you can set BUILD_DIR to a external drive.
# The build directory will be created automatically if it does not exist.
BUILD_DIR="../build-${MANIFEST_VER}"

###############################################################################
# select MACHINE
#MACHINE="raspberrypi3"
MACHINE="raspberrypi5"

###############################################################################
# select DISTRO
#DISTRO="rpi-build"
DISTRO="pironman5"

###############################################################################
# select IMAGES
IMAGES="core-image-x11xfce"
#IMAGES="core-image-westonxfce"

###############################################################################
echo -e "REMOTE:\t\t${REMOTE}"
echo -e "BRANCH:\t\t${BRANCH}"
echo -e "MANIFEST:\t${MANIFEST}"
echo -e "SSTATE_DIR:\t${SSTATE_DIR}"
echo -e "DL_DIR:\t\t${DL_DIR}"
echo -e "BUILD_DIR:\t${BUILD_DIR}"
echo -e "MACHINE:\t${MACHINE}"
echo -e "DISTRO:\t\t${DISTRO}"
echo -e "IMAGES:\t\t${IMAGES}"
echo ""
