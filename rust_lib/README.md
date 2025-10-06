# Rust FFI Integration

This directory contains the Rust code for the FFI (Foreign Function Interface) bridge to the Aries Askar library.

## Prerequisites

- **Rust**: Install from https://rustup.rs/
- **Android NDK**: Required for Android builds (version 29.0.13113456 or later)
  - Install via Android Studio SDK Manager
  - Default location: `~/Library/Android/sdk/ndk/`

## Building

### Quick Build (macOS + Android)

Run the build script to compile for both platforms:

```bash
cd rust_lib
./build_all.sh
```

This will:
1. Build for macOS (Apple Silicon): `aarch64-apple-darwin`
2. Build for iOS Device (ARM64): `aarch64-apple-ios`
3. Build for iOS Simulator (Apple Silicon + Intel): `aarch64-apple-ios-sim`, `x86_64-apple-ios`
4. Build for Android (ARM64): `aarch64-linux-android`
5. Copy libraries to the correct locations

### Manual Builds

#### macOS (Apple Silicon)

```bash
cd rust_lib
cargo build --release --target aarch64-apple-darwin
cp target/aarch64-apple-darwin/release/libffi_bridge.dylib ../macos/libs/
```

#### Android (ARM64)

```bash
cd rust_lib

NDK_PATH="$HOME/Library/Android/sdk/ndk/29.0.13113456"
TOOLCHAIN_PATH="$NDK_PATH/toolchains/llvm/prebuilt/darwin-x86_64/bin"

CC_aarch64_linux_android="$TOOLCHAIN_PATH/aarch64-linux-android30-clang" \
AR_aarch64_linux_android="$TOOLCHAIN_PATH/llvm-ar" \
CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER="$TOOLCHAIN_PATH/aarch64-linux-android30-clang" \
cargo build --release --target aarch64-linux-android

cp target/aarch64-linux-android/release/libffi_bridge.so \
   ../android/app/src/main/jniLibs/arm64-v8a/
```

## Library Locations

After building, the libraries should be placed at:

- **macOS**: `macos/libs/libffi_bridge.dylib`
- **iOS Device**: `ios/libs/libffi_bridge.a`
- **iOS Simulator**: `ios/libs/libffi_bridge_sim.a`
- **Android**: `android/app/src/main/jniLibs/arm64-v8a/libffi_bridge.so`

## Architecture

The FFI bridge exposes the following functions:

- `provision_wallet()` - Creates a new Askar wallet
- `insert_entry()` - Inserts a single entry into the wallet
- `list_entries()` - Lists all entries in the wallet
- `import_bulk_entries()` - Imports entries from Askar export JSON
- `list_categories()` - Lists all categories and their entry counts
- `free_string()` - Frees memory allocated by Rust

All functions return JSON strings that the Dart code parses.

## Configuration

The Android NDK configuration is stored in `.cargo/config.toml`. If you have a different NDK version or location, update the paths in:

1. `.cargo/config.toml`
2. `build_all.sh`

## Troubleshooting

### "Failed to load dynamic library"

This error means the Rust library wasn't found at runtime. Ensure:

1. The library was built for the correct platform
2. The library is in the correct location
3. For macOS, run `flutter clean` and rebuild

### Android build fails with "tool not found"

This means the Android NDK is not installed or the path is incorrect. Check:

1. Android NDK is installed via Android Studio
2. The NDK version in `build_all.sh` matches your installation
3. The path in `.cargo/config.toml` is correct

### Rust compiler errors

If you encounter Rust compilation errors:

1. Update Rust: `rustup update`
2. Clean the build: `cargo clean`
3. Rebuild: `./build_all.sh`

## Dependencies

The Rust code depends on:

- `aries-askar` - Hyperledger Aries Askar library
- `ffi-support` - FFI helper utilities
- `serde_json` - JSON serialization

See `Cargo.toml` for the complete dependency list.
