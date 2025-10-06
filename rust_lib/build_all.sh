#!/bin/bash

# Build script for Rust FFI bridge for macOS and Android

set -e

echo "🔨 Building Rust FFI bridge..."

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$SCRIPT_DIR"

# Build for macOS (Apple Silicon)
echo "📱 Building for macOS (Apple Silicon)..."
cargo build --release --target aarch64-apple-darwin

# Create macOS libs directory
mkdir -p "$PROJECT_ROOT/macos/libs"

# Copy macOS library
cp "$PROJECT_ROOT/target/aarch64-apple-darwin/release/libffi_bridge.dylib" \
   "$PROJECT_ROOT/macos/libs/"

echo "✅ macOS build complete: $PROJECT_ROOT/macos/libs/libffi_bridge.dylib"

# Build for iOS Device (ARM64)
echo "📱 Building for iOS Device (ARM64)..."
cargo build --release --target aarch64-apple-ios

# Build for iOS Simulator (Apple Silicon)
echo "📱 Building for iOS Simulator (Apple Silicon)..."
cargo build --release --target aarch64-apple-ios-sim

# Build for iOS Simulator (Intel)
echo "📱 Building for iOS Simulator (Intel)..."
cargo build --release --target x86_64-apple-ios

# Create universal binary for simulator
echo "Creating universal binary for iOS Simulator..."
lipo -create \
  "$PROJECT_ROOT/target/aarch64-apple-ios-sim/release/libffi_bridge.a" \
  "$PROJECT_ROOT/target/x86_64-apple-ios/release/libffi_bridge.a" \
  -output "$PROJECT_ROOT/target/libffi_bridge_sim.a"

# Create iOS libs directory
mkdir -p "$PROJECT_ROOT/ios/libs"

# Copy iOS libraries
cp "$PROJECT_ROOT/target/aarch64-apple-ios/release/libffi_bridge.a" \
   "$PROJECT_ROOT/ios/libs/libffi_bridge.a"
cp "$PROJECT_ROOT/target/libffi_bridge_sim.a" \
   "$PROJECT_ROOT/ios/libs/libffi_bridge_sim.a"

echo "✅ iOS builds complete."

# Build for Android (ARM64)
echo "📱 Building for Android (ARM64)..."

NDK_PATH="$HOME/Library/Android/sdk/ndk/29.0.13113456"
TOOLCHAIN_PATH="$NDK_PATH/toolchains/llvm/prebuilt/darwin-x86_64/bin"


if [ ! -d "$NDK_PATH" ]; then
    echo "❌ Android NDK not found at $NDK_PATH"
    echo "Please install Android NDK or update the path in this script"
    exit 1
fi

CC_aarch64_linux_android="$TOOLCHAIN_PATH/aarch64-linux-android30-clang" \
AR_aarch64_linux_android="$TOOLCHAIN_PATH/llvm-ar" \
CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER="$TOOLCHAIN_PATH/aarch64-linux-android30-clang" \
cargo build --release --target aarch64-linux-android

# Create Android jniLibs directory
mkdir -p "$PROJECT_ROOT/android/app/src/main/jniLibs/arm64-v8a"

# Copy Android library
cp "$PROJECT_ROOT/target/aarch64-linux-android/release/libffi_bridge.so" \
   "$PROJECT_ROOT/android/app/src/main/jniLibs/arm64-v8a/"

echo "✅ Android build complete: $PROJECT_ROOT/android/app/src/main/jniLibs/arm64-v8a/libffi_bridge.so"

echo ""
echo "🎉 All builds complete!"
echo ""
echo "📝 Summary:"
echo "  macOS:   $PROJECT_ROOT/macos/libs/libffi_bridge.dylib"
echo "  iOS:     $PROJECT_ROOT/ios/libs/libffi_bridge.a"
echo "  iOS Sim: $PROJECT_ROOT/ios/libs/libffi_bridge_sim.a"
echo "  Android: $PROJECT_ROOT/android/app/src/main/jniLibs/arm64-v8a/libffi_bridge.so"
echo ""
echo "You can now run 'flutter run' to test the application."
