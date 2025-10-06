#!/bin/bash

# Script to copy Rust FFI library into the macOS app bundle
# This is called during the Flutter build process

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LIB_SOURCE="$PROJECT_ROOT/macos/libs/libffi_bridge.dylib"

# Check if the library exists
if [ ! -f "$LIB_SOURCE" ]; then
    echo "❌ Error: Rust library not found at $LIB_SOURCE"
    echo "Please run: cd rust_lib && ./build_all.sh"
    exit 1
fi

# For development builds, the library can be loaded from the source location
# The Dart FFI code will handle finding it

echo "✅ Rust library found at $LIB_SOURCE"

# Optionally copy to app bundle if BUILT_PRODUCTS_DIR is set (during Xcode build)
if [ -n "$BUILT_PRODUCTS_DIR" ] && [ -n "$FRAMEWORKS_FOLDER_PATH" ]; then
    DEST_DIR="$BUILT_PRODUCTS_DIR/$FRAMEWORKS_FOLDER_PATH"
    mkdir -p "$DEST_DIR"
    cp "$LIB_SOURCE" "$DEST_DIR/"
    echo "✅ Copied Rust library to app bundle: $DEST_DIR/libffi_bridge.dylib"
fi

exit 0
