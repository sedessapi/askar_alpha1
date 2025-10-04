# Askar Import - Developer Guide

Technical documentation for developers working on the Askar Import application.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Build Instructions](#build-instructions)
3. [Project Structure](#project-structure)
4. [FFI Bridge Details](#ffi-bridge-details)
5. [API Specifications](#api-specifications)
6. [Development Workflow](#development-workflow)
7. [Testing](#testing)
8. [Deployment](#deployment)

---

## Architecture Overview

### Technology Stack

- **Frontend**: Flutter 3.9.2+ (Dart 3.9.2+)
- **Backend**: Rust (Aries Askar v0.3.2)
- **FFI Bridge**: Dart FFI ↔ Rust
- **Storage**: SQLite (via Aries Askar)
- **HTTP Client**: Dart `http` package
- **Platforms**: iOS, Android, macOS, Windows, Linux, Web

### High-Level Architecture

```
┌─────────────────────────────────────────┐
│         Flutter Application             │
│  ┌───────────────────────────────────┐  │
│  │  UI Layer (Material Design 3)     │  │
│  │  - WalletExportDownloadPage       │  │
│  │  - WalletImportPage               │  │
│  │  - JsonViewerPage                 │  │
│  └───────────────────────────────────┘  │
│                  ↓                       │
│  ┌───────────────────────────────────┐  │
│  │  Services Layer                   │  │
│  │  - AskarExportClient (HTTP)       │  │
│  │  - AskarFfi (FFI Bridge)          │  │
│  │  - CredentialVerifier             │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│       Rust FFI Bridge (Native)          │
│  ┌───────────────────────────────────┐  │
│  │  C-Compatible Functions           │  │
│  │  - provision_wallet               │  │
│  │  - import_bulk_entries            │  │
│  │  - list_categories                │  │
│  │  - list_entries                   │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│      Aries Askar (Rust Library)         │
│  - Encrypted SQLite Storage             │
│  - Key Management                       │
│  - Entry Management                     │
└─────────────────────────────────────────┘
```

### Data Flow

#### Phase 1: Download Export
```
User Input → AskarExportClient → HTTP GET → Server
         ← JSON Response ← ← ←
Response → Save to File → path_provider → Local Storage
```

#### Phase 2: Import to Wallet
```
User Input → AskarFfi.importBulkEntries() → Rust FFI
FFI → Aries Askar → Parse JSON → Insert Entries → SQLite
    ← Success/Error Stats ← ← ←
```

#### Phase 3: Verify Credential
```
Credential JSON → CredentialVerifier.verify()
               → Detect Format (W3C/AnonCreds)
               → Run Checks (Structure/Dates/Signatures/DIDs)
               → Return VerificationResult
```

---

## Build Instructions

### Prerequisites

#### 1. Install Rust and Targets

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Add Android targets
rustup target add aarch64-linux-android
rustup target add armv7-linux-androideabi  
rustup target add x86_64-linux-android

# Add macOS target (on macOS)
rustup target add aarch64-apple-darwin
```

#### 2. Install Android NDK

**Via Android Studio:**
1. Tools → SDK Manager
2. SDK Tools tab
3. Check "NDK (Side by side)" version 29.0.13113456
4. Click Apply

**Via Command Line:**
```bash
sdkmanager --install "ndk;29.0.13113456"
```

#### 3. Install Flutter Dependencies

```bash
cd /path/to/askar_import
flutter pub get
```

### Configure NDK Paths

**macOS/Linux:**
Update `.cargo/config.toml`:
```toml
[target.aarch64-linux-android]
linker = "/Users/YOUR_USERNAME/Library/Android/sdk/ndk/29.0.13113456/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android34-clang"
```

Update `rust_lib/build_android.sh`:
```bash
export NDK_HOME="$HOME/Library/Android/sdk/ndk/29.0.13113456"
```

**Windows:**
Update paths to use Windows format:
```
C:\Users\YOUR_USERNAME\AppData\Local\Android\sdk\ndk\29.0.13113456\...
```

### Build Rust Libraries

#### Android

```bash
cd rust_lib
./build_android.sh
cd ..
```

This compiles for:
- ARM64 (`aarch64-linux-android`)
- ARMv7 (`armv7-linux-androideabi`)
- x86_64 (`x86_64-linux-android`)

Output: `.so` files in `android/app/src/main/jniLibs/`

#### macOS

```bash
cd rust_lib/ffi_bridge
cargo build --release --target aarch64-apple-darwin
cp ../../target/aarch64-apple-darwin/release/libffi_bridge.dylib ../../macos/Frameworks/
cd ../..
```

Output: `libffi_bridge.dylib` in `macos/Frameworks/`

#### iOS

```bash
cd rust_lib/ffi_bridge
cargo build --release --target aarch64-apple-ios
# Copy to iOS frameworks
cd ../..
```

### Run the Application

```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Specific platform
flutter run -d macos      # macOS
flutter run -d chrome     # Web
flutter run -d windows    # Windows
```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Google Play)
flutter build appbundle --release

# iOS
flutter build ios --release

# macOS
flutter build macos --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release

# Web
flutter build web --release
```

---

## Project Structure

```
askar_import/
├── lib/
│   ├── main.dart                           # App entry point
│   ├── models/
│   │   └── verification_result.dart        # Verification data models
│   ├── services/
│   │   ├── askar_export_client.dart        # HTTP client for downloads
│   │   ├── askar_ffi.dart                  # Dart FFI bindings
│   │   └── credential_verifier.dart        # Credential validation
│   └── ui/
│       └── pages/
│           ├── wallet_export_download_page.dart  # Phase 1 UI
│           ├── wallet_import_page.dart           # Phase 2 UI
│           └── json_viewer_page.dart             # JSON viewer
├── rust_lib/
│   ├── build_android.sh                    # Android build script
│   └── ffi_bridge/
│       ├── Cargo.toml                      # Rust dependencies
│       └── src/
│           └── lib.rs                      # FFI implementation
├── android/                                # Android platform files
├── ios/                                   # iOS platform files
├── macos/                                 # macOS platform files
├── windows/                               # Windows platform files
├── linux/                                 # Linux platform files
├── web/                                   # Web platform files
├── .cargo/
│   └── config.toml                        # Cargo/NDK configuration
├── Cargo.toml                             # Rust workspace config
└── pubspec.yaml                           # Flutter dependencies
```

### Key Files

**Dart/Flutter:**
- `lib/services/askar_ffi.dart` - FFI bindings to Rust
- `lib/services/askar_export_client.dart` - HTTP client
- `lib/services/credential_verifier.dart` - Offline verification
- `lib/models/verification_result.dart` - Verification models

**Rust:**
- `rust_lib/ffi_bridge/src/lib.rs` - FFI exports
- `rust_lib/ffi_bridge/Cargo.toml` - Dependencies (Aries Askar)

**Build Configuration:**
- `.cargo/config.toml` - NDK linker paths
- `rust_lib/build_android.sh` - Android build automation

---

## FFI Bridge Details

### Overview

The FFI bridge connects Dart (Flutter) to Rust (Aries Askar) using C-compatible functions.

### Architecture

```
Dart (Flutter)
    ↓ DynamicLibrary.open()
[Dart FFI Layer]
    ↓ Native function calls
[C-Compatible Interface]
    ↓ #[no_mangle] pub extern "C"
[Rust Implementation]
    ↓ Uses tokio runtime
[Aries Askar Library]
    ↓ SQLite operations
[Encrypted Wallet Storage]
```

### FFI Functions

#### 1. `provision_wallet`

Creates a new encrypted wallet.

**Signature:**
```rust
#[no_mangle]
pub extern "C" fn provision_wallet(
    db_path_ptr: *const c_char,
    raw_key_ptr: *const c_char
) -> *mut c_char
```

**Input:**
- `db_path`: File path (e.g., `/path/to/wallet.db`)
- `raw_key`: Base58-encoded 32-byte encryption key

**Output (JSON):**
```json
{"success": true}
// or
{"success": false, "error": "message"}
```

#### 2. `import_bulk_entries`

Imports entries from export JSON into wallet.

**Signature:**
```rust
#[no_mangle]
pub extern "C" fn import_bulk_entries(
    db_path_ptr: *const c_char,
    raw_key_ptr: *const c_char,
    json_data_ptr: *const c_char
) -> *mut c_char
```

**Input:**
- `db_path`: Wallet database path
- `raw_key`: Wallet encryption key
- `json_data`: Export JSON string

**Expected JSON Format:**
```json
{
  "credential": [
    {
      "name": "cred_id_1",
      "value": {...},
      "tags": {"schema_id": "..."}
    }
  ],
  "schema": [...],
  "connection": [...]
}
```

**Output (JSON):**
```json
{
  "success": true,
  "imported": 150,
  "failed": 2,
  "categories": {
    "credential": {"imported": 100, "failed": 1},
    "schema": {"imported": 50, "failed": 1}
  }
}
```

#### 3. `list_categories`

Lists all categories and counts in wallet.

**Signature:**
```rust
#[no_mangle]
pub extern "C" fn list_categories(
    db_path_ptr: *const c_char,
    raw_key_ptr: *const c_char
) -> *mut c_char
```

**Output (JSON):**
```json
{
  "success": true,
  "categories": {
    "credential": 100,
    "schema": 50,
    "connection": 25
  },
  "total": 175
}
```

#### 4. `list_entries`

Lists all entries in wallet with full details.

**Signature:**
```rust
#[no_mangle]
pub extern "C" fn list_entries(
    db_path_ptr: *const c_char,
    raw_key_ptr: *const c_char
) -> *mut c_char
```

**Output (JSON):**
```json
{
  "success": true,
  "entries": [
    {
      "category": "credential",
      "name": "cred_id_1",
      "value": {...},
      "tags": [...]
    }
  ]
}
```

#### 5. `free_string`

Frees memory allocated by Rust for returned strings.

**Signature:**
```rust
#[no_mangle]
pub extern "C" fn free_string(ptr: *mut c_char)
```

### Memory Management

**Important:** All C strings returned from Rust must be freed!

```dart
ffi.Pointer<Utf8> resultPtr = ffi.nullptr;
try {
  resultPtr = _nativeFunction(args);
  final resultString = resultPtr.toDartString();
  return jsonDecode(resultString);
} finally {
  if (resultPtr != ffi.nullptr) {
    _freeString(resultPtr);  // Always free!
  }
  // Free input pointers too
  malloc.free(inputPtr1);
  malloc.free(inputPtr2);
}
```

### Error Handling

FFI functions never throw exceptions. All errors returned as JSON:

```json
{
  "success": false,
  "error": "Descriptive error message"
}
```

Dart code checks `success` field and handles accordingly.

---

## API Specifications

### AskarExportClient

HTTP client for downloading wallet exports from Askar server.

#### Methods

**`healthz()`**
```dart
Future<bool> healthz()
```
- Checks server health
- Returns: `true` if healthy, throws `AskarExportException` on error
- Timeout: 8 seconds

**`downloadExport()`**
```dart
Future<String> downloadExport({
  required String profile,
  bool pretty = false,
})
```
- Downloads wallet export
- Returns: JSON string
- Throws: `AskarExportException` on error
- Timeout: 30 seconds

#### Error Handling

Custom exception with detailed information:
```dart
class AskarExportException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;
}
```

HTTP status code handling:
- `200` - Success
- `404` - Profile not found
- `401` - Authentication required
- `403` - Access denied
- `500` - Server error

### CredentialVerifier

Offline structural validation of credentials.

#### Methods

**`verify()`**
```dart
static Future<VerificationResult> verify(dynamic credential)
```
- Accepts: String (JSON) or Map (parsed)
- Returns: `VerificationResult` with status and checks
- Never throws: Returns error result on failure

#### Verification Categories

1. **Structure** - Required fields
2. **Dates** - Issuance/expiration validation
3. **Signatures** - Proof structure
4. **DIDs** - DID format validation

#### Supported Formats

- W3C Verifiable Credentials
- AnonCreds/Indy credentials
- Legacy Indy credentials

---

## Development Workflow

### Adding New Features

1. **Create branch**
   ```bash
   git checkout -b feature/your-feature
   ```

2. **Implement feature**
   - Update Dart/Flutter code in `lib/`
   - Update Rust code in `rust_lib/` if needed
   - Follow existing patterns

3. **Test locally**
   ```bash
   flutter test
   flutter run
   ```

4. **Build native libraries**
   ```bash
   cd rust_lib && ./build_android.sh && cd ..
   ```

5. **Commit and push**
   ```bash
   git add .
   git commit -m "feat: description"
   git push origin feature/your-feature
   ```

### Code Style

**Dart:**
- Follow `flutter_lints` rules
- Run `dart format lib/`
- Use descriptive variable names
- Document public APIs

**Rust:**
- Follow `rustfmt` style
- Run `cargo fmt`
- Add doc comments for public functions
- Handle errors explicitly

### Debugging

**Flutter DevTools:**
```bash
flutter run
# Open DevTools URL from console output
```

**Rust Logging:**
```rust
eprintln!("Debug: {}", value);  // Prints to stderr
```

**FFI Debugging:**
- Check pointer validity
- Verify string encoding (UTF-8)
- Confirm memory freed properly
- Test with simple values first

---

## Testing

### Unit Tests

**Dart:**
```bash
flutter test
flutter test test/specific_test.dart
```

**Rust:**
```bash
cd rust_lib/ffi_bridge
cargo test
```

### Integration Tests

```bash
flutter test integration_test/
```

### Manual Testing Checklist

**Phase 1 (Download):**
- [ ] Health check succeeds
- [ ] Download completes
- [ ] File saved correctly
- [ ] JSON viewer displays content
- [ ] Statistics accurate

**Phase 2 (Import):**
- [ ] Wallet creation succeeds
- [ ] Import completes
- [ ] All categories imported
- [ ] Statistics accurate
- [ ] View All shows entries

**Phase 3 (Verification):**
- [ ] W3C credentials verify
- [ ] AnonCreds credentials verify
- [ ] Non-credentials skipped
- [ ] Results display correctly
- [ ] Auto-scroll works

**Copy JSON:**
- [ ] Button visible
- [ ] Copy succeeds
- [ ] JSON formatted
- [ ] Clipboard contains data

---

## Deployment

### Release Checklist

1. **Version bump**
   - Update `pubspec.yaml` version
   - Update documentation versions
   - Create release notes

2. **Build all platforms**
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   flutter build ios --release
   flutter build macos --release
   flutter build windows --release
   flutter build linux --release
   flutter build web --release
   ```

3. **Test releases**
   - Install on physical devices
   - Test core workflows
   - Verify native libraries included

4. **Create GitHub release**
   - Tag version (e.g., `v1.0.0`)
   - Upload artifacts
   - Add release notes

### Platform-Specific Notes

**Android:**
- Requires `.so` files in `jniLibs`
- Test on ARM64, ARMv7, x86_64
- Check app signing for Play Store

**iOS:**
- Requires code signing
- Test on real devices (simulator may not support all features)
- Submit to App Store via Xcode

**macOS:**
- Requires code signing
- Place `.dylib` in `Frameworks/`
- Notarize for distribution

**Windows:**
- Include `.dll` files
- Test on Windows 10/11
- Create installer (optional)

**Web:**
- No native libraries needed
- CORS may affect server requests
- Test in multiple browsers

---

## Troubleshooting Development Issues

### Build Failures

**"Failed to lookup symbol"**
- Rust library not built or not found
- Run `./build_android.sh` again
- Check library copied to correct location

**NDK-related errors**
- Verify NDK version (29.0.13113456)
- Update linker paths in `.cargo/config.toml`
- Check `NDK_HOME` environment variable

**Aries Askar compilation errors**
- Using patched version from git (v0.3.2)
- Rust toolchain too old? Update: `rustup update`
- Check `Cargo.toml` has correct patch

### Runtime Issues

**"Failed to open store"**
- Wallet not created yet
- Wrong encryption key
- File permissions issue

**"Import failed"**
- Check JSON format matches expected
- Verify wallet open succeeded
- Check Rust logs (stderr)

**Crash on FFI call**
- Memory management issue
- Check all pointers freed
- Verify string encoding correct

---

## Contributing

### Guidelines

1. Follow existing code style
2. Add tests for new features
3. Update documentation
4. Keep commits atomic
5. Write descriptive commit messages

### Pull Request Process

1. Fork repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit PR with description
6. Address review feedback

---

## Resources

### Documentation
- [Flutter FFI Guide](https://dart.dev/guides/libraries/c-interop)
- [Aries Askar Documentation](https://github.com/hyperledger/aries-askar)
- [Rust Book](https://doc.rust-lang.org/book/)
- [Flutter Documentation](https://flutter.dev/docs)

### Tools
- [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools/overview)
- [Android Studio](https://developer.android.com/studio)
- [Xcode](https://developer.apple.com/xcode/) (macOS/iOS)
- [VS Code Flutter Extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)

---

**Version**: 1.0.0  
**Last Updated**: October 4, 2025  
**Maintainer**: sedessapi
