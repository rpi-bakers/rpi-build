#!/bin/bash

. env.sh

# source the yocto env
 source poky/oe-init-build-env "${BUILD_DIR}"

# Build
bitbake "${IMAGES}"