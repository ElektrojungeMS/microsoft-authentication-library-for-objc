#!/bin/sh

# Sets the target folders and the final framework product.
FMK_NAME=MSAL
TGT_NAME=${FMK_NAME}

echo "Building ${FMK_NAME} iOS static framework."

# Install dir will be the final output to the framework.
# The following line create it in the root folder of the current project.
PRODUCTS_DIR=${SRCROOT}/../FooBar/iOS

# Working dir will be deleted after the framework creation.
WRK_DIR=build
DEVICE_DIR=${WRK_DIR}/Release-iphoneos
SIMULATOR_DIR=${WRK_DIR}/Release-iphonesimulator

# Make sure we're inside $SRCROOT.
cd "${SRCROOT}"

# Cleaning previous build.
xcodebuild -project "${FMK_NAME}.xcodeproj" -configuration "Release" -target "${TGT_NAME}" clean

# Building both architectures.
xcodebuild -project "${FMK_NAME}.xcodeproj" -configuration "Release" -target "${TGT_NAME}" -sdk iphoneos
xcodebuild -project "${FMK_NAME}.xcodeproj" -configuration "Release" -target "${TGT_NAME}" -sdk iphonesimulator

# Cleaning the oldest.
if [ -d "${PRODUCTS_DIR}" ]
then
rm -rf "${PRODUCTS_DIR}"
fi

mkdir -p $PRODUCTS_DIR

# Copy the swift import file
cp -R $DEVICE_DIR $PRODUCTS_DIR

# Create the arm64e slice in Xcode 10.1 and lipo it with the device binary that was created with oldest supported Xcode version.
LIB_IPHONEOS_FINAL="${PRODUCTS_DIR}/Release-iphoneos/${FMK_NAME}.framework/${FMK_NAME}"
#if [ -z "$MS_ARM64E_XCODE_PATH" ] || [ ! -d "$MS_ARM64E_XCODE_PATH" ]; then
#echo "Environment variable MS_ARM64E_XCODE_PATH not set or not a valid path."

echo "Use current Xcode version and lipo -create the fat binary."
lipo -create "${LIB_IPHONEOS_FINAL}" "${SIMULATOR_DIR}/${FMK_NAME}.framework/${FMK_NAME}" -output "${PRODUCTS_DIR}/${FMK_NAME}"

