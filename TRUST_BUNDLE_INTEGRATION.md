# Trust Bundle Verifier Integration Guide

**Integration Strategy**: Hybrid Architecture (Option D)

---

## Overview

This document outlines how to integrate the **Trust Bundle Verifier** cryptographic engine into the **Askar Import** application to create a comprehensive 3-tier verification system.

### 🎯 Architecture Roles

#### **Askar Import = Holder Application**
- **Deployment**: User's personal device (mobile phone, tablet, laptop)
- **Role**: Digital wallet for storing and presenting credentials
- **User**: Credential holder (citizen, employee, student, patient, etc.)
- **Functions**:
  - Import credentials from Askar wallet exports
  - Store credentials securely in local database
  - Browse and manage credential collection
  - **NEW**: Verify own credentials (self-verification)
  - **NEW**: Create presentations when verifier requests proof

#### **Trust Bundle Verifier = Verifier Application**
- **Deployment Options**:
  - **Physical device**: Separate tablet, kiosk, inspector device
  - **Cloud server**: REST API for online verification
  - **Edge device**: IoT gateway, access control system
- **Role**: Verifies credentials presented by holders
- **User**: Verifier (security guard, border agent, HR officer, etc.)
- **Functions**:
  - Receive credential presentations (QR, NFC, API)
  - Verify signatures using trust bundles (offline)
  - Check revocation status
  - Return verification results

### 🔄 Integration Goal

**Enable Askar Import (Holder) to self-verify credentials** using the same cryptographic engine that Trust Bundle Verifier (Verifier) uses. This allows:

1. **Holders can verify before presenting** - Check credential validity on their own device
2. **Consistent verification logic** - Same crypto engine for holder and verifier
3. **Offline capability** - Both can work without network using trust bundles
4. **Online fallback** - Holder can use ACA-Py when trust bundle unavailable

### 📱 Deployment Architecture

```
HOLDER SIDE (Personal Devices)          VERIFIER SIDE (Separate Devices/Cloud)
┌──────────────────────────┐            ┌─────────────────────────────┐
│   Askar Import App       │            │  Trust Bundle Verifier App  │
│   ==================     │            │  =========================  │
│                          │            │                             │
│   Holder Functions:      │            │   Verifier Functions:       │
│   • Import credentials   │            │   • Receive presentations   │
│   • Store in wallet      │            │   • Verify signatures       │
│   • Browse collection    │            │   • Check trust bundles     │
│                          │            │   • Return results          │
│   NEW - Self-Verify:     │            │                             │
│   • Trust Bundle (crypto)│◄───────────│   Uses same crypto core!    │
│   • ACA-Py (online)      │            │                             │
│   • Structural (fallback)│            │                             │
└──────────────────────────┘            └─────────────────────────────┘
         │                                         │
         │                                         │
         └──────────────────┬──────────────────────┘
                            │
                            ↓
                 ┌─────────────────────┐
                 │   Shared Components │
                 │   ================= │
                 │                     │
                 │  • Trust Bundle Core│
                 │  • Crypto Engine    │
                 │  • Verification API │
                 └─────────────────────┘
```

---

## Deployment Scenarios

### Scenario 1: **Separate Physical Devices (Most Common)**

**Use Case**: Entry control, border crossings, in-person verification

```
HOLDER'S PHONE                    VERIFIER'S TABLET/KIOSK
┌─────────────────┐              ┌──────────────────────┐
│  Askar Import   │              │  Trust Bundle        │
│                 │              │  Verifier            │
│  1. Has creds   │              │                      │
│  2. Self-verify │              │  1. Scans QR/NFC     │
│  3. Show QR code│─────────────▶│  2. Verifies crypto  │
│     or NFC      │  Presentation│  3. Shows ✓ or ✗    │
│                 │              │  4. Logs result      │
└─────────────────┘              └──────────────────────┘
     (Offline)                        (Offline)
```

**Examples**:
- Airport security: Traveler's phone → Agent's tablet
- Building access: Employee's phone → Security kiosk  
- Age verification: Customer's phone → Cashier's device
- Event entry: Attendee's phone → Gate scanner

**Benefits**:
- ✅ Complete offline operation
- ✅ Privacy preserved (no network calls)
- ✅ Fast verification (local crypto)
- ✅ Works in low-connectivity areas

---

### Scenario 2: **Cloud Verifier (Online Services)**

**Use Case**: Remote verification, online services, API integration

```
HOLDER'S PHONE                    CLOUD SERVER
┌─────────────────┐              ┌──────────────────────┐
│  Askar Import   │              │  Trust Bundle        │
│                 │              │  Verifier API        │
│  1. Has creds   │              │                      │
│  2. Self-verify │   HTTPS      │  1. REST endpoint    │
│  3. Send proof  │─────────────▶│  2. Verifies crypto  │
│     via API     │  POST /verify│  3. Returns result   │
│                 │              │  4. Stores logs      │
└─────────────────┘              └──────────────────────┘
    (Any network)                  (High availability)
```

**Examples**:
- Online banking: Customer verification via app
- Telemedicine: Patient credential validation
- Remote job applications: Degree verification
- Government e-services: Citizen identity checks

**Benefits**:
- ✅ Scalable (handle many verifications)
- ✅ Centralized audit logs
- ✅ Always up-to-date trust bundles
- ✅ Integration with other systems

---

### Scenario 3: **Hybrid Architecture (RECOMMENDED)**

**Use Case**: Maximum flexibility for all scenarios

```
HOLDER DEVICE                     VERIFIER (Device/Cloud)
┌─────────────────┐              ┌──────────────────────┐
│  Askar Import   │              │  Trust Bundle        │
│  (Enhanced)     │              │  Verifier            │
│                 │              │                      │
│  3-Tier Verify: │              │  Primary: Trust      │
│  1.Trust Bundle │──Local QR───▶│           Bundle     │
│  2.ACA-Py Online│              │           (offline)  │
│  3.Structural   │              │                      │
└─────────────────┘              │  Fallback: ACA-Py    │
         │                       │            (online)  │
         │                       └──────────────────────┘
         │                                 │
         └─────────────┬──────────────────┘
                       │ (When online)
                       ↓
              ┌─────────────────┐
              │  Cloud Services │
              │                 │
              │  • Traction     │
              │    ACA-Py       │
              │  • Trust Bundle │
              │    Sync Server  │
              └─────────────────┘
```

**This is YOUR target architecture!**

**Verification Priority**:
1. **Try Trust Bundle** (offline crypto) - BEST
2. **Try ACA-Py** (online crypto) - GOOD  
3. **Fall back to Structural** (no crypto) - LIMITED

**Benefits**:
- ✅ Works offline with trust bundles
- ✅ Falls back to online when needed
- ✅ Always shows verification quality to user
- ✅ Best user experience in any situation

---

## Integration Goals

1. **Best Offline Experience**: Use Trust Bundle Verifier for production-grade offline crypto verification
2. **Network Flexibility**: Fall back to ACA-Py when trust bundles unavailable but network available
3. **Maximum Compatibility**: Keep structural verification as ultimate fallback
4. **Clean Architecture**: Maintain separation of concerns between apps

---

## Architecture: 3-Tier Verification System

```dart
enum VerificationTier {
  trustBundle,    // Tier 1: Best - Full crypto offline
  acaPy,          // Tier 2: Good - Full crypto online
  structural,     // Tier 3: Fallback - Structural only
}

class VerificationStrategy {
  // Try tiers in order, use first successful one
  static const priority = [
    VerificationTier.trustBundle,  // Try offline crypto first
    VerificationTier.acaPy,         // Try online crypto second
    VerificationTier.structural,    // Fallback to structural
  ];
}
```

### Decision Matrix

| Scenario | Trust Bundle Available? | Network? | Selected Tier | Why |
|----------|------------------------|----------|---------------|-----|
| Production offline | ✅ Yes | ❌ No | **Trust Bundle** | Best crypto, works offline |
| Production online | ✅ Yes | ✅ Yes | **Trust Bundle** | Best option still preferred |
| No trust bundle, online | ❌ No | ✅ Yes | **ACA-Py** | Need network for crypto |
| No trust bundle, offline | ❌ No | ❌ No | **Structural** | Emergency fallback |

---

## Implementation Approach

### Phase 1: Extract Trust Bundle Verifier Core

Create a **shared library/package** from Trust Bundle Verifier containing:

```
trust_bundle_core/
├── lib/
│   ├── services/
│   │   ├── manifest_verifier.dart       // Ed25519 + SHA-256 verification
│   │   ├── anoncreds_verifier.dart      // AnonCreds crypto operations
│   │   └── trust_bundle_cache.dart      // Local cache management
│   ├── models/
│   │   ├── verification_result.dart     // Common result model
│   │   ├── trust_bundle.dart            // Trust bundle structure
│   │   └── schema_models.dart           // Schema/CredDef models
│   └── utils/
│       ├── crypto_utils.dart            // Ed25519 helpers
│       └── hash_utils.dart              // SHA-256 helpers
└── pubspec.yaml
```

### Phase 2: Update Askar Import Dependencies

Add trust bundle core as dependency:

```yaml
# pubspec.yaml
dependencies:
  # Existing
  aries_askar:
    git:
      url: https://github.com/your-org/aries_askar
      ref: v0.3.2
  http: ^1.5.0
  
  # NEW: Trust Bundle Core
  trust_bundle_core:
    path: ../trust_bundle_core  # Local path
    # OR
    git:
      url: https://github.com/your-org/trust_bundle_core
      ref: main
```

### Phase 3: Create Enhanced Hybrid Service

```dart
// lib/services/enhanced_verification_service.dart

import 'package:trust_bundle_core/trust_bundle_core.dart';
import 'acapy_client.dart';
import 'credential_verifier.dart';

enum VerificationTier { trustBundle, acaPy, structural }

class VerificationAttempt {
  final VerificationTier tier;
  final VerificationResult result;
  final String? error;
  final Duration duration;

  const VerificationAttempt({
    required this.tier,
    required this.result,
    this.error,
    required this.duration,
  });
}

class EnhancedVerificationResult {
  final VerificationResult result;
  final VerificationTier usedTier;
  final List<VerificationAttempt> attempts;
  final String message;

  const EnhancedVerificationResult({
    required this.result,
    required this.usedTier,
    required this.attempts,
    required this.message,
  });
  
  bool get isFullCrypto => usedTier != VerificationTier.structural;
  bool get isOffline => usedTier == VerificationTier.trustBundle;
}

class EnhancedVerificationService {
  final TrustBundleVerifier trustBundleVerifier;
  final AcaPyClient acaPyClient;
  final CredentialVerifier structuralVerifier;
  
  EnhancedVerificationService({
    required this.trustBundleVerifier,
    required this.acaPyClient,
    required this.structuralVerifier,
  });

  /// Verify credential using best available method
  Future<EnhancedVerificationResult> verifyCredential({
    required dynamic credential,
    bool preferOffline = true,
  }) async {
    final attempts = <VerificationAttempt>[];
    
    // Define tier order based on preference
    final tierOrder = preferOffline
        ? [VerificationTier.trustBundle, VerificationTier.acaPy, VerificationTier.structural]
        : [VerificationTier.acaPy, VerificationTier.trustBundle, VerificationTier.structural];
    
    // Try each tier until one succeeds
    for (final tier in tierOrder) {
      try {
        final stopwatch = Stopwatch()..start();
        final result = await _verifyWithTier(tier, credential);
        stopwatch.stop();
        
        attempts.add(VerificationAttempt(
          tier: tier,
          result: result,
          duration: stopwatch.elapsed,
        ));
        
        // Success - return with used tier
        return EnhancedVerificationResult(
          result: result,
          usedTier: tier,
          attempts: attempts,
          message: _getTierMessage(tier),
        );
        
      } catch (e) {
        attempts.add(VerificationAttempt(
          tier: tier,
          result: VerificationResult.error('Tier $tier failed'),
          error: e.toString(),
          duration: Duration.zero,
        ));
        // Continue to next tier
      }
    }
    
    // All tiers failed
    throw Exception('All verification tiers failed: ${attempts.map((a) => a.error).join(", ")}');
  }

  /// Verify using specific tier
  Future<VerificationResult> _verifyWithTier(
    VerificationTier tier,
    dynamic credential,
  ) async {
    switch (tier) {
      case VerificationTier.trustBundle:
        return await _verifyWithTrustBundle(credential);
        
      case VerificationTier.acaPy:
        return await _verifyWithAcaPy(credential);
        
      case VerificationTier.structural:
        return await _verifyStructural(credential);
    }
  }

  /// Tier 1: Trust Bundle Verification (Best)
  Future<VerificationResult> _verifyWithTrustBundle(dynamic credential) async {
    // Check if trust bundle available for this credential's schema
    final schemaId = _extractSchemaId(credential);
    final hasBundle = await trustBundleVerifier.hasTrustBundle(schemaId);
    
    if (!hasBundle) {
      throw Exception('No trust bundle available for schema: $schemaId');
    }
    
    // Perform full cryptographic verification
    return await trustBundleVerifier.verifyCached(credential);
  }

  /// Tier 2: ACA-Py Verification (Good)
  Future<VerificationResult> _verifyWithAcaPy(dynamic credential) async {
    // Check ACA-Py availability
    final isAvailable = await acaPyClient.checkHealth();
    if (!isAvailable) {
      throw Exception('ACA-Py server unavailable');
    }
    
    // Verify via ACA-Py REST API
    final response = await acaPyClient.verifyCredential(
      credential: credential as Map<String, dynamic>,
    );
    
    // Convert ACA-Py response to VerificationResult
    return _convertAcaPyResponse(response);
  }

  /// Tier 3: Structural Verification (Fallback)
  Future<VerificationResult> _verifyStructural(dynamic credential) async {
    // Use existing structural verifier
    return await structuralVerifier.verifyCredential(credential);
  }

  /// Check availability of each tier
  Future<Map<VerificationTier, bool>> checkTierAvailability() async {
    return {
      VerificationTier.trustBundle: await trustBundleVerifier.isAvailable(),
      VerificationTier.acaPy: await acaPyClient.checkHealth(),
      VerificationTier.structural: true, // Always available
    };
  }

  String _getTierMessage(VerificationTier tier) {
    switch (tier) {
      case VerificationTier.trustBundle:
        return 'OFFLINE CRYPTOGRAPHIC VERIFICATION (Trust Bundle)';
      case VerificationTier.acaPy:
        return 'ONLINE CRYPTOGRAPHIC VERIFICATION (ACA-Py)';
      case VerificationTier.structural:
        return 'STRUCTURAL VALIDATION ONLY (No Crypto)';
    }
  }

  String? _extractSchemaId(dynamic credential) {
    // Extract schema ID from credential
    if (credential is Map<String, dynamic>) {
      // Try W3C VC format
      if (credential.containsKey('credentialSchema')) {
        return credential['credentialSchema']['id'];
      }
      // Try AnonCreds format
      if (credential.containsKey('schema_id')) {
        return credential['schema_id'];
      }
    }
    return null;
  }

  VerificationResult _convertAcaPyResponse(Map<String, dynamic> response) {
    // Convert ACA-Py response to our VerificationResult model
    final isValid = response['verified'] == true;
    
    if (isValid) {
      return VerificationResult.success(
        message: 'Credential verified via ACA-Py',
        verifiedAt: DateTime.now(),
      );
    } else {
      return VerificationResult.error(
        'Verification failed: ${response['error'] ?? 'Unknown error'}',
        verifiedAt: DateTime.now(),
      );
    }
  }
}
```

### Phase 4: Update UI to Show Tier Information

```dart
// In wallet_import_page.dart

Widget _buildVerificationResults() {
  final result = _enhancedVerificationResult!;
  
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: _getStatusColor(result.result.overallStatus),
        width: 2,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        // Tier indicator with quality badge
        _buildTierIndicator(result),
        
        // Verification verdict
        _buildVerdictSection(result.result),
        
        // Tier explanation
        _buildTierExplanation(result),
        
        // Attempt history (expandable)
        if (result.attempts.length > 1)
          _buildAttemptHistory(result.attempts),
      ],
    ),
  );
}

Widget _buildTierIndicator(EnhancedVerificationResult result) {
  final tierInfo = _getTierInfo(result.usedTier);
  
  return Container(
    padding: const EdgeInsets.all(12),
    color: tierInfo.color.withOpacity(0.1),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(tierInfo.icon, color: tierInfo.color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tierInfo.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: tierInfo.color,
                  fontSize: 14,
                ),
              ),
              Text(
                tierInfo.subtitle,
                style: TextStyle(
                  color: tierInfo.color.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        // Quality badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: tierInfo.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tierInfo.badge,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

TierDisplayInfo _getTierInfo(VerificationTier tier) {
  switch (tier) {
    case VerificationTier.trustBundle:
      return TierDisplayInfo(
        title: 'OFFLINE CRYPTOGRAPHIC',
        subtitle: 'Full signature verification • Works offline',
        icon: Icons.security,
        color: Colors.green,
        badge: 'BEST',
      );
      
    case VerificationTier.acaPy:
      return TierDisplayInfo(
        title: 'ONLINE CRYPTOGRAPHIC',
        subtitle: 'Full signature verification • Requires network',
        icon: Icons.cloud_done,
        color: Colors.blue,
        badge: 'GOOD',
      );
      
    case VerificationTier.structural:
      return TierDisplayInfo(
        title: 'STRUCTURAL ONLY',
        subtitle: 'Format validation • No signature verification',
        icon: Icons.warning,
        color: Colors.orange,
        badge: 'LIMITED',
      );
  }
}

class TierDisplayInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String badge;

  const TierDisplayInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.badge,
  });
}
```

---

## Integration Steps

### Step 1: Extract Trust Bundle Core (Week 1)

1. **Create new package**: `trust_bundle_core`
2. **Move core services**:
   - `ManifestVerifier` → `trust_bundle_core/lib/services/`
   - `AnonCredsVerifier` → `trust_bundle_core/lib/services/`
   - Crypto utilities → `trust_bundle_core/lib/utils/`
3. **Define clean API**: Minimal public interface
4. **Add tests**: Unit tests for core verification
5. **Publish package**: Local path or git repository

### Step 2: Update Askar Import (Week 1-2)

1. **Add dependency**: Add `trust_bundle_core` to `pubspec.yaml`
2. **Create service**: `EnhancedVerificationService`
3. **Update UI**: Add tier indicators and explanations
4. **Test integration**: Verify all three tiers work
5. **Update docs**: Add integration documentation

### Step 3: Add Trust Bundle Sync (Week 2-3)

1. **Add sync UI**: Settings page for trust bundle configuration
2. **Background sync**: Periodic trust bundle updates
3. **Cache management**: View/clear trust bundle cache
4. **Sync status**: Show last sync time and available bundles

### Step 4: Production Testing (Week 3-4)

1. **Test offline mode**: Disable network, verify with trust bundles
2. **Test online mode**: Test ACA-Py fallback
3. **Test structural mode**: Test final fallback
4. **Performance test**: Measure verification times per tier
5. **Security audit**: Review crypto implementation

---

## API Reference

### EnhancedVerificationService

```dart
class EnhancedVerificationService {
  /// Main verification method - tries tiers in priority order
  Future<EnhancedVerificationResult> verifyCredential({
    required dynamic credential,
    bool preferOffline = true,
  });
  
  /// Check which tiers are currently available
  Future<Map<VerificationTier, bool>> checkTierAvailability();
  
  /// Force specific tier (for testing)
  Future<VerificationResult> verifyWithTier(
    VerificationTier tier,
    dynamic credential,
  );
}
```

### TrustBundleVerifier (from core package)

```dart
class TrustBundleVerifier {
  /// Check if trust bundle available for schema
  Future<bool> hasTrustBundle(String schemaId);
  
  /// Verify credential using cached trust bundle
  Future<VerificationResult> verifyCached(dynamic credential);
  
  /// Check if trust bundle service is available
  Future<bool> isAvailable();
  
  /// Sync trust bundles from server
  Future<void> syncTrustBundles(String serverUrl);
}
```

---

## Configuration

### Trust Bundle Configuration

```dart
// lib/config/trust_bundle_config.dart

class TrustBundleConfig {
  static const String serverUrl = 'https://your-trust-bundle-server.com';
  static const String trustAnchor = 'did:key:z6Mkf5rGMoatrSj1f4CyvuHBeXJELe9RPdzo2PKGNCKVtZxP';
  
  // Sync settings
  static const Duration syncInterval = Duration(hours: 24);
  static const bool autoSync = true;
  
  // Cache settings
  static const int maxCacheSize = 100; // MB
  static const Duration cacheExpiry = Duration(days: 30);
}
```

---

## Benefits of This Integration

### For Users
1. **Best offline experience** - Production crypto verification without network
2. **Flexibility** - Falls back gracefully when trust bundles unavailable
3. **Transparency** - Clear indication of verification quality
4. **Performance** - Fast offline verification

### For Developers
1. **Clean separation** - Trust Bundle core is reusable
2. **Maintainability** - Each tier is independent
3. **Testability** - Easy to test each verification method
4. **Extensibility** - Easy to add new verification tiers

### For Enterprise
1. **Security** - Production-grade cryptographic verification
2. **Compliance** - Audit trail of verification attempts
3. **Reliability** - Multiple fallback options
4. **Scalability** - Offline verification reduces server load

---

## Next Steps

1. **Review this integration plan** - Confirm approach makes sense
2. **Share Trust Bundle Verifier code** - I'll help extract the core
3. **Create trust_bundle_core package** - Set up project structure
4. **Implement EnhancedVerificationService** - Build the orchestrator
5. **Test integration** - Verify all tiers work correctly

---

**Status**: Ready for Implementation  
**Version**: 1.0.0  
**Last Updated**: October 4, 2025
