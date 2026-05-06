#!/bin/bash

###############################################################################
# Rpi build BSP setup script.
###############################################################################

LOGPREFIX="[rpi-setup]"
LOGSEPARATOR="################################################################################"

echo "${LOGSEPARATOR}" ########################################################
echo "${LOGPREFIX} Setup environment."
. env.sh

echo "${LOGSEPARATOR}" ########################################################
echo "${LOGPREFIX} Initializing repository..."

###############################################################################
# Install repo command if not found (first time only)
#------------------------------------------------------------------------------
if ! command -v repo &> /dev/null; then
    echo "${LOGPREFIX} repo command not found..."

    # Install to ~/.local/bin
    mkdir -p ~/.local/bin
    curl -s https://storage.googleapis.com/git-repo-downloads/repo > ~/.local/bin/repo
    chmod a+x ~/.local/bin/repo

    # path while this shell is active
    export PATH="${HOME}/.local/bin:${PATH}"

    echo "${LOGPREFIX} Install repo into ~/.local/bin"
fi

#------------------------------------------------------------------------------
# Check repo version
repo --version

###############################################################################
# Fetch manifest if .repo directory does not exist
#------------------------------------------------------------------------------
if [ ! -d .repo ]; then
    echo "${LOGPREFIX} run repo init ..."
    repo init \
        -u "${REMOTE}" \
        -b "${BRANCH}" \
        -m "${MANIFEST}"
fi
echo ""

echo "${LOGSEPARATOR}" ########################################################
echo "${LOGPREFIX} Updating repository..."
###############################################################################

###############################################################################
echo "${LOGPREFIX} repo sync in progress..."
#------------------------------------------------------------------------------
repo sync -j"$(nproc)"
echo ""

echo "${LOGSEPARATOR}" ########################################################
echo "${LOGPREFIX} Init Yocto build environment..."
#------------------------------------------------------------------------------
SRC_DIR=$(pwd)

LOCAL_CONF="${BUILD_DIR}/conf/local.conf"

# Remove local.conf if it exists to avoid conflicts with previous settings.
rm -r "${LOCAL_CONF}"

# Set TEMPLATECONF for poky/scripts/oe-setup-builddir
TEMPLATECONF="${SRC_DIR}/meta-custom/conf/templates/default"

echo "${LOGPREFIX} Set TEMPLATECONF to ${TEMPLATECONF}"
echo "${LOGPREFIX} and initialize build env by poky/oe-init-build-env with BUILD_DIR='${BUILD_DIR}' ..."
echo "${LOGPREFIX} source poky/oe-init-build-env ${BUILD_DIR}"
echo ""
# Yocto's interface to initialize the build environment.
source poky/oe-init-build-env "${BUILD_DIR}"
echo ""

unset TEMPLATECONF

echo "${LOGSEPARATOR}" ########################################################
echo "${LOGPREFIX} Copy env.sh settings to local.conf..."
#------------------------------------------------------------------------------
{
    echo "SSTATE_DIR = \"${SSTATE_DIR}\""
    echo "DL_DIR = \"${DL_DIR}\""
    echo "MACHINE = \"${MACHINE}\""
    echo "DISTRO = \"${DISTRO}\""
} >> "${LOCAL_CONF}"

###############################################################################
cd "${SRC_DIR}" || exit

echo "${LOGPREFIX} setup.sh finished."
echo "${LOGPREFIX} You can now run the build.sh command or run 'bitbake'."
echo ""
