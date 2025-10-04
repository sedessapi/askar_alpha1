# Quick Start Guide

## Run the App

```bash
cd /Users/itzmi/dev/offline/tests/askar_import
flutter run
```

## Test Workflow

### 1. Download Export (Tab 1)
```
Server URL: http://10.0.2.2:3000/wallets/test-profile/export
(Use 10.0.2.2 for Android emulator, or your local IP for physical device)

Profile: test-profile
```

### 2. Import to Wallet (Tab 2)
```
1. Create Wallet:
   - Wallet Name: my_imported_wallet
   - Raw Key: my-secret-key-32-bytes-long!!!

2. Select File:
   - Choose the downloaded export file

3. Import:
   - View import statistics by category
   - Check success/failure counts
```

## File Locations

- **Native Libraries**:
  - Android: `android/app/src/main/jniLibs/[arch]/libffi_bridge.so`
  - macOS: `macos/Frameworks/libffi_bridge.dylib`

- **Rust Source**: `rust_lib/ffi_bridge/src/lib.rs`
- **Dart FFI**: `lib/services/askar_ffi.dart`
- **UI Pages**: `lib/ui/pages/`

## Rebuild Native Libraries

```bash
# Android
cd rust_lib
./build_android.sh

# macOS
cd rust_lib/ffi_bridge
cargo build --release --target aarch64-apple-darwin
cp ../../target/aarch64-apple-darwin/release/libffi_bridge.dylib ../../macos/Frameworks/
```

## Clean Build

```bash
flutter clean
flutter pub get
cd rust_lib
./build_android.sh
cd ..
flutter run
```

## Troubleshooting

**Problem**: Library not found  
**Solution**: 
```bash
flutter clean
cd rust_lib && ./build_android.sh
cd .. && flutter run
```

**Problem**: FFI function fails  
**Solution**: Check logs with `adb logcat | grep -i rust`

**Problem**: Import fails  
**Solution**: Verify JSON format matches expected structure (categories with arrays of {name, value, tags})

## Key Files to Edit

- **Add FFI functions**: `rust_lib/ffi_bridge/src/lib.rs`
- **Update Dart bindings**: `lib/services/askar_ffi.dart`
- **Modify UI**: `lib/ui/pages/wallet_import_page.dart`
- **Update navigation**: `lib/main.dart`

---

**Documentation**: See README.md, BUILD_INSTRUCTIONS.md, and RUST_COMPATIBILITY_FIX.md for details.
