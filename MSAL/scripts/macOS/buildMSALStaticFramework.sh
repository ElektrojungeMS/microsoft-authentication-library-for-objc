#!/bin/sh

# Sets the target folders and the final framework product.
FMK_NAME=MSAL
TGT_NAME="MSAL (Static Mac Framework)"

echo "Building fat ${FMK_NAME} macOS static framework."

# Install dir will be the final output to the framework.
# The following line create it in the root folder of the current project.
PRODUCTS_DIR="${SRCROOT}/MSAL Static Framework/macOS"

# Working dir will be deleted after the framework creation.
WRK_DIR=${SRCROOT}/build
DEVICE_DIR=${WRK_DIR}/Release

# Make sure we're inside $SRCROOT.
cd "${SRCROOT}"

# Cleaning previous build.
xcodebuild -project "${FMK_NAME}.xcodeproj" -configuration "Release" -target "${TGT_NAME}" clean

# Building both device and simulator architectures.
xcodebuild -project "${FMK_NAME}.xcodeproj" -configuration "Release" -target "${TGT_NAME}"

# Cleaning the previous build.
if [ -d "${PRODUCTS_DIR}" ]
then
rm -rf "${PRODUCTS_DIR}"
fi
mkdir -p "${PRODUCTS_DIR}"

# Copy the device .framework to the final destination to preserve the structure.
echo $DEVICE_DIR
echo $PRODUCTS_DIR
cp -R "$DEVICE_DIR/${FMK_NAME}.framework" "$PRODUCTS_DIR"

# Lipo it the device binary that was created with the simulator binary.
LIB_MACOS_FINAL="${PRODUCTS_DIR}/${FMK_NAME}.framework/${FMK_NAME}"

# Remove the framework at our final location as it will only contain device architectures.
rm -rf "$LIB_MACOS_FINAL"
mv "${DEVICE_DIR}/${FMK_NAME}.framework/${FMK_NAME}" "${LIB_MACOS_FINAL}"

# Delete the build directory
rm -rf "${WRK_DIR}"

# Add IdentityCore.
if [ -z $(otool -L "LIB_MACOS_FINAL" | grep 'libIdentityCore') ]
then
libtool -static  "${LIB_MACOS_FINAL}" "${SRCROOT}/IdentityCore/IdentityCore/IdentityCore Static Framework/macOS/libIdentityCore.a" -o "${LIB_MACOS_FINAL}"
fi
