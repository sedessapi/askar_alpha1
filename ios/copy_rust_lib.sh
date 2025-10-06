#!/bin/bash

# Script to copy Rust FFI library into the iOS app bundle
# This is called during the Flutter build process

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LIB_SOURCE_DEVICE="$PROJECT_ROOT/ios/libs/libffi_bridge.a"
LIB_SOURCE_SIM="$PROJECT_ROOT/ios/libs/libffi_bridge_sim.a"

# Check if the libraries exist
if [ ! -f "$LIB_SOURCE_DEVICE" ]; then
    echo "❌ Error: iOS device library not found at $LIB_SOURCE_DEVICE"
    echo "Please run: cd rust_lib && ./build_all.sh"
    exit 1
fi

if [ ! -f "$LIB_SOURCE_SIM" ]; then
    echo "❌ Error: iOS simulator library not found at $LIB_SOURCE_SIM"
    echo "Please run: cd rust_lib && ./build_all.sh"
    exit 1
fi

echo "✅ Rust libraries found"
echo "  Device: $LIB_SOURCE_DEVICE"
echo "  Simulator: $LIB_SOURCE_SIM"

# Determine which library to use based on the build configuration
if [ "$PLATFORM_NAME" = "iphonesimulator" ]; then
    LIB_TO_USE="$LIB_SOURCE_SIM"
    echo "📱 Building for iOS Simulator"
else
    LIB_TO_USE="$LIB_SOURCE_DEVICE"
    echo "📱 Building for iOS Device"
fi

# Copy to the appropriate location if BUILT_PRODUCTS_DIR is set
if [ -n "$BUILT_PRODUCTS_DIR" ]; then
    DEST_DIR="$BUILT_PRODUCTS_DIR"
    mkdir -p "$DEST_DIR"
    cp "$LIB_TO_USE" "$DEST_DIR/libffi_bridge.a"
    echo "✅ Copied Rust library to: $DEST_DIR/libffi_bridge.a"
fi

exit 0
