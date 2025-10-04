#!/bin/bash

# Build script for Android Askar FFI bridge
# This compiles Rust code for multiple Android architectures

set -e  # Exit on error

echo "🚀 Starting Android build for Askar FFI bridge..."

# Add your NDK standalone toolchain to the PATH
export NDK_HOME="$HOME/Library/Android/sdk/ndk/29.0.13113456"

# Check if NDK exists
if [ ! -d "$NDK_HOME" ]; then
    echo "❌ Error: Android NDK not found at $NDK_HOME"
    echo "Please install NDK 29.0.13113456 or update the NDK_HOME path in this script"
    exit 1
fi

export PATH="$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin":$PATH

echo "📦 Building for ARM64 (aarch64-linux-android)..."
export CC_aarch64_linux_android="$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android34-clang"
export AR_aarch64_linux_android="$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-ar"
cargo build --target aarch64-linux-android --release

echo "📦 Building for ARMv7 (armv7-linux-androideabi)..."
export CC_armv7_linux_androideabi="$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/armv7a-linux-androideabi34-clang"
export AR_armv7_linux_androideabi="$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-ar"
cargo build --target armv7-linux-androideabi --release

echo "📦 Building for x86_64 (x86_64-linux-android)..."
export CC_x86_64_linux_android="$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/x86_64-linux-android34-clang"
export AR_x86_64_linux_android="$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-ar"
cargo build --target x86_64-linux-android --release

echo "📂 Creating jniLibs directories..."
mkdir -p ../android/app/src/main/jniLibs/arm64-v8a
mkdir -p ../android/app/src/main/jniLibs/armeabi-v7a
mkdir -p ../android/app/src/main/jniLibs/x86_64

echo "📋 Copying compiled libraries to Flutter project..."
cp ../target/aarch64-linux-android/release/libffi_bridge.so ../android/app/src/main/jniLibs/arm64-v8a/
cp ../target/armv7-linux-androideabi/release/libffi_bridge.so ../android/app/src/main/jniLibs/armeabi-v7a/
cp ../target/x86_64-linux-android/release/libffi_bridge.so ../android/app/src/main/jniLibs/x86_64/

echo ""
echo "✅ Build complete! Native libraries are ready:"
echo "   - arm64-v8a/libffi_bridge.so"
echo "   - armeabi-v7a/libffi_bridge.so"
echo "   - x86_64/libffi_bridge.so"
echo ""
echo "🎯 You can now run: flutter run"
