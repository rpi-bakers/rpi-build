#!/bin/bash

###############################################################################
# Rpi build BSP build environment settings.
###############################################################################

###############################################################################
# Yocto layer manifest settings.

# -----------------------------------------------------------------------------
MANIFEST_VER="torizon-default"
#MANIFEST_VER="rpi-0.1.0-promax"
#MANIFEST_VER="rpi-0.1.0-rpi3"
#MANIFEST_VER="rpi-0.0.1"

REMOTE="https://github.com/rpi-bakers/rpi-manifest"
BRANCH="torizon"
MANIFEST="${MANIFEST_VER}.xml"

###############################################################################
# Rpi-build Variables:

###############################################################################
# Yocto Project Variables:

# -----------------------------------------------------------------------------
# If you want to reduce disk usage, set the SSTATE_DIR and DL_DIR to a common location.
# SSTATE_DIR: When building code, cache files will be generated here.
# DL_DIR: Resources needed for building downloaded from the internet will be stored here.
SSTATE_DIR="/srv/yocto/torizon/sstate-cache"
DL_DIR="/srv/yocto/downloads"

# -----------------------------------------------------------------------------
# select DISTRO
DISTRO=torizon
#DISTRO="rpi-build"
#DISTRO="pironman5-promax"
#DISTRO="pironman5-rpi3"
#DISTRO="pironman5"

# -----------------------------------------------------------------------------
# If you want to reduce system disk usage, you can set BUILD_DIR to a external drive.
# The build directory will be created automatically if it does not exist.
if [ "${DISTRO}" = "torizon" ]; then
    BUILD_DIR="build-torizon"
else
    BUILD_DIR="../build-${MANIFEST_VER}-${DISTRO}"
fi

# -----------------------------------------------------------------------------
# select MACHINE
if [ "${DISTRO}" = "rpi-build" ]; then
    MACHINE="raspberrypi3"
elif [ "${DISTRO}" = "pironman5-rpi3" ]; then
    MACHINE="raspberrypi3"
elif [ "${DISTRO}" = "pironman5-promax" ]; then
    MACHINE="raspberrypi5"
elif [ "${DISTRO}" = "pironman5" ]; then
    MACHINE="raspberrypi5"
elif [ "${DISTRO}" = "torizon" ]; then
    MACHINE="toradex-smarc-imx8mp"
else
    echo "Unknown DISTRO: ${DISTRO}"
    exit 1
fi

# -----------------------------------------------------------------------------
# select IMAGES
IMAGES="torizon-docker"
#IMAGES="core-image-x11xfce"
#IMAGES="core-image-westonxfce"

###############################################################################
# Print settings.
# -----------------------------------------------------------------------------
echo -e "REMOTE:\t\t\t${REMOTE}"
echo -e "BRANCH:\t\t\t${BRANCH}"
echo -e "MANIFEST:\t\t${MANIFEST}"
echo -e "SSTATE_DIR:\t\t${SSTATE_DIR}"
echo -e "DL_DIR:\t\t\t${DL_DIR}"
echo -e "BUILD_DIR:\t\t${BUILD_DIR}"
echo -e "MACHINE:\t\t${MACHINE}"
echo -e "DISTRO:\t\t\t${DISTRO}"
echo -e "IMAGES:\t\t\t${IMAGES}"
echo ""
