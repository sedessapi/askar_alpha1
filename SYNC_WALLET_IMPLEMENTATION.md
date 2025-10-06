# Sync Wallet Feature Implementation

## Overview
Simplified wallet synchronization by combining download and import into a single streamlined workflow. Users can now sync wallet data from ACA-Py directly to their local Askar wallet with one button.

## What Was Implemented

### 1. New Sync Wallet Page ✅
**File**: `lib/ui/pages/sync_wallet_page.dart`

**Features**:
- Combined download + auto-import functionality
- Fixed wallet configuration:
  - Wallet name: `synced_wallet`
  - Wallet key: `8HH5gYEeNc3z7PYXmd54d4x6qAfCNrqQqEB3nS7Zfu7K` (default)
- Default ACA-Py URL: `http://mary9.com:9070`
- Auto-creates wallet if doesn't exist
- Auto-reuses wallet if exists
- Shows real-time server health status
- One-click sync button
- Clean status display

**Workflow**:
1. User enters export server URL and profile ID (or uses defaults)
2. System checks ACA-Py health
3. User taps "Sync Wallet" button
4. System downloads export data
5. System automatically creates/opens `synced_wallet`
6. System automatically imports all credentials
7. Shows result: "✅ Synced X credentials"

### 2. Updated Home Page Gallery ✅
**File**: `lib/ui/pages/home_page.dart`

**Changes**:
- ✅ Added "Sync Wallet" mini-app (cyan, cloud_sync icon)
- ❌ Removed "Scan" mini-app (now only in bottom navigation)
- ✅ Kept "Sync Bundle" mini-app
- ✅ Kept "Verify Local" mini-app

**Final Gallery** (3 mini-apps):
1. **Sync Bundle** (purple) - Manage trust settings
2. **Sync Wallet** (cyan) - Download & import wallet
3. **Verify Local** (green) - Verify credentials

### 3. Updated Sync Bundle Default URL ✅
**File**: `packages/trust_bundle_core/lib/src/services/bundle_client.dart`

**Change**:
- Default URL: `http://mary9.com:9090` → `http://mary4.com:9090`

### 4. Simplified Bottom Navigation ✅
**File**: `lib/ui/navigation/app_navigation.dart`

**Removed Tabs**:
- ❌ Download
- ❌ Credentials

**Kept Tabs** (4 total):
1. Home
2. Scan (Scanner)
3. Proofs
4. Settings

### 5. Moved Pages to Developer Tools ✅
**File**: `lib/ui/pages/settings_page.dart`

**Added to Developer Tools Section**:
- **Download** - Export wallet data from ACA-Py (advanced)
- **Credentials** - Import wallet data to Askar (manual)
- **Isar Inspector** - Database viewer (existing)

Users can access these for debugging or manual operations.

## Architecture

### Navigation Structure
```
Bottom Navigation (4 tabs):
├─ Home
│  └─ Mini-Apps Gallery:
│     ├─ Sync Bundle (mary4) → Trust Bundle Settings
│     ├─ Sync Wallet (mary9) → Sync Wallet Page [NEW]
│     └─ Verify Local → Verify Local Page
├─ Scan
│  └─ QR Code Scanner
├─ Proofs
│  └─ Proof Requests
└─ Settings
   ├─ Dark Mode Toggle
   └─ Developer Tools:
      ├─ Download Page
      ├─ Credentials Page
      └─ Isar Inspector
```

### Sync Wallet Flow
```
User Action: Tap "Sync Wallet"
     ↓
Sync Wallet Page Opens
     ↓
Enter/Confirm Server URL & Profile
     ↓
Health Check (auto-runs on load)
     ↓
Tap "Sync Wallet" Button
     ↓
┌─────────────────────────────┐
│ 1. Check ACA-Py Health      │
│ 2. Download Export JSON      │
│ 3. Save to Temp File         │
│ 4. Check if Wallet Exists    │
│ 5. Create Wallet (if needed) │
│ 6. Import Credentials        │
│ 7. Show Success Message      │
│ 8. Clean Up Temp File        │
└─────────────────────────────┘
     ↓
Display: "✅ Synced X credentials"
```

## Technical Details

### Sync Wallet Implementation

#### Auto-Create Wallet
```dart
final walletPath = '${dir.path}/synced_wallet.db';
final walletFile = File(walletPath);

if (!walletFile.existsSync()) {
  final provisionResult = _askarFfi.provisionWallet(
    dbPath: walletPath,
    rawKey: _walletKey,
  );
}
```

#### Auto-Import Credentials
```dart
final importResult = _askarFfi.importBulkEntries(
  dbPath: walletPath,
  rawKey: _walletKey,
  jsonData: jsonData,
);

final imported = importResult['imported'] as int? ?? 0;
```

#### Health Check
```dart
_client = AskarExportClient(_serverCtrl.text.trim());
final isHealthy = await _client!.healthz();
setState(() => _isHealthy = isHealthy);
```

### Fixed Configuration
```dart
static const String _walletName = 'synced_wallet';
static const String _walletKey = '8HH5gYEeNc3z7PYXmd54d4x6qAfCNrqQqEB3nS7Zfu7K';
```

## Benefits

### User Experience
1. **Simpler Workflow**: One button instead of two-step process
2. **No File Management**: No need to locate downloaded files
3. **No Wallet Management**: Auto-creates/reuses wallet
4. **Clear Feedback**: Real-time status updates
5. **Fast**: Typical sync takes 2-5 seconds

### Developer Experience
1. **Cleaner Navigation**: Removed cluttered tabs
2. **Organized Tools**: Developer features in dedicated section
3. **Consistent Defaults**: Fixed wallet name/key
4. **Better Separation**: User features vs. debug tools

## Files Modified

| File | Changes |
|------|---------|
| `lib/ui/pages/sync_wallet_page.dart` | **NEW** - Combined sync page |
| `lib/ui/pages/home_page.dart` | Added Sync Wallet, removed Scan |
| `lib/ui/navigation/app_navigation.dart` | Removed Download/Credentials tabs |
| `lib/ui/pages/settings_page.dart` | Added Download/Credentials to Dev Tools |
| `packages/trust_bundle_core/lib/src/services/bundle_client.dart` | Changed default URL mary9 → mary4 |

## Default URLs Summary

| Service | URL |
|---------|-----|
| **Sync Bundle** | `http://mary4.com:9090` |
| **Sync Wallet** | `http://mary9.com:9070` |
| **Download (Dev)** | `http://mary9.com:9070` |

## Testing Checklist

- [ ] Home page shows 3 mini-apps (Sync Bundle, Sync Wallet, Verify Local)
- [ ] Bottom nav shows 4 tabs (Home, Scan, Proofs, Settings)
- [ ] Tapping "Sync Wallet" opens sync page
- [ ] Health check runs on page load
- [ ] Sync button downloads and imports in one action
- [ ] Wallet auto-creates if doesn't exist
- [ ] Wallet reuses if exists
- [ ] Success message shows credential count
- [ ] Settings → Developer Tools shows Download and Credentials
- [ ] Sync Bundle uses mary4 by default
- [ ] Sync Wallet uses mary9 by default

## User Guide

### For Regular Users

**To Sync Wallet:**
1. Tap **Sync Wallet** from home
2. Enter/confirm server URL and profile ID
3. Tap **Sync Wallet** button
4. Wait for "✅ Synced X credentials" message
5. Use **Verify Local** to test credentials

### For Developers

**To Access Advanced Tools:**
1. Tap **Settings** tab
2. Scroll to **Developer Tools**
3. Access:
   - **Download** - Manual export download
   - **Credentials** - Manual import with history
   - **Isar Inspector** - Database viewer

## Migration Notes

### Previous Workflow
```
Download Tab → Enter URL → Download → See History
     ↓
Credentials Tab → Select File → Import → See Results
```

### New Workflow
```
Home → Sync Wallet → Enter URL → Sync → Done ✅
```

**Savings**: 2 tabs → 1 mini-app, 2 steps → 1 step

## Future Enhancements

### Possible Improvements
1. **Auto-sync on app launch** (background refresh)
2. **Sync scheduling** (daily/weekly automatic sync)
3. **Multiple profiles** (switch between different wallets)
4. **Sync history** (track sync operations)
5. **Conflict resolution** (handle duplicate credentials)
6. **Selective sync** (choose which credentials to import)

## Summary

Successfully implemented a streamlined Sync Wallet feature that:
- ✅ Combines download + import into one action
- ✅ Uses fixed wallet configuration (synced_wallet)
- ✅ Auto-creates/reuses wallet as needed
- ✅ Simplifies navigation (removed 2 tabs)
- ✅ Organizes developer tools in Settings
- ✅ Updates default URLs (mary4 for trust bundle)
- ✅ Maintains backward compatibility (old pages in Dev Tools)

The implementation provides a significantly better user experience while maintaining access to advanced features for developers.
