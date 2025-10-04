# Incremental Development Plan: Unified App with Trust Bundle

**Last Updated**: October 4, 2025  
**Strategy**: Iterative, value-driven development with testable milestones

---

## Development Philosophy

### Core Principles:

✅ **Each phase delivers working functionality**  
✅ **Test before moving to next phase**  
✅ **Can pause/deploy at any milestone**  
✅ **Backward compatible with existing features**  
✅ **User feedback between phases**

---

## Phase 1: Extract Trust Bundle Core Package 📦 + UI Refactoring 🎨

**Goal**: Create standalone, reusable crypto verification library AND modernize UI  
**Duration**: 5-6 days (extended for UI work)  
**Risk**: Low - Independent of main app logic  
**Value**: Foundation for all future work + Professional UI

### Part A: Trust Bundle Core Package (Days 1-3)

```bash
# 1.1 Create Package Structure
cd /Users/itzmi/dev/offline/tests/
flutter create --template=package trust_bundle_core
cd trust_bundle_core
```

#### 1.2 Setup Dependencies

```yaml
# trust_bundle_core/pubspec.yaml
name: trust_bundle_core
description: Cryptographic verification engine for verifiable credentials
version: 1.0.0
publish_to: 'none'

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  crypto: ^3.0.6
  ed25519_edwards: ^0.3.1
  bs58: ^1.0.2
  convert: ^3.1.1
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

#### 1.3 Extract Files (from Trust Bundle Verifier)

Create this structure:

```
trust_bundle_core/
├── lib/
│   ├── trust_bundle_core.dart              # Main export
│   ├── src/
│   │   ├── crypto/
│   │   │   └── manifest_verifier.dart      # ⭐ GOLD - Ed25519 verification
│   │   ├── services/
│   │   │   ├── bundle_ingest.dart          # Manifest ingestion
│   │   │   ├── schema_loader.dart          # Schema/CredDef loader
│   │   │   └── bundle_client.dart          # HTTP client
│   │   ├── storage/
│   │   │   └── trust_cache.dart            # Isar persistence
│   │   └── models/
│   │       ├── bundle_models.dart          # Data models
│   │       └── verification_result.dart    # Result types
│   └── trust_bundle_core.dart
├── test/
│   ├── crypto/
│   │   └── manifest_verifier_test.dart     # Unit tests
│   └── integration/
│       └── full_verification_test.dart     # Integration tests
└── pubspec.yaml
```

#### 1.4 Create Public API

```dart
// trust_bundle_core/lib/trust_bundle_core.dart

library trust_bundle_core;

// Export public API
export 'src/crypto/manifest_verifier.dart' show ManifestVerifier, BundleVerifyResult;
export 'src/services/bundle_ingest.dart' show BundleIngest, SyncResult;
export 'src/services/schema_loader.dart' show SchemaLoader;
export 'src/services/bundle_client.dart' show BundleClient;
export 'src/models/bundle_models.dart';
export 'src/models/verification_result.dart';

/// Main entry point for Trust Bundle Core
class TrustBundleCore {
  final ManifestVerifier _verifier;
  final SchemaLoader _loader;
  
  TrustBundleCore({
    required Map<String, String> trustedKeys,
    required SchemaLoader loader,
  })  : _verifier = ManifestVerifier(trustedKeys: trustedKeys),
        _loader = loader;
  
  /// Check if trust bundle verification is available
  bool get isAvailable => _loader.hasSchemas();
  
  /// Verify a credential using trust bundle
  Future<VerificationResult> verifyCredential(Map<String, dynamic> credential) async {
    // Implementation
  }
  
  /// Sync trust bundle from server
  Future<SyncResult> syncBundle(String serverUrl) async {
    // Implementation
  }
}
```

#### 1.5 Write Tests

```dart
// test/crypto/manifest_verifier_test.dart

void main() {
  group('ManifestVerifier', () {
    test('verifies valid Ed25519 signature', () async {
      // Test implementation
    });
    
    test('rejects invalid signature', () async {
      // Test implementation
    });
    
    test('resolves did:key correctly', () async {
      // Test implementation
    });
  });
}
```

### Part B: UI Refactoring (Days 4-6)

**Goal**: Modernize UI with bottom navigation, no functionality changes

#### B.1 Navigation Structure (Day 4)

```dart
// lib/ui/navigation/app_navigation.dart

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});
  
  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _currentIndex = 0;
  
  // Screens for each tab
  final List<Widget> _screens = [
    const HomePage(),
    const CredentialsPage(),
    const ScanPage(),
    const ProofsPage(),
    const SettingsPage(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: 'Credentials',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Proofs',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
```

**Tasks**:
- [ ] Create bottom navigation scaffold
- [ ] Implement tab switching
- [ ] Add app drawer for secondary features
- [ ] Create navigation routes

#### B.2 Screen Scaffolds (Day 5)

**Create skeleton pages** (functionality comes later):

1. **Home Page** - Dashboard with stats
2. **Credentials Page** - Migrate existing wallet import page
3. **Scan Page** - Placeholder for QR scanner
4. **Proofs Page** - Placeholder for verification log
5. **Settings Page** - Basic settings UI

```dart
// lib/ui/screens/home/home_page.dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Card
            _buildStatsCard(),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            _buildQuickActions(context),
            
            const SizedBox(height: 24),
            
            // Recent Activity
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }
}
```

**Tasks**:
- [ ] Create home page with statistics
- [ ] Migrate credential list to new Credentials tab
- [ ] Create scan page skeleton
- [ ] Create proofs/log page skeleton
- [ ] Create settings page with sections

#### B.3 Reusable Components (Day 6)

**Create design system components**:

```dart
// lib/ui/widgets/credential_card.dart
class CredentialCard extends StatelessWidget {
  final String title;
  final String issuer;
  final VerificationStatus status;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _buildIcon(),
        title: Text(title),
        subtitle: Text('Issued by: $issuer'),
        trailing: StatusBadge(status: status),
        onTap: () => _navigateToDetails(),
      ),
    );
  }
}

// lib/ui/widgets/tier_badge.dart
class TierBadge extends StatelessWidget {
  final VerificationTier tier;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tier.color.withOpacity(0.1),
        border: Border.all(color: tier.color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tier.icon, size: 16, color: tier.color),
          SizedBox(width: 4),
          Text(tier.label, style: TextStyle(color: tier.color)),
        ],
      ),
    );
  }
}
```

**Tasks**:
- [ ] Design credential card widget
- [ ] Create verification result card
- [ ] Implement tier badges (BEST/GOOD/LIMITED)
- [ ] Create status badges (Verified/Unverified/Invalid)
- [ ] Create mode indicator widget

#### B.4 Theme & Polish (Day 6)

```dart
// lib/ui/theme/app_theme.dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
```

**Tasks**:
- [ ] Implement Material Design 3 theme
- [ ] Add consistent spacing and typography
- [ ] Add smooth animations and transitions
- [ ] Test responsive layout (phone/tablet)

#### B.5 Migration & Integration (Day 6)

**Connect existing features to new UI**:

```dart
// Migrate existing functionality:
// 1. Import from Askar → Home quick action + Credentials page
// 2. Credential verification → Keep existing CredentialVerifier
// 3. Credential display → New CredentialCard components
// 4. JSON export → Settings or credential detail
```

**Tasks**:
- [ ] Move credential import to Home page button
- [ ] Migrate credential list to Credentials tab
- [ ] Keep existing verification logic (no changes)
- [ ] Update navigation to use new structure
- [ ] Test all existing features still work

### Deliverable (End of Phase 1):

✅ **Part A**: Standalone `trust_bundle_core` package with passing tests  
✅ **Part B**: Modern UI with bottom navigation  
✅ All existing features working in new UI  
✅ Professional look and feel  
✅ Ready for Phase 2 (mode configuration)

### Success Criteria:

```bash
# Part A: Package
cd trust_bundle_core
flutter test
# All crypto tests pass ✅

# Part B: UI
cd askar_import
flutter run
# App launches with new UI ✅
# Can import credentials ✅
# Can view credentials ✅
# Can verify credentials ✅
# Bottom navigation works ✅
```

---

## Phase 2: Add Basic Mode Configuration 🎛️

**Goal**: Add mode switching without breaking existing features  
**Duration**: 1 day  
**Risk**: Very Low - Pure addition  
**Value**: Foundation for role-based UI

### Tasks:

#### 2.1 Create Mode Configuration

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
  static AppMode _currentMode = AppMode.hybrid; // Default to hybrid
  
  static AppMode get current => _currentMode;
  
  static bool get isHolderEnabled => 
      _currentMode == AppMode.holder || _currentMode == AppMode.hybrid;
      
  static bool get isVerifierEnabled => 
      _currentMode == AppMode.verifier || _currentMode == AppMode.hybrid;
  
  static Future<void> setMode(AppMode mode) async {
    _currentMode = mode;
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

#### 2.2 Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  shared_preferences: ^2.2.0  # Add this
```

#### 2.3 Initialize in main.dart

```dart
// lib/main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load saved mode
  await AppModeConfig.loadMode();
  
  runApp(const AskarImportApp());
}
```

#### 2.4 Add Mode Indicator (Top of HomePage)

```dart
// At top of existing home page, add:

Card(
  color: _getModeColor(),
  child: Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        Icon(AppModeConfig.current.icon, color: Colors.white),
        const SizedBox(width: 8),
        Text(
          '${AppModeConfig.current.label} Mode',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const Spacer(),
        // Mode switcher button
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => _showModeSelector(context),
        ),
      ],
    ),
  ),
)
```

#### 2.5 Add Mode Selector Dialog

```dart
void _showModeSelector(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Select App Mode'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: AppMode.values.map((mode) {
          final isSelected = mode == AppModeConfig.current;
          return ListTile(
            leading: Icon(mode.icon),
            title: Text(mode.label),
            subtitle: Text(mode.description),
            trailing: isSelected ? const Icon(Icons.check) : null,
            selected: isSelected,
            onTap: () async {
              await AppModeConfig.setMode(mode);
              if (context.mounted) {
                Navigator.pop(context);
                // Trigger rebuild
                (context as Element).markNeedsBuild();
              }
            },
          );
        }).toList(),
      ),
    ),
  );
}
```

### Deliverable:

✅ Mode selector works  
✅ Mode persists across app restarts  
✅ Existing features still work (backward compatible)  
✅ UI shows current mode

### Success Criteria:

1. Run app ✅
2. Switch between modes ✅
3. Restart app - mode preserved ✅
4. Existing import/verification still works ✅

---

## Phase 3: Integrate Trust Bundle (Holder Mode) 🔐

**Goal**: Add 3-tier verification to existing holder features  
**Duration**: 2-3 days  
**Risk**: Medium - Changes verification flow  
**Value**: HIGH - Cryptographic verification enabled

### Tasks:

#### 3.1 Add Package Dependency

```yaml
# pubspec.yaml
dependencies:
  trust_bundle_core:
    path: ../trust_bundle_core  # Local package
```

#### 3.2 Initialize Trust Bundle Database

```dart
// lib/services/trust_bundle_service.dart

class TrustBundleService {
  static Isar? _verifierDb;
  static TrustBundleCore? _core;
  
  static Future<void> initialize() async {
    final dir = await getApplicationSupportDirectory();
    
    _verifierDb = await Isar.open(
      [SchemaRecSchema, CredDefRecSchema, TrustedIssuerRecSchema],
      directory: path.join(dir.path, 'verifier_db'),
      name: 'verifier',
    );
    
    final loader = SchemaLoader(_verifierDb!);
    
    _core = TrustBundleCore(
      trustedKeys: {
        'did:key:z6Mkf...': 'base64-public-key', // Your trusted keys
      },
      loader: loader,
    );
  }
  
  static TrustBundleCore? get core => _core;
}
```

#### 3.3 Create Enhanced Verification Service

```dart
// lib/services/enhanced_verification_service.dart

enum VerificationTier {
  trustBundle('Trust Bundle', 'Offline Crypto', Colors.green, Icons.security),
  acaPy('ACA-Py', 'Online Crypto', Colors.blue, Icons.cloud_done),
  structural('Structural', 'Format Only', Colors.orange, Icons.warning);
  
  final String label;
  final String description;
  final Color color;
  final IconData icon;
  
  const VerificationTier(this.label, this.description, this.color, this.icon);
}

class EnhancedVerificationService {
  final TrustBundleCore? _trustBundle;
  final AcaPyClient? _acaPy;
  final CredentialVerifier _structural;
  
  EnhancedVerificationService({
    TrustBundleCore? trustBundle,
    AcaPyClient? acaPy,
    required CredentialVerifier structural,
  })  : _trustBundle = trustBundle,
        _acaPy = acaPy,
        _structural = structural;
  
  /// Verify credential with automatic tier selection
  Future<EnhancedVerificationResult> verifyCredential(
    Map<String, dynamic> credential,
  ) async {
    final attempts = <VerificationAttempt>[];
    
    // Tier 1: Try Trust Bundle (BEST)
    if (_trustBundle?.isAvailable ?? false) {
      try {
        final result = await _trustBundle!.verifyCredential(credential);
        attempts.add(VerificationAttempt(
          tier: VerificationTier.trustBundle,
          success: result.isValid,
          message: result.message,
        ));
        
        if (result.isValid) {
          return EnhancedVerificationResult(
            isValid: true,
            tier: VerificationTier.trustBundle,
            message: 'Cryptographically verified (offline)',
            attempts: attempts,
            verifiedAt: DateTime.now(),
          );
        }
      } catch (e) {
        attempts.add(VerificationAttempt(
          tier: VerificationTier.trustBundle,
          success: false,
          message: 'Trust Bundle error: $e',
        ));
      }
    }
    
    // Tier 2: Try ACA-Py (GOOD)
    if (_acaPy != null) {
      try {
        final isOnline = await _acaPy!.checkHealth();
        if (isOnline) {
          final result = await _acaPy!.verifyCredential(credential);
          attempts.add(VerificationAttempt(
            tier: VerificationTier.acaPy,
            success: result['verified'] ?? false,
            message: result['message'] ?? '',
          ));
          
          if (result['verified'] == true) {
            return EnhancedVerificationResult(
              isValid: true,
              tier: VerificationTier.acaPy,
              message: 'Cryptographically verified (online)',
              attempts: attempts,
              verifiedAt: DateTime.now(),
            );
          }
        }
      } catch (e) {
        attempts.add(VerificationAttempt(
          tier: VerificationTier.acaPy,
          success: false,
          message: 'ACA-Py error: $e',
        ));
      }
    }
    
    // Tier 3: Structural (FALLBACK)
    final result = await _structural.verifyCredential(credential);
    attempts.add(VerificationAttempt(
      tier: VerificationTier.structural,
      success: result.isValid,
      message: result.message,
    ));
    
    return EnhancedVerificationResult(
      isValid: result.isValid,
      tier: VerificationTier.structural,
      message: result.message,
      attempts: attempts,
      verifiedAt: DateTime.now(),
    );
  }
}
```

#### 3.4 Update UI to Show Tier

```dart
// In credential detail view, add:

if (verificationResult != null) {
  Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: verificationResult.tier.color.withOpacity(0.1),
      border: Border.all(color: verificationResult.tier.color),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(verificationResult.tier.icon, color: verificationResult.tier.color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              verificationResult.tier.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: verificationResult.tier.color,
              ),
            ),
            Text(
              verificationResult.tier.description,
              style: TextStyle(
                fontSize: 12,
                color: verificationResult.tier.color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
}
```

### Deliverable:

✅ 3-tier verification works  
✅ Automatic fallback between tiers  
✅ UI shows which tier was used  
✅ Trust bundle verification functional

### Success Criteria:

1. Import credential ✅
2. Verify - shows tier badge ✅
3. Offline: Trust Bundle → Structural ✅
4. Online: Trust Bundle → ACA-Py → Structural ✅

---

## Phase 4: Add Verifier Mode UI 🔍

**Goal**: Enable credential verification features  
**Duration**: 3-4 days  
**Risk**: Low - New features, doesn't affect existing  
**Value**: Complete verifier capability

### Tasks:

#### 4.1 Add QR Scanner

```dart
// lib/ui/pages/scan_verify_page.dart

class ScanVerifyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan & Verify')),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRScanned,
      ),
    );
  }
  
  void _onQRScanned(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) async {
      // Parse credential from QR
      final credential = json.decode(scanData.code);
      
      // Verify using EnhancedVerificationService
      final result = await _verificationService.verifyCredential(credential);
      
      // Show result
      _showVerificationResult(result);
    });
  }
}
```

#### 4.2 Add Manual Verification Page

```dart
// lib/ui/pages/manual_verify_page.dart

class ManualVerifyPage extends StatelessWidget {
  // Allow paste JSON or select from file
  // Same verification flow
}
```

#### 4.3 Add Trust Bundle Sync

```dart
// lib/ui/pages/bundle_sync_page.dart

class BundleSyncPage extends StatefulWidget {
  @override
  State<BundleSyncPage> createState() => _BundleSyncPageState();
}

class _BundleSyncPageState extends State<BundleSyncPage> {
  bool _syncing = false;
  SyncResult? _lastResult;
  
  Future<void> _syncBundle() async {
    setState(() => _syncing = true);
    
    final result = await TrustBundleService.core?.syncBundle(
      'https://your-trust-bundle-server.com',
    );
    
    setState(() {
      _syncing = false;
      _lastResult = result;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trust Bundle Sync')),
      body: // UI implementation
    );
  }
}
```

#### 4.4 Add Verification Log

```dart
// lib/ui/pages/verification_log_page.dart

class VerificationLogPage extends StatelessWidget {
  // Show history of all verifications
  // Filter by date, result, tier
  // Export to CSV option
}
```

#### 4.5 Update Home Page with Verifier Features

```dart
// In home page, add:

if (AppModeConfig.isVerifierEnabled) {
  // Verifier section
  _buildSectionHeader('Verifier Features', Icons.verified_user),
  Wrap(
    children: [
      FilledButton.icon(
        icon: const Icon(Icons.sync),
        label: const Text('Sync Trust Bundle'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BundleSyncPage()),
        ),
      ),
      FilledButton.icon(
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan & Verify'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScanVerifyPage()),
        ),
      ),
      // More buttons...
    ],
  ),
}
```

### Deliverable:

✅ QR scanning works  
✅ Manual verification works  
✅ Trust bundle sync functional  
✅ Verification logging implemented  
✅ Verifier mode fully functional

### Success Criteria:

1. Switch to Verifier mode ✅
2. Sync trust bundle ✅
3. Scan QR code and verify ✅
4. See verification in log ✅

---

## Phase 5: Polish & Production Ready ✨

**Goal**: Production-ready release  
**Duration**: 2-3 days  
**Risk**: Low - Final touches  
**Value**: Professional, deployable app

### Tasks:

#### 5.1 Add Settings Page

```dart
// lib/ui/pages/settings_page.dart

class SettingsPage extends StatelessWidget {
  // App mode selection
  // Trust bundle server URL
  // ACA-Py server URL
  // Auto-sync settings
  // Theme selection
  // About/version info
}
```

#### 5.2 Add Verification History UI

```dart
// Show attempt history when multiple tiers tried
// Color-coded timeline
// Expandable details
```

#### 5.3 Update Documentation

- Update USER_GUIDE.md with mode switching
- Update DEVELOPER_GUIDE.md with trust_bundle_core
- Create TRUST_BUNDLE_SETUP.md
- Add screenshots to README.md

#### 5.4 Comprehensive Testing

```bash
# Test matrix:
# - Holder mode: Import, verify, present
# - Verifier mode: Scan, verify, log
# - Hybrid mode: All features
# - Offline scenarios
# - Online scenarios
# - Mode switching
```

#### 5.5 Performance Optimization

- Lazy load unused features
- Optimize database queries
- Cache verification results
- Background sync

#### 5.6 Release Preparation

```bash
# Create git tag
git add .
git commit -m "feat: unified app with 3-tier verification"
git tag -a unified_v1.0.0 -m "Unified app with holder/verifier modes and 3-tier verification"
git push origin main --tags

# Build release
flutter build apk --release
flutter build ios --release
```

### Deliverable:

✅ Settings page complete  
✅ All documentation updated  
✅ Full test coverage  
✅ Performance optimized  
✅ Release tagged and built

### Success Criteria:

1. All features work in all modes ✅
2. Documentation complete ✅
3. Tests pass ✅
4. Performance acceptable ✅
5. Ready to deploy ✅

---

## Timeline Summary

| Phase | Duration | Dependencies | Can Deploy? |
|-------|----------|--------------|-------------|
| Phase 1A | 3 days | None | No (just package) |
| Phase 1B | 3 days | None | Yes (new UI) |
| Phase 2 | 1 day | Phase 1 | Yes (mode switching) |
| Phase 3 | 2-3 days | Phase 1, 2 | Yes (enhanced verification) |
| Phase 4 | 3-4 days | Phase 3 | Yes (full verifier) |
| Phase 5 | 2-3 days | Phase 4 | Yes (production) |
| **Total** | **14-17 days** | | |

---

## Risk Mitigation

### Phase 1 Risks:
- **Risk**: Crypto extraction complexity
- **Mitigation**: Extract in small pieces, test incrementally

### Phase 2 Risks:
- **Risk**: Breaking existing features
- **Mitigation**: Pure addition, no changes to existing code

### Phase 3 Risks:
- **Risk**: Verification flow changes
- **Mitigation**: Fallback to structural always works

### Phase 4 Risks:
- **Risk**: QR scanning platform issues
- **Mitigation**: Also provide manual verification

### Phase 5 Risks:
- **Risk**: Integration bugs
- **Mitigation**: Comprehensive testing phase

---

## Decision Points

### After Phase 2:
**Question**: Is mode switching working well?
- ✅ Continue to Phase 3
- ❌ Refine UI before proceeding

### After Phase 3:
**Question**: Is 3-tier verification reliable?
- ✅ Continue to Phase 4
- ❌ Fix verification issues first

### After Phase 4:
**Question**: Are verifier features useful?
- ✅ Continue to Phase 5
- ❌ Gather user feedback, iterate

---

## Rollback Strategy

Each phase is a git commit. If issues arise:

```bash
# Rollback to previous phase
git log --oneline
git reset --hard <commit-hash>

# Or create fix branch
git checkout -b fix/phase-3-issues
```

---

## Success Metrics

### Phase 1:
- ✅ Package compiles
- ✅ All tests pass
- ✅ Can verify test credentials

### Phase 2:
- ✅ Mode persists across restarts
- ✅ UI updates correctly
- ✅ No regressions

### Phase 3:
- ✅ Trust bundle verification works
- ✅ Tier badges display
- ✅ Fallback logic correct

### Phase 4:
- ✅ QR scanning works
- ✅ Verification logs saved
- ✅ Trust bundle syncs

### Phase 5:
- ✅ All tests pass
- ✅ Documentation complete
- ✅ Performance acceptable
- ✅ Ready for production

---

## Next Immediate Action

**Start Phase 1: Extract Trust Bundle Core Package**

Would you like me to:

1. **Create the trust_bundle_core package structure** (recommended)
2. **Extract the ManifestVerifier file first** (crypto core)
3. **Review the Trust Bundle source again** (ensure we have everything)
4. **Something else?**

Let me know and I'll help you get started! 🚀

---

**Status**: Ready to Begin  
**Current Phase**: Phase 1  
**Next Step**: Create package structure  
**Estimated Completion**: 2 weeks total
