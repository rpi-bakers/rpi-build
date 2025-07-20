#!/bin/bash

. env.sh

###############################################################################
echo "[rpi-setup] Initializing repository..."
###############################################################################

###############################################################################
# Install repo command if not found (first time only)
#------------------------------------------------------------------------------
if ! command -v repo &> /dev/null; then
    echo "[rpi-setup] repo command not found..."

    # Install to ~/.local/bin
    mkdir -p ~/.local/bin
    curl -s https://storage.googleapis.com/git-repo-downloads/repo > ~/.local/bin/repo
    chmod a+x ~/.local/bin/repo

    # path while this shell is active
    export PATH="${HOME}/.local/bin:${PATH}"

    echo "[rpi-setup] Install repo into ~/.local/bin"
fi

#------------------------------------------------------------------------------
# Check repo version
repo --version

###############################################################################
# Fetch manifest if .repo directory does not exist
#------------------------------------------------------------------------------
if [ ! -d .repo ]; then
    echo "[rpi-setup] run repo init ..."
    repo init \
        -u "${REMOTE}" \
        -b "${BRANCH}" \
        -m "${MANIFEST}"
fi

###############################################################################
echo "[rpi-setup] Updating repository..."
###############################################################################

###############################################################################
echo "[rpi-setup] repo sync in progress..."
#------------------------------------------------------------------------------
repo sync -j"$(nproc)"

###############################################################################
echo "[rpi-setup] Init Yocto build environment..."
#------------------------------------------------------------------------------
SRC_DIR=$(pwd)
source poky/oe-init-build-env "${BUILD_DIR}"

###############################################################################
echo "[rpi-setup] Copying sample configuration files..."
#------------------------------------------------------------------------------
cp "${SRC_DIR}"/meta-custom/conf/templates/*.conf.sample conf/
mv conf/bblayers.conf.sample conf/bblayers.conf
mv conf/local.conf.sample conf/local.conf

###############################################################################
echo "[rpi-setup] replace %%SRC_DIR%% in conf/bblayers.conf with actual path"
#------------------------------------------------------------------------------
sed -i "s|%%SRC_DIR%%|${SRC_DIR}|g" conf/bblayers.conf

###############################################################################
echo "[rpi-setup] Copy env.sh settings to local.conf..."
{
  echo "SSTATE_DIR = \"${SSTATE_DIR}\""
  echo "DL_DIR = \"${DL_DIR}\""
  echo "MACHINE = \"${MACHINE}\""
} >> conf/local.conf

echo "[rpi-setup] setup.sh finished."
echo "[rpi-setup] You can now run the build.sh command or"
echo "[rpi-setup] run 'bitbake' after source oe-init-build-env to set up the bitbake environment."
echo "[rpi-setup] source ../poky/oe-init-build-env ${BUILD_DIR}"
echo "[rpi-setup] bitbake core-image-x11xfce"
