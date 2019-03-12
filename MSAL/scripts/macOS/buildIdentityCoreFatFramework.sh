#!/bin/sh

# Sets the target folders and the final framework product.
FMK_NAME=IdentityCore
TGT_NAME="IdentityCore Mac"

echo "Building fat ${FMK_NAME} macOS static framework."

# Install dir will be the final output to the framework.
# The following line create it in the root folder of the current project.
PRODUCTS_DIR="${SRCROOT}/IdentityCore/IdentityCore/IdentityCore Static Framework/macOS"

# Working dir will be deleted after the framework creation.
WRK_DIR=${SRCROOT}/IdentityCore/IdentityCore/build
DEVICE_DIR=${WRK_DIR}/Release

# Make sure we're inside $SRCROOT.
cd "${SRCROOT}/IdentityCore/IdentityCore"

# Cleaning previous build.
xcodebuild -project "${FMK_NAME}.xcodeproj" -configuration "Release" -target "${TGT_NAME}" clean

# Building device architecture.
xcodebuild -project "${FMK_NAME}.xcodeproj" -configuration "Release" -target "${TGT_NAME}"

# Cleaning the previous build.
if [ -d "${PRODUCTS_DIR}" ]
then
rm -rf "${PRODUCTS_DIR}"
fi
mkdir -p "${PRODUCTS_DIR}"

# Move the library to the final directory.
LIB_MACOS_FINAL="${PRODUCTS_DIR}/lib${FMK_NAME}.a"

# Remove the framework at our final location as it will only contain device architectures.
rm -rf "$LIB_MACOS_FINAL"

echo "Use lipo -create to create the fat binary."
mv "${DEVICE_DIR}/lib${FMK_NAME}.a" "${LIB_MACOS_FINAL}"

# Delete the build directory
rm -rf "${WRK_DIR}"
