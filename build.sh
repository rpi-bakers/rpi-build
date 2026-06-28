#!/bin/bash

. env.sh

# source the yocto env
if [ "${DISTRO}" = "torizon" ]; then
    source layers/meta-toradex-torizon/scripts/setup-environment
else
    source poky/oe-init-build-env "${BUILD_DIR}"
fi

# Build
echo "Building images:bitbake -k ${IMAGES}"
bitbake -k "${IMAGES}"