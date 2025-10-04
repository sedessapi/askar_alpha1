# Askar Import - Flutter Application

A Flutter application for downloading and viewing Askar wallet exports from remote servers. This app provides a user-friendly interface to connect to Askar export servers, download wallet data in JSON format, and view the exported content with comprehensive file management capabilities.

## 📱 Features

### Core Functionality
- **Server Health Check**: Verify connectivity and server status before downloading
- **Export Download**: Download wallet exports from Askar servers in JSON format
- **File Management**: Browse, view, and delete previously downloaded export files
- **JSON Viewer**: Advanced JSON content viewer with formatting and analysis tools

### User Experience
- **Input Validation**: Real-time validation for server URLs and profile names
- **Clipboard Support**: Paste server URLs and profile names from clipboard (⌘+V on macOS)
- **Error Handling**: Comprehensive error messages and user feedback
- **Progress Indicators**: Visual feedback during downloads and operations
- **File Summary**: Automatic analysis of export content (categories, record counts)

### Platform Support
- ✅ **iOS** (iPhone/iPad)
- ✅ **macOS** (Desktop)
- ✅ **Android** (Phone/Tablet)
- ✅ **Windows** (Desktop)
- ✅ **Linux** (Desktop)
- ✅ **Web** (Browser)

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: 3.9.2 or higher
- **Dart SDK**: Included with Flutter
- **Platform-specific requirements**:
  - **iOS/macOS**: Xcode 12+ and iOS 11+ / macOS 10.14+
  - **Android**: Android Studio with API level 21+
  - **Windows**: Windows 10+ with Visual Studio 2019+
  - **Linux**: GTK 3.0+

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd askar_import
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # Debug mode
   flutter run
   
   # Release mode
   flutter run --release
   
   # Specific platform
   flutter run -d macos    # macOS
   flutter run -d chrome   # Web
   flutter run -d windows  # Windows
   ```

### Building for Production

```bash
# iOS (requires macOS and Xcode)
flutter build ios --release

# Android APK
flutter build apk --release

# Android App Bundle (recommended for Google Play)
flutter build appbundle --release

# macOS
flutter build macos --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release

# Web
flutter build web --release
```

## 📖 Usage

### 1. Server Configuration
1. Enter the **Server URL** (e.g., `http://mary9.com:9070`)
2. Enter the **Profile Name** (tenant/wallet identifier)
3. Use the **Paste** button to paste from clipboard if needed
4. Click **Check Health** to verify server connectivity

### 2. Download Export
1. After successful health check, click **Download Export JSON**
2. Monitor the progress via status messages
3. Export will be saved to device documents directory
4. View download summary (records count, categories)

### 3. View Exports
1. Click **View File Contents** to open the JSON viewer for current export
2. Use **View All Files** to browse all saved exports
3. **JSON Viewer Features**:
   - Toggle between formatted and raw JSON
   - Copy content to clipboard
   - View export summary and statistics
   - Delete old files

### 4. File Management
- **Browse**: View all downloaded export files with timestamps
- **Delete**: Remove unwanted export files
- **View**: Open any export file in the JSON viewer
- **Copy Path**: Get file system path for external access

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                    # Application entry point
├── services/
│   └── askar_export_client.dart # HTTP client for Askar API
└── ui/
    └── pages/
        ├── wallet_export_download_page.dart # Main UI
        └── json_viewer_page.dart           # JSON viewer UI

test/
└── widget_test.dart            # Widget tests

android/                        # Android platform files
ios/                           # iOS platform files
macos/                         # macOS platform files
windows/                       # Windows platform files
linux/                         # Linux platform files
web/                          # Web platform files
```

### Key Components

#### `AskarExportClient`
- HTTP client for Askar server communication
- Comprehensive error handling and validation
- Support for health checks and export downloads
- Proper resource management (connection disposal)

#### `WalletExportDownloadPage`
- Main application interface
- Form validation and user input handling
- File management and clipboard integration
- Progress tracking and status updates

#### `JsonViewerPage`
- Advanced JSON content viewer
- Export analysis and statistics
- Copy-to-clipboard functionality
- Responsive layout with overflow protection

## 🔧 Configuration

### Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  cupertino_icons: ^1.0.8   # iOS-style icons
  http: ^1.5.0              # HTTP client
  path_provider: ^2.1.5     # File system access

dev_dependencies:
  flutter_test: sdk: flutter
  flutter_lints: ^6.0.0     # Code quality checks
```

## 🧪 Testing

### Run Tests
```bash
# All tests
flutter test

# Specific test file
flutter test test/widget_test.dart

# With coverage
flutter test --coverage
```

## 🔒 Security Considerations

### Network Security
- **HTTPS Support**: Supports secure connections (recommended)
- **Input Sanitization**: Validates and sanitizes all user inputs
- **URL Validation**: Prevents malformed URL attacks

### Data Handling
- **Local Storage**: Files stored in secure app documents directory
- **No Persistent Credentials**: No authentication data stored
- **Clipboard Security**: Secure clipboard access with proper permissions

## 🐛 Troubleshooting

### Common Issues

#### **Network Connection Failed**
- Verify server URL is correct and accessible
- Check network connectivity
- Try HTTP instead of HTTPS for local development

#### **Profile Not Found (404)**
- Verify the profile/tenant name is correct
- Check if profile exists on the server

#### **Permission Denied (403)**
- Check if authentication is required
- Contact server administrator

#### **Server Error (500)**
- Server-side issue, try again later
- Contact server administrator

## 📋 Roadmap

### Phase 1 (Current) - Export Download
- ✅ Server health checking
- ✅ JSON export download
- ✅ File viewing and management
- ✅ Clipboard integration

### Phase 2 - Import Functionality
- 🔄 Local Askar wallet creation
- 🔄 Import JSON data into wallet
- 🔄 Encryption and security features

## 🔄 Version History

### v1.0.0 (Current)
- Initial release
- Export download functionality
- JSON viewer with analysis
- Cross-platform support
- Clipboard integration
- Comprehensive error handling

---

**Note**: This is Phase 1 of the Askar Import project. Future phases will include actual wallet import functionality and advanced security features.
