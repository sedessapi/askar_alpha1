# Single Codebase: Dual-Mode App (Holder + Verifier)

**Last Updated**: October 4, 2025  
**Architecture**: Unified application with configurable modes

---

## Executive Summary

**Yes, you can have ONE codebase that operates as both Holder and Verifier**, with mode selection at:
- **Compile time** (build flavors)
- **Runtime** (configuration/settings)
- **Or both** (maximum flexibility)

This is actually a **superior architecture** for many use cases!

---

## Architecture: Unified Single Codebase

```
┌────────────────────────────────────────────────────────┐
│         UNIFIED APP (Single Codebase)                  │
│         "Askar Import Pro"                             │
├────────────────────────────────────────────────────────┤
│                                                        │
│  ┌──────────────────────────────────────────────┐    │
│  │  MODE SELECTOR (Runtime Configuration)       │    │
│  │  • Holder Mode                               │    │
│  │  • Verifier Mode                             │    │
│  │  • Hybrid Mode (Both)                        │    │
│  └──────────────────────────────────────────────┘    │
│                       │                               │
│         ┌─────────────┴─────────────┐                │
│         ↓                           ↓                 │
│  ┌─────────────┐            ┌──────────────┐         │
│  │ HOLDER UI   │            │ VERIFIER UI  │         │
│  │             │            │              │         │
│  │ • Import    │            │ • Scan QR    │         │
│  │ • Store     │            │ • Verify     │         │
│  │ • Present   │            │ • Audit Log  │         │
│  │ • Self-verify│           │ • Trust Mgmt │         │
│  └─────────────┘            └──────────────┘         │
│         │                           │                 │
│         └─────────────┬─────────────┘                │
│                       ↓                               │
│  ┌──────────────────────────────────────────────┐    │
│  │      SHARED CORE SERVICES                    │    │
│  │                                              │    │
│  │  • Trust Bundle Core (verification)          │    │
│  │  • ACA-Py Client (online operations)         │    │
│  │  • Askar FFI (native crypto)                │    │
│  │  • Database Layer (Isar)                    │    │
│  │  • Network Layer (HTTP)                     │    │
│  └──────────────────────────────────────────────┘    │
│                                                        │
└────────────────────────────────────────────────────────┘
```

---

## Implementation Approaches

### Option 1: Runtime Configuration (Recommended) ⭐

**Best for**: Apps that need to switch modes without reinstalling

```dart
// lib/config/app_mode.dart

enum AppMode {
  holder('Holder', 'Digital Wallet', Icons.account_balance_wallet),
  verifier('Verifier', 'Credential Checker', Icons.verified_user),
  hybrid('Hybrid', 'Holder + Verifier', Icons.swap_horiz);
  
  final String label;
  final String description;
  final IconData icon;
  
  const AppMode(this.label, this.description, this.icon);
}

class AppModeConfig {
  static AppMode _currentMode = AppMode.hybrid; // Default
  
  static AppMode get current => _currentMode;
  
  static bool get isHolderEnabled => 
      _currentMode == AppMode.holder || _currentMode == AppMode.hybrid;
      
  static bool get isVerifierEnabled => 
      _currentMode == AppMode.verifier || _currentMode == AppMode.hybrid;
  
  static Future<void> setMode(AppMode mode) async {
    _currentMode = mode;
    // Persist to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_mode', mode.name);
  }
  
  static Future<void> loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString('app_mode') ?? 'hybrid';
    _currentMode = AppMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => AppMode.hybrid,
    );
  }
}
```

**UI Implementation**:

```dart
// lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load saved mode
  await AppModeConfig.loadMode();
  
  runApp(const UnifiedApp());
}

class UnifiedApp extends StatelessWidget {
  const UnifiedApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Askar Import Pro',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Askar Import - ${AppModeConfig.current.label} Mode'),
        actions: [
          // Mode switcher
          PopupMenuButton<AppMode>(
            icon: Icon(AppModeConfig.current.icon),
            onSelected: (mode) async {
              await AppModeConfig.setMode(mode);
              setState(() {});
            },
            itemBuilder: (context) => AppMode.values.map((mode) {
              return PopupMenuItem(
                value: mode,
                child: ListTile(
                  leading: Icon(mode.icon),
                  title: Text(mode.label),
                  subtitle: Text(mode.description),
                  trailing: mode == AppModeConfig.current
                      ? const Icon(Icons.check)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: _buildModeSpecificUI(),
    );
  }
  
  Widget _buildModeSpecificUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Show mode indicator
          Card(
            color: _getModeColor(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    AppModeConfig.current.icon,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppModeConfig.current.label} Mode',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          AppModeConfig.current.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Holder features (if enabled)
          if (AppModeConfig.isHolderEnabled) ...[
            _buildSectionHeader('Holder Features', Icons.account_balance_wallet),
            _buildHolderButtons(),
            const SizedBox(height: 24),
          ],
          
          // Verifier features (if enabled)
          if (AppModeConfig.isVerifierEnabled) ...[
            _buildSectionHeader('Verifier Features', Icons.verified_user),
            _buildVerifierButtons(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHolderButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          icon: const Icon(Icons.file_download),
          label: const Text('Import from Askar'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const WalletImportPage(),
            ),
          ),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.badge),
          label: const Text('My Credentials'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CredentialListPage(),
            ),
          ),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.qr_code),
          label: const Text('Present Credential'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PresentationPage(),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildVerifierButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          icon: const Icon(Icons.sync),
          label: const Text('Sync Trust Bundle'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BundleSyncPage(),
            ),
          ),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Scan & Verify'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ScanVerifyPage(),
            ),
          ),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.check_circle),
          label: const Text('Manual Verification'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const OfflineVerifyPage(),
            ),
          ),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.history),
          label: const Text('Verification Log'),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const VerificationLogPage(),
            ),
          ),
        ),
      ],
    );
  }
  
  Color _getModeColor() {
    switch (AppModeConfig.current) {
      case AppMode.holder:
        return Colors.blue;
      case AppMode.verifier:
        return Colors.green;
      case AppMode.hybrid:
        return Colors.purple;
    }
  }
}
```

---

### Option 2: Build Flavors (Compile Time)

**Best for**: Distributing separate apps from same codebase

```bash
# Build holder-only version
flutter build apk --flavor holder -t lib/main_holder.dart

# Build verifier-only version
flutter build apk --flavor verifier -t lib/main_verifier.dart

# Build hybrid version
flutter build apk --flavor hybrid -t lib/main.dart
```

**Configuration**:

```yaml
# android/app/build.gradle

android {
    flavorDimensions "mode"
    
    productFlavors {
        holder {
            dimension "mode"
            applicationIdSuffix ".holder"
            versionNameSuffix "-holder"
            manifestPlaceholders = [appLabel: "Wallet"]
        }
        
        verifier {
            dimension "mode"
            applicationIdSuffix ".verifier"
            versionNameSuffix "-verifier"
            manifestPlaceholders = [appLabel: "Verifier"]
        }
        
        hybrid {
            dimension "mode"
            manifestPlaceholders = [appLabel: "Askar Import Pro"]
        }
    }
}
```

```dart
// lib/main_holder.dart
void main() {
  AppModeConfig.setModeCompileTime(AppMode.holder);
  runUnifiedApp();
}

// lib/main_verifier.dart
void main() {
  AppModeConfig.setModeCompileTime(AppMode.verifier);
  runUnifiedApp();
}

// lib/main.dart (hybrid)
void main() {
  AppModeConfig.setModeCompileTime(AppMode.hybrid);
  runUnifiedApp();
}
```

---

### Option 3: Hybrid Approach (Best of Both) ⭐⭐

**Best for**: Maximum flexibility

```dart
class AppModeConfig {
  // Compile-time default
  static AppMode _compiledMode = AppMode.hybrid;
  
  // Runtime override
  static AppMode? _runtimeMode;
  
  static AppMode get current => _runtimeMode ?? _compiledMode;
  
  static void setModeCompileTime(AppMode mode) {
    _compiledMode = mode;
  }
  
  static Future<void> setModeRuntime(AppMode mode) async {
    // Only allow switching within compiled capabilities
    if (!_canSwitchTo(mode)) {
      throw StateError('Cannot switch to $mode - not enabled at compile time');
    }
    
    _runtimeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('runtime_mode', mode.name);
  }
  
  static bool _canSwitchTo(AppMode target) {
    // If compiled as hybrid, can switch to anything
    if (_compiledMode == AppMode.hybrid) return true;
    
    // Otherwise, can only use the compiled mode
    return target == _compiledMode;
  }
}
```

---

## Database Strategy

### Shared vs Separate Databases

```dart
class UnifiedDatabase {
  final Isar holder;   // Holder-specific data
  final Isar verifier; // Verifier-specific data
  final Isar shared;   // Shared data (trust bundles, settings)
  
  UnifiedDatabase({
    required this.holder,
    required this.verifier,
    required this.shared,
  });
  
  static Future<UnifiedDatabase> open() async {
    final root = await getApplicationSupportDirectory();
    
    return UnifiedDatabase(
      holder: await Isar.open(
        [CredentialRecSchema, PendingCredentialRecSchema],
        directory: path.join(root.path, 'holder_db'),
        name: 'holder',
      ),
      verifier: await Isar.open(
        [
          SchemaRecSchema,
          CredDefRecSchema,
          TrustedIssuerRecSchema,
          VerificationLogRecSchema,
        ],
        directory: path.join(root.path, 'verifier_db'),
        name: 'verifier',
      ),
      shared: await Isar.open(
        [SyncMetaRecSchema, SettingsRecSchema],
        directory: path.join(root.path, 'shared_db'),
        name: 'shared',
      ),
    );
  }
}
```

---

## Use Cases for Each Mode

### Mode 1: Holder Only

**Use Case**: Personal digital wallet app for citizens/employees

```
Features Enabled:
✅ Import credentials from Askar
✅ Store credentials locally
✅ View credential details
✅ Self-verify credentials
✅ Create presentations (QR codes)
✅ Present to verifiers

Features Disabled:
❌ Scan QR codes from others
❌ Verify others' credentials
❌ Trust bundle management
❌ Verification audit logs
```

**Target Users**:
- Citizens with government IDs
- Employees with company badges
- Students with academic credentials
- Patients with health insurance

---

### Mode 2: Verifier Only

**Use Case**: Verification kiosks, security stations, inspector devices

```
Features Enabled:
✅ Sync trust bundles
✅ Scan QR codes from holders
✅ Verify credentials offline
✅ Verify credentials online (ACA-Py)
✅ Audit logging
✅ Trust management
✅ Verification statistics

Features Disabled:
❌ Import credentials
❌ Store personal credentials
❌ Create presentations
❌ Self-verification of own creds
```

**Target Users**:
- Security guards at entry points
- Border control agents
- HR personnel checking credentials
- Healthcare staff verifying insurance
- Retail staff checking age verification

---

### Mode 3: Hybrid (Both) ⭐

**Use Case**: Flexible agents who both hold and verify credentials

```
Features Enabled:
✅ ALL Holder features
✅ ALL Verifier features
✅ Role switching on-demand
✅ Self-verification with own trust bundle

Features Available:
✅ Same person can verify others' credentials
✅ Test verification before presenting
✅ Inspector with own credentials
✅ Demo and testing scenarios
```

**Target Users**:
- Security professionals with own badges
- Healthcare workers with licenses
- Inspectors with credentials
- Developers testing systems
- Training and demonstration

---

## Real-World Scenarios

### Scenario 1: Corporate Building Security

**Device**: Tablet at entrance kiosk

```
Configuration:
Mode: Verifier Only
Trust Bundle: Company employee schema + trusted HR issuer
Database: Verification logs with timestamps
Network: Optional (works offline with trust bundle)

Workflow:
1. Employee approaches kiosk
2. Shows QR code from their phone (holder app)
3. Kiosk scans and verifies using trust bundle
4. Logs access attempt
5. Opens door if valid
```

---

### Scenario 2: Security Guard with Badge

**Device**: Guard's phone

```
Configuration:
Mode: Hybrid (Holder + Verifier)
Trust Bundle: Employee schema + visitor pass schema
Database: Both holder and verifier DBs

Use as Holder:
- Guard has own employee badge credential
- Shows badge to access restricted areas
- Self-verifies badge before shift starts

Use as Verifier:
- Scans visitor passes
- Verifies contractor credentials
- Checks temporary access badges
- Logs all verification attempts
```

---

### Scenario 3: Healthcare Worker

**Device**: Doctor's tablet

```
Configuration:
Mode: Hybrid
Trust Bundle: Medical licenses + insurance schemas

Use as Holder:
- Doctor has medical license credential
- Has DEA registration credential
- Presents to pharmacy for controlled substances

Use as Verifier:
- Verifies patient insurance credentials
- Checks nurse credentials in emergency
- Validates visiting doctor credentials
```

---

## Configuration File Approach

### Using JSON Configuration

```json
// config/app_config.json

{
  "mode": "hybrid",
  "holder": {
    "enabled": true,
    "features": {
      "import": true,
      "present": true,
      "self_verify": true
    }
  },
  "verifier": {
    "enabled": true,
    "features": {
      "scan": true,
      "manual_verify": true,
      "audit_log": true,
      "trust_bundle_sync": true
    },
    "trust_bundle": {
      "server_url": "https://trust-bundle.example.com",
      "trusted_keys": {
        "did:key:z6Mkf...": "base64-public-key"
      },
      "auto_sync": true,
      "sync_interval_hours": 24
    }
  },
  "ui": {
    "theme": "light",
    "show_mode_switcher": true,
    "default_tab": "holder"
  }
}
```

---

## Advantages of Single Codebase

### ✅ Development Benefits

1. **Single Maintenance**: One codebase to maintain and update
2. **Shared Code**: Crypto, network, UI components reused
3. **Consistent UX**: Same look and feel across modes
4. **Easier Testing**: Test once, works everywhere
5. **Rapid Iteration**: Changes apply to all modes

### ✅ Deployment Benefits

1. **Flexible Distribution**: One app, multiple use cases
2. **Easy Updates**: Single app store listing
3. **User Flexibility**: Users can switch modes as needed
4. **Reduced Storage**: No need for multiple apps
5. **Unified Support**: One support channel

### ✅ Business Benefits

1. **Lower Costs**: Single development effort
2. **Faster Time-to-Market**: Build once, deploy many ways
3. **Scalability**: Easy to add new modes
4. **Market Flexibility**: Adapt to different customer needs
5. **Demo-Friendly**: Show all capabilities in one app

---

## Disadvantages to Consider

### ⚠️ Potential Issues

1. **Larger App Size**: Includes code for all modes
2. **Complexity**: More conditional logic
3. **Security Concerns**: Holder data in verifier-only device?
4. **User Confusion**: Too many options?
5. **App Store Categories**: Which category to list in?

### 🛡️ Mitigation Strategies

1. **Code Splitting**: Lazy load unused features
2. **Clear UI**: Hide disabled features completely
3. **Database Isolation**: Separate databases per mode
4. **Documentation**: Clear mode explanations
5. **Build Flavors**: Compile-time optimization

---

## Recommendation

### 🎯 Use **Hybrid Approach (Option 3)**:

```
✅ Compile with all features (hybrid default)
✅ Allow runtime mode switching
✅ Persist user's mode preference
✅ Show only relevant UI for current mode
✅ Use separate databases for isolation
```

This gives you:
- ✅ **Flexibility** for all use cases
- ✅ **Single codebase** for easy maintenance
- ✅ **User control** with mode switching
- ✅ **Security** with database isolation
- ✅ **Scalability** for future modes

---

## Migration Path

If you currently have two separate codebases:

### Phase 1: Merge Core Services
```
1. Combine shared services (crypto, network, database)
2. Create unified package structure
3. Test both modes independently
```

### Phase 2: Unify UI
```
1. Create mode-aware UI components
2. Implement mode switcher
3. Test transitions between modes
```

### Phase 3: Optimize
```
1. Remove duplicate code
2. Add lazy loading for unused features
3. Optimize database access
```

---

## Summary

**Answer: YES**, you absolutely should have **one codebase** that can be:
- **Holder only** (personal wallet)
- **Verifier only** (inspection device)
- **Hybrid** (both capabilities)

**Best Implementation**: Runtime configuration with optional build flavors for optimization.

**Key Pattern**:
```dart
if (AppModeConfig.isHolderEnabled) {
  // Show holder features
}

if (AppModeConfig.isVerifierEnabled) {
  // Show verifier features
}
```

This is the **modern, flexible architecture** that will serve you well! 🚀

---

**Status**: Architecture Recommended  
**Complexity**: Moderate  
**Benefits**: High  
**Recommended**: ⭐⭐⭐⭐⭐
