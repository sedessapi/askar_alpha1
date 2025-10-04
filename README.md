# Askar Import/Export - Complete Wallet Migration Tool# Askar Import - Flutter Application



A comprehensive Flutter application for downloading Askar wallet exports from a server and importing them into local encrypted Askar wallets using Rust FFI.A Flutter application for downloading and viewing Askar wallet exports from remote servers. This app provides a user-friendly interface to connect to Askar export servers, download wallet data in JSON format, and view the exported content with comprehensive file management capabilities.



## 🎯 Overview## 📱 Features



This project implements a two-phase approach for Aries Askar wallet migration:### Core Functionality

- **Server Health Check**: Verify connectivity and server status before downloading

- **Phase 1: Download** - Download wallet exports from an Askar server via REST API- **Export Download**: Download wallet exports from Askar servers in JSON format

- **Phase 2: Import** - Import downloaded exports into local encrypted Askar wallets- **File Management**: Browse, view, and delete previously downloaded export files

- **JSON Viewer**: Advanced JSON content viewer with formatting and analysis tools

## ✨ Features

### User Experience

### Phase 1: Download Export ✅- **Input Validation**: Real-time validation for server URLs and profile names

- ✅ Server health checks- **Clipboard Support**: Paste server URLs and profile names from clipboard (⌘+V on macOS)

- ✅ Download wallet exports from Askar server- **Error Handling**: Comprehensive error messages and user feedback

- ✅ JSON viewer with credentials analysis- **Progress Indicators**: Visual feedback during downloads and operations

- ✅ Export statistics (schemas, credential definitions, categories)- **File Summary**: Automatic analysis of export content (categories, record counts)

- ✅ Local file management (view, delete, browse)

- ✅ Clipboard integration (⌘+V support on Mac)### Platform Support

- ✅ Input validation and error handling- ✅ **iOS** (iPhone/iPad)

- ✅ **macOS** (Desktop)

### Phase 2: Import to Wallet ✅- ✅ **Android** (Phone/Tablet)

- ✅ Create encrypted Askar wallets- ✅ **Windows** (Desktop)

- ✅ Import bulk entries with categories and tags- ✅ **Linux** (Desktop)

- ✅ Category-aware import from export structure- ✅ **Web** (Browser)

- ✅ Wallet statistics and contents viewing

- ✅ Progress tracking and detailed results## 🚀 Getting Started

- ✅ Rust FFI bridge for native performance

- ✅ Support for credentials, schemas, and all Askar record types### Prerequisites

- **Flutter SDK**: 3.9.2 or higher

## 🏗️ Architecture- **Dart SDK**: Included with Flutter

- **Platform-specific requirements**:

```  - **iOS/macOS**: Xcode 12+ and iOS 11+ / macOS 10.14+

Flutter (Dart)  - **Android**: Android Studio with API level 21+

    ↓  - **Windows**: Windows 10+ with Visual Studio 2019+

┌─────────────────────────┐  - **Linux**: GTK 3.0+

│  Phase 1: Download      │

│  - HTTP Client          │### Installation

│  - JSON Viewer          │

│  - File Management      │1. **Clone the repository**

└─────────────────────────┘   ```bash

    ↓   git clone <repository-url>

┌─────────────────────────┐   cd askar_import

│  Phase 2: Import        │   ```

│  - Dart FFI Bindings    │

└─────────────────────────┘2. **Install dependencies**

    ↓   ```bash

┌─────────────────────────┐   flutter pub get

│  Rust FFI Bridge        │   ```

│  - provision_wallet     │

│  - import_bulk_entries  │3. **Run the application**

│  - list_categories      │   ```bash

└─────────────────────────┘   # Debug mode

    ↓   flutter run

┌─────────────────────────┐   

│  Aries Askar (Rust)     │   # Release mode

│  - SQLite Storage       │   flutter run --release

│  - Encrypted Wallet     │   

└─────────────────────────┘   # Specific platform

```   flutter run -d macos    # macOS

   flutter run -d chrome   # Web

## 📋 Prerequisites   flutter run -d windows  # Windows

   ```

- **Flutter SDK**: 3.9.2 or higher

- **Dart SDK**: 3.9.2 or higher  ### Building for Production

- **Rust**: Latest stable toolchain

- **Android NDK**: 29.0.13113456 (for Android builds)```bash

- **Xcode**: (for iOS/macOS builds)# iOS (requires macOS and Xcode)

flutter build ios --release

### Install Rust Targets for Android

# Android APK

```bashflutter build apk --release

rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android

```# Android App Bundle (recommended for Google Play)

flutter build appbundle --release

## 🚀 Getting Started

# macOS

### 1. Clone and Install Dependenciesflutter build macos --release



```bash# Windows

git clone https://github.com/sedessapi/askar_import.gitflutter build windows --release

cd askar_import

flutter pub get# Linux

```flutter build linux --release



### 2. Build Rust Native Libraries# Web

flutter build web --release

```bash```

cd rust_lib

./build_android.sh## 📖 Usage

cd ..

```### 1. Server Configuration

1. Enter the **Server URL** (e.g., `http://mary9.com:9070`)

This will:2. Enter the **Profile Name** (tenant/wallet identifier)

- Compile Rust code for ARM64, ARMv7, and x86_643. Use the **Paste** button to paste from clipboard if needed

- Copy `.so` files to `android/app/src/main/jniLibs/`4. Click **Check Health** to verify server connectivity



### 3. Run the Application### 2. Download Export

1. After successful health check, click **Download Export JSON**

```bash2. Monitor the progress via status messages

flutter run3. Export will be saved to device documents directory

```4. View download summary (records count, categories)



## 📱 Usage Guide### 3. View Exports

1. Click **View File Contents** to open the JSON viewer for current export

### Phase 1: Download Exports2. Use **View All Files** to browse all saved exports

3. **JSON Viewer Features**:

1. **Enter Server Details**   - Toggle between formatted and raw JSON

   - Server URL: `http://your-server.com:9070`   - Copy content to clipboard

   - Profile Name: Your wallet/tenant identifier   - View export summary and statistics

   - Delete old files

2. **Check Server Health**

   - Click "Check Health" to verify connectivity### 4. File Management

- **Browse**: View all downloaded export files with timestamps

3. **Download Export**- **Delete**: Remove unwanted export files

   - Click "Download Export JSON"- **View**: Open any export file in the JSON viewer

   - File saved to app documents directory- **Copy Path**: Get file system path for external access

   - View contents with detailed analysis

## 🏗️ Architecture

4. **View Exports**

   - Browse all downloaded exports### Project Structure

   - View credentials summary```

   - See categories breakdownlib/

   - Copy file paths to clipboard├── main.dart                    # Application entry point

├── services/

### Phase 2: Import to Wallet│   └── askar_export_client.dart # HTTP client for Askar API

└── ui/

1. **Create Wallet**    └── pages/

   - Enter wallet name (e.g., `my_wallet`)        ├── wallet_export_download_page.dart # Main UI

   - Provide encryption key (Base58-encoded 32-byte key)        └── json_viewer_page.dart           # JSON viewer UI

   - Click "Create New Wallet"

test/

2. **Select Export File**└── widget_test.dart            # Widget tests

   - Choose from previously downloaded exports

   - See file modification datesandroid/                        # Android platform files

ios/                           # iOS platform files

3. **Import**macos/                         # macOS platform files

   - Click "Import Selected File"windows/                       # Windows platform files

   - View progress and resultslinux/                         # Linux platform files

   - See per-category statisticsweb/                          # Web platform files

```

4. **View Wallet Contents**

   - See total entries### Key Components

   - Browse by category

   - Verify imported data#### `AskarExportClient`

- HTTP client for Askar server communication

## 🔧 Configuration- Comprehensive error handling and validation

- Support for health checks and export downloads

### Android NDK Path- Proper resource management (connection disposal)



Update in `.cargo/config.toml` and `rust_lib/build_android.sh`:#### `WalletExportDownloadPage`

- Main application interface

```toml- Form validation and user input handling

[target.aarch64-linux-android]- File management and clipboard integration

linker = "/path/to/your/ndk/aarch64-linux-android34-clang"- Progress tracking and status updates

```

#### `JsonViewerPage`

### Wallet Keys- Advanced JSON content viewer

- Export analysis and statistics

⚠️ **Security Note**: The default key in the code is for demonstration only!- Copy-to-clipboard functionality

- Responsive layout with overflow protection

For production:

- Generate keys securely## 🔧 Configuration

- Use platform keystore/keychain

- Implement proper key derivation### Dependencies

- Never hardcode production keys```yaml

dependencies:

Example key generation:  flutter: sdk: flutter

```bash  cupertino_icons: ^1.0.8   # iOS-style icons

# Generate a random 32-byte key and encode as Base58  http: ^1.5.0              # HTTP client

openssl rand 32 | base58  path_provider: ^2.1.5     # File system access

```

dev_dependencies:

## 📚 API Documentation  flutter_test: sdk: flutter

  flutter_lints: ^6.0.0     # Code quality checks

### Rust FFI Functions```



#### `provision_wallet`## 🧪 Testing

Creates a new encrypted wallet.

### Run Tests

```rust```bash

provision_wallet(db_path: *const c_char, raw_key: *const c_char) -> *mut c_char# All tests

```flutter test



#### `import_bulk_entries`# Specific test file

Imports entries from export JSON into wallet.flutter test test/widget_test.dart



```rust# With coverage

import_bulk_entries(flutter test --coverage

    db_path: *const c_char,```

    raw_key: *const c_char, 

    json_data: *const c_char## 🔒 Security Considerations

) -> *mut c_char

```### Network Security

- **HTTPS Support**: Supports secure connections (recommended)

Returns:- **Input Sanitization**: Validates and sanitizes all user inputs

```json- **URL Validation**: Prevents malformed URL attacks

{

  "success": true,### Data Handling

  "imported": 150,- **Local Storage**: Files stored in secure app documents directory

  "failed": 2,- **No Persistent Credentials**: No authentication data stored

  "categories": {- **Clipboard Security**: Secure clipboard access with proper permissions

    "credential": {"imported": 100, "failed": 1},

    "schema": {"imported": 50, "failed": 1}## 🐛 Troubleshooting

  }

}### Common Issues

```

#### **Network Connection Failed**

#### `list_categories`- Verify server URL is correct and accessible

Lists all categories and counts in the wallet.- Check network connectivity

- Try HTTP instead of HTTPS for local development

```rust

list_categories(db_path: *const c_char, raw_key: *const c_char) -> *mut c_char#### **Profile Not Found (404)**

```- Verify the profile/tenant name is correct

- Check if profile exists on the server

### Export JSON Format

#### **Permission Denied (403)**

```json- Check if authentication is required

{- Contact server administrator

  "credential": [

    {#### **Server Error (500)**

      "name": "credential_id_1",- Server-side issue, try again later

      "value": {- Contact server administrator

        "schema_id": "...",

        "cred_def_id": "...",## 📋 Roadmap

        ...

      },### Phase 1 (Current) - Export Download

      "tags": {- ✅ Server health checking

        "schema_id": "...",- ✅ JSON export download

        "state": "done"- ✅ File viewing and management

      }- ✅ Clipboard integration

    }

  ],### Phase 2 - Import Functionality

  "schema": [...],- 🔄 Local Askar wallet creation

  "credential_definition": [...]- 🔄 Import JSON data into wallet

}- 🔄 Encryption and security features

```

## 🔄 Version History

## 🏗️ Project Structure

### v1.0.0 (Current)

```- Initial release

askar_import/- Export download functionality

├── lib/- JSON viewer with analysis

│   ├── main.dart                    # App entry with navigation- Cross-platform support

│   ├── services/- Clipboard integration

│   │   ├── askar_export_client.dart # HTTP client for downloads- Comprehensive error handling

│   │   └── askar_ffi.dart          # Dart FFI bindings

│   └── ui/pages/---

│       ├── wallet_export_download_page.dart  # Phase 1 UI

│       ├── wallet_import_page.dart           # Phase 2 UI**Note**: This is Phase 1 of the Askar Import project. Future phases will include actual wallet import functionality and advanced security features.

│       └── json_viewer_page.dart             # Export viewer
├── rust_lib/
│   ├── build_android.sh            # Build script
│   └── ffi_bridge/
│       ├── Cargo.toml
│       └── src/
│           └── lib.rs              # Rust FFI implementation
├── android/                        # Android project files
├── ios/                           # iOS project files
├── Cargo.toml                     # Rust workspace config
├── .cargo/config.toml            # NDK configuration
└── README.md                      # This file
```

## 🔍 Troubleshooting

### "Failed to lookup symbol" Error

The native library wasn't found:

```bash
cd rust_lib
./build_android.sh
cd ..
flutter clean
flutter run
```

### NDK Version Mismatch

Update paths in:
- `.cargo/config.toml`
- `rust_lib/build_android.sh`

### Import Fails with "Failed to open store"

- Verify wallet was created successfully
- Check wallet key is correct (Base58-encoded 32 bytes)
- Ensure wallet file exists at specified path

### JSON Parse Error

- Verify export file format matches expected structure
- Check file isn't corrupted
- Ensure categories are arrays of objects with name/value/tags

## 🔒 Security Considerations

⚠️ **Important for Production**:

1. **Key Management**
   - Use platform-specific secure storage
   - iOS: Keychain Services
   - Android: AndroidKeyStore
   - Never hardcode keys

2. **Input Validation**
   - All inputs are validated
   - SQL injection prevention via parameterized queries (Askar handles this)
   - Path traversal prevention

3. **Network Security**
   - HTTPS support for server communication
   - Certificate validation
   - Timeout management

4. **File Security**
   - Files stored in app-private directory
   - Platform sandboxing enforced
   - Proper file permissions

## 📈 Performance

- **Bulk Import**: Handles thousands of entries efficiently
- **Async Operations**: Non-blocking UI during import
- **Memory Management**: Proper cleanup of FFI resources
- **Native Speed**: Rust FFI for performance-critical operations

## 🧪 Testing

```bash
# Run Dart tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Build for release
flutter build apk --release
```

## 📖 Additional Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed technical architecture
- [Aries Askar Documentation](https://github.com/hyperledger/aries-askar)
- [Flutter FFI Guide](https://dart.dev/guides/libraries/c-interop)

## 🛣️ Roadmap

### Future Enhancements

- [ ] iOS/macOS native library builds
- [ ] Wallet backup and restore
- [ ] Export from wallet (reverse operation)
- [ ] Multi-wallet management
- [ ] Advanced filtering and search
- [ ] Wallet merging capabilities
- [ ] Key rotation support
- [ ] Cloud backup integration

## 📝 License

This project is a demonstration for Askar wallet migration. Check individual component licenses:
- Flutter: BSD 3-Clause
- Aries Askar: Apache 2.0  
- Rust: MIT/Apache 2.0

## 🤝 Contributing

This is a demonstration project. For production use, consider:
- Adding comprehensive tests
- Implementing proper key management
- Adding backup/restore functionality
- Enhanced error handling
- Logging and monitoring

## 📧 Support

For issues and questions:
- GitHub Issues: [https://github.com/sedessapi/askar_import/issues](https://github.com/sedessapi/askar_import/issues)

---

**Built with ❤️ using Flutter, Rust, and Aries Askar**
