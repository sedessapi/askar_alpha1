# Build Instructions for Askar Import

## Complete Setup Guide

### 1. Install Prerequisites

#### Rust and Targets
```bash
# Install Rust (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Add Android targets
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi  
rustup target add x86_64-linux-android
```

**Important Note**: This project uses `aries-askar v0.3.2` from git (patched version) to resolve compatibility issues with newer Rust toolchains. The patch is pre-configured in `Cargo.toml`:

```toml
[patch.crates-io]
aries-askar = { git = "https://github.com/hyperledger/aries-askar", tag = "v0.3.2" }
```

This fixes compilation errors with `Box::generate` that occur in `aries-askar v0.3.1` on Rust 1.90+.

#### Android NDK
1. Open Android Studio
2. Go to Tools → SDK Manager
3. Select "SDK Tools" tab
4. Check "NDK (Side by side)" version 29.0.13113456
5. Click "Apply" to install

Or install via command line:
```bash
sdkmanager --install "ndk;29.0.13113456"
```

#### Flutter Dependencies
```bash
cd /path/to/askar_import
flutter pub get
```

### 2. Configure NDK Paths

Update the NDK path in two files if your NDK is in a different location:

**File: `.cargo/config.toml`**
```toml
[target.aarch64-linux-android]
linker = "/Users/YOUR_USERNAME/Library/Android/sdk/ndk/29.0.13113456/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android34-clang"
```

**File: `rust_lib/build_android.sh`**
```bash
export NDK_HOME="$HOME/Library/Android/sdk/ndk/29.0.13113456"
```

### 3. Build Rust Libraries

```bash
cd rust_lib
./build_android.sh
cd ..
```

**What this does:**
- Compiles Rust FFI bridge for ARM64, ARMv7, and x86_64
- Links against Android NDK toolchain
- Copies `.so` files to `android/app/src/main/jniLibs/`

**Expected output:**
```
🚀 Starting Android build for Askar FFI bridge...
📦 Building for ARM64 (aarch64-linux-android)...
   Compiling ffi_bridge v0.1.0 (/path/to/rust_lib/ffi_bridge)
    Finished `release` profile [optimized] target(s) in X.XXs
📦 Building for ARMv7 (armv7-linux-androideabi)...
   Compiling ffi_bridge v0.1.0 (/path/to/rust_lib/ffi_bridge)
    Finished `release` profile [optimized] target(s) in X.XXs
📦 Building for x86_64 (x86_64-linux-android)...
   Compiling ffi_bridge v0.1.0 (/path/to/rust_lib/ffi_bridge)
    Finished `release` profile [optimized] target(s) in X.XXs
📂 Creating jniLibs directories...
📋 Copying compiled libraries to Flutter project...
✅ Build complete! Native libraries are ready:
   - arm64-v8a/libffi_bridge.so
   - armeabi-v7a/libffi_bridge.so
   - x86_64/libffi_bridge.so

🎯 You can now run: flutter run
```

### 4. Run the Application

```bash
flutter run
```

Or for specific platforms:
```bash
# Android
flutter run -d android

# iOS (requires iOS Rust builds - not yet implemented)
flutter run -d ios

# Desktop (may require additional setup)
flutter run -d macos
flutter run -d windows
flutter run -d linux
```

### 5. Build Release APK

```bash
flutter build apk --release
```

Output will be at: `build/app/outputs/flutter-apk/app-release.apk`

## Troubleshooting

### Problem: "Failed to lookup symbol"

**Cause**: Native libraries not compiled or not in correct location

**Solution**:
```bash
cd rust_lib
./build_android.sh
cd ..
flutter clean
flutter run
```

### Problem: NDK not found

**Cause**: NDK path in config doesn't match your system

**Solution**:
1. Find your NDK location:
   ```bash
   ls ~/Library/Android/sdk/ndk/
   ```
2. Update paths in `.cargo/config.toml` and `rust_lib/build_android.sh`

### Problem: Rust compilation errors

**Cause**: Missing Rust targets or outdated toolchain

**Solution**:
```bash
rustup update
rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android
```

### Problem: "error: linker `aarch64-linux-android34-clang` not found"

**Cause**: NDK not properly installed or paths incorrect

**Solution**:
1. Verify NDK installation:
   ```bash
   ls ~/Library/Android/sdk/ndk/29.0.13113456/toolchains/llvm/prebuilt/darwin-x86_64/bin/
   ```
2. Should contain `aarch64-linux-android34-clang` and other toolchain binaries
3. If missing, reinstall NDK via Android Studio SDK Manager

### Problem: Flutter dependency conflicts

**Solution**:
```bash
flutter pub get
flutter pub upgrade
```

### Problem: Askar crate compilation fails

**Cause**: Network issues or missing system dependencies

**Solution**:
1. Check internet connection (Rust needs to download crates)
2. Try with git CLI for better networking:
   ```bash
   git config --global --add http.version HTTP/1.1
   cargo clean
   cd rust_lib && ./build_android.sh
   ```

## Build Verification

After successful build, verify the libraries exist:

```bash
ls -la android/app/src/main/jniLibs/*/libffi_bridge.so
```

Expected output:
```
android/app/src/main/jniLibs/arm64-v8a/libffi_bridge.so
android/app/src/main/jniLibs/armeabi-v7a/libffi_bridge.so
android/app/src/main/jniLibs/x86_64/libffi_bridge.so
```

## Clean Build

For a completely fresh build:

```bash
# Clean Rust build artifacts
cd rust_lib
cargo clean
cd ..

# Clean Flutter build
flutter clean

# Rebuild everything
cd rust_lib
./build_android.sh
cd ..
flutter pub get
flutter run
```

## Development Workflow

### Making Changes to Rust Code

1. Edit `rust_lib/ffi_bridge/src/lib.rs`
2. Rebuild native libraries:
   ```bash
   cd rust_lib
   ./build_android.sh
   cd ..
   ```
3. Hot restart Flutter app (press 'R' in terminal)

### Making Changes to Dart Code

1. Edit any `.dart` files
2. Hot reload (press 'r' in terminal) or Hot restart (press 'R')
3. No native rebuild needed

## CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Build
on: [push]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-java@v3
        with:
          java-version: '11'
          
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.2'
          
      - uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
          target: aarch64-linux-android
          
      - name: Build Rust libs
        run: cd rust_lib && ./build_android.sh
        
      - name: Build APK
        run: flutter build apk --release
```

## Additional Resources

- [Rust FFI Documentation](https://doc.rust-lang.org/nomicon/ffi.html)
- [Flutter FFI Guide](https://dart.dev/guides/libraries/c-interop)
- [Aries Askar Repository](https://github.com/hyperledger/aries-askar)
- [Android NDK Documentation](https://developer.android.com/ndk)

---

For more help, see the main [README.md](README.md) or open an issue on GitHub.
