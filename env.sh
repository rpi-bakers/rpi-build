#!/bin/bash
# Default settings.

MANIFEST_VER="rpi-0.0.1"

###############################################################################
# If you want to reduce disk usage, set the SSTATE_DIR and DL_DIR to a common location.
# SSTATE_DIR: When building code, cache files will be generated here.
# DL_DIR: Resources needed for building downloaded from the internet will be stored here.
SSTATE_DIR="/srv/yocto/sstate-cache"
DL_DIR="/srv/yocto/downloads"

###############################################################################
# select raspberrypi 3 or 5
#MACHINE="raspberrypi3"
MACHINE="raspberrypi5"

IMAGES="core-image-x11xfce"

REMOTE="https://github.com/rpi-bakers/rpi-manifest"
BRANCH="main"
MANIFEST="${MANIFEST_VER}.xml"