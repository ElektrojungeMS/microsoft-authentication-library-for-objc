#!/bin/sh

# Sets the target folders and the final framework product.
FMK_NAME=IdentityCore
TGT_NAME="IdentityCore iOS"

echo "Building fat ${FMK_NAME} iOS static framework."

# Install dir will be the final output to the framework.
# The following line create it in the root folder of the current project.
PRODUCTS_DIR="${SRCROOT}/IdentityCore/IdentityCore/IdentityCore Static Framework/iOS"

# Working dir will be deleted after the framework creation.
WRK_DIR=${SRCROOT}/IdentityCore/IdentityCore/build
DEVICE_DIR=${WRK_DIR}/Release-iphoneos
SIMULATOR_DIR=${WRK_DIR}/Release-iphonesimulator

# Make sure we're inside $SRCROOT.
cd "${SRCROOT}/IdentityCore/IdentityCore"

# Cleaning previous build.
xcodebuild -project "${FMK_NAME}.xcodeproj" -configuration "Release" -target "${TGT_NAME}" clean

# Building both device and simulator architectures.
xcodebuild -project "${FMK_NAME}.xcodeproj" -configuration "Release" -target "${TGT_NAME}" -sdk iphoneos
xcodebuild -project "${FMK_NAME}.xcodeproj" -configuration "Release" -target "${TGT_NAME}" -sdk iphonesimulator

# Cleaning the previous build.
if [ -d "${PRODUCTS_DIR}" ]
then
rm -rf "${PRODUCTS_DIR}"
fi
mkdir -p "${PRODUCTS_DIR}"

# Lipo it the device binary that was created with the simulator binary.
LIB_IPHONEOS_FINAL="${PRODUCTS_DIR}/lib${FMK_NAME}.a"

# Remove the framework at our final location as it will only contain device architectures.
rm -rf "$LIB_IPHONEOS_FINAL"

echo "Use lipo -create to create the fat binary."
lipo -create "${DEVICE_DIR}/lib${FMK_NAME}.a" "${SIMULATOR_DIR}/lib${FMK_NAME}.a" -output "${LIB_IPHONEOS_FINAL}"

# Delete the build directory
rm -rf "${WRK_DIR}"


