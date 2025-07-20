#!/bin/bash

. env.sh

# source the yocto env
source poky/oe-init-build-env "${BUILD_DIR}"

# Build
echo "Building images:bitbake -k ${IMAGES}"
bitbake -k "${IMAGES}"