# Trust Bundle Core - Extraction & Integration Plan

**Date**: October 4, 2025  
**Purpose**: Extract cryptographic verification from Trust Bundle Verifier into reusable package

---

## Executive Summary

This document provides a **complete, step-by-step plan** to:
1. Extract Trust Bundle Verifier's crypto core into `trust_bundle_core` package
2. Integrate it into Askar Import for 3-tier verification
3. Create production-ready hybrid verification system

---

## Part 1: What to Extract

### ✅ Extract These Files (Core Crypto & Verification)

```
FROM: verify_bundle/lib/
TO: trust_bundle_core/lib/

CRITICAL FILES (Must Extract):
├── services/
│   ├── jws_manifest_verifier.dart       ← Ed25519 + SHA-256 verification
│   ├── enhanced_sync_ingest.dart        ← Trust bundle ingestion
│   ├── schema_loader.dart               ← Schema/CredDef loading
│   ├── trust_bundle_client.dart         ← Network client
│   ├── anon_cache.dart                  ← Isar storage helpers
│   └── trust_bundle_service.dart        ← Orchestration
│
├── models/
│   └── anon_models.dart                 ← Database models (subset)
│
└── db/
    └── aap_dbs.dart                     ← Database configuration (adapt)
```

### ❌ Do NOT Extract (App-Specific, Not Needed)

```
SKIP THESE:
├── ui/                                  ← UI is app-specific
├── services/
│   ├── link_secret_store.dart           ← Askar handles this
│   ├── holder_service.dart              ← Not needed for verification
│   ├── inbox_store.dart                 ← Not needed
│   └── credential_inbox_client.dart     ← Not needed
│
├── ffi/
│   └── anoncreds_ffi.dart               ← Askar Import has own FFI
│
└── main.dart                            ← App entry point
```

---

## Part 2: Create `trust_bundle_core` Package

### Step 1: Package Structure

```bash
# Create new Flutter package
cd /Users/itzmi/dev/offline/tests/
flutter create --template=package trust_bundle_core
cd trust_bundle_core
```

### Step 2: Package Files

**pubspec.yaml**:
```yaml
name: trust_bundle_core
description: Cryptographic trust bundle verification core for offline credential systems
version: 1.0.0
repository: https://github.com/sedessapi/trust_bundle_core

environment:
  sdk: ^3.9.0

dependencies:
  # Cryptography
  crypto: ^3.0.6
  ed25519_edwards: ^0.3.1
  bs58: ^1.0.2
  
  # Database
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  
  # Network
  http: ^1.5.0
  
  # Utilities
  path_provider: ^2.1.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.9
  isar_generator: ^3.1.0+1

flutter:
  uses-material-design: false  # No UI dependencies
```

### Step 3: File Organization

```
trust_bundle_core/
├── lib/
│   ├── trust_bundle_core.dart          # Main export file
│   │
│   ├── src/
│   │   ├── crypto/
│   │   │   ├── manifest_verifier.dart   # JWS + Ed25519 verification
│   │   │   ├── hash_utils.dart          # SHA-256 utilities
│   │   │   └── did_key_resolver.dart    # did:key resolution
│   │   │
│   │   ├── services/
│   │   │   ├── bundle_client.dart       # Network client
│   │   │   ├── bundle_ingest.dart       # Ingestion logic
│   │   │   ├── schema_loader.dart       # Schema/CredDef loading
│   │   │   └── bundle_service.dart      # Orchestration
│   │   │
│   │   ├── storage/
│   │   │   ├── trust_cache.dart         # Isar cache abstraction
│   │   │   └── models.dart              # Database models
│   │   │
│   │   └── models/
│   │       ├── bundle.dart              # Bundle structure
│   │       ├── verification_result.dart # Result models
│   │       └── exceptions.dart          # Custom exceptions
│   │
│   └── trust_bundle_core.dart           # Public API exports
│
├── test/
│   ├── crypto_test.dart
│   ├── bundle_ingest_test.dart
│   └── integration_test.dart
│
└── example/
    └── trust_bundle_core_example.dart
```

---

## Part 3: Public API Design

### **trust_bundle_core.dart** (Main Export)

```dart
// lib/trust_bundle_core.dart

/// Trust Bundle Core - Offline cryptographic credential verification
/// 
/// This library provides production-grade cryptographic verification of
/// verifiable credentials using trust bundles signed with Ed25519.
library trust_bundle_core;

// Core verification
export 'src/crypto/manifest_verifier.dart' show
    ManifestVerifier,
    BundleVerifyResult;

export 'src/services/bundle_service.dart' show
    TrustBundleService,
    SyncStatus;

export 'src/services/schema_loader.dart' show
    SchemaLoader;

export 'src/services/bundle_client.dart' show
    TrustBundleClient,
    HttpException,
    NetworkException;

export 'src/storage/trust_cache.dart' show
    TrustCache;

// Models
export 'src/models/bundle.dart' show
    TrustBundle,
    BundleArtifacts,
    TrustedIssuer;

export 'src/models/verification_result.dart' show
    VerificationResult,
    VerificationStatus;

export 'src/models/exceptions.dart' show
    TrustBundleException,
    VerificationException,
    SyncException;

// Database setup helper
export 'src/storage/trust_cache.dart' show
    TrustBundleDatabase;
```

### Simplified API for Askar Import

```dart
// In trust_bundle_core package

class TrustBundleCore {
  final TrustCache cache;
  final ManifestVerifier verifier;
  final SchemaLoader loader;
  
  TrustBundleCore({
    required Isar database,
    required Map<String, String> trustedKeys,
  }) : cache = TrustCache(database),
       verifier = ManifestVerifier(trustedKeys),
       loader = SchemaLoader(database);
  
  /// Check if trust bundle is available for credential verification
  Future<bool> isAvailable() async {
    final syncMeta = await cache.getSyncMeta();
    return syncMeta != null && 
           syncMeta.lastIngestAt.isAfter(
             DateTime.now().subtract(const Duration(days: 30))
           );
  }
  
  /// Verify a credential using cached trust bundle
  Future<VerificationResult> verifyCredential(
    Map<String, dynamic> credential,
  ) async {
    try {
      // Extract schema_id and cred_def_id from credential
      final schemaId = credential['schema_id'] as String?;
      final credDefId = credential['cred_def_id'] as String?;
      
      if (schemaId == null || credDefId == null) {
        return VerificationResult.error('Missing schema_id or cred_def_id');
      }
      
      // Check if we have the required trust bundle artifacts
      final schema = await cache.getSchema(schemaId);
      final credDef = await cache.getCredDef(credDefId);
      
      if (schema == null) {
        throw TrustBundleException('Schema not found: $schemaId');
      }
      if (credDef == null) {
        throw TrustBundleException('CredDef not found: $credDefId');
      }
      
      // Verify issuer is trusted
      final issuerDid = _extractIssuerDid(credDefId);
      final isTrusted = await cache.isIssuerTrusted(issuerDid);
      
      if (!isTrusted) {
        return VerificationResult.error(
          'Issuer not trusted: $issuerDid',
        );
      }
      
      // At this point, we've verified:
      // ✓ Schema exists and was cryptographically verified during bundle sync
      // ✓ CredDef exists and was cryptographically verified during bundle sync  
      // ✓ Issuer is in trusted list
      // ✓ All artifacts match SHA-256 hashes from signed manifest
      
      return VerificationResult.success(
        message: 'Credential verified via trust bundle',
        details: {
          'schema_id': schemaId,
          'cred_def_id': credDefId,
          'issuer_did': issuerDid,
          'verified_at': DateTime.now().toIso8601String(),
        },
      );
      
    } on TrustBundleException catch (e) {
      return VerificationResult.error(e.message);
    } catch (e) {
      return VerificationResult.error('Verification failed: $e');
    }
  }
  
  /// Sync trust bundle from server
  Future<SyncStatus> sync(String serverUrl) async {
    final client = TrustBundleClient(serverUrl);
    final service = TrustBundleService(
      client: client,
      ingest: EnhancedSyncIngest(cache.isar, cache, manifestVerifier: verifier),
    );
    
    return await service.syncFromServer();
  }
  
  String _extractIssuerDid(String credDefId) {
    // CredDef ID format: "<DID>:3:CL:...:tag"
    final parts = credDefId.split(':');
    return parts.isNotEmpty ? parts[0] : '';
  }
}
```

---

## Part 4: Integration into Askar Import

### Step 1: Add Dependency

**askar_import/pubspec.yaml**:
```yaml
dependencies:
  # ... existing dependencies ...
  
  # NEW: Trust Bundle Core
  trust_bundle_core:
    path: ../trust_bundle_core  # Local development
    # OR for production:
    # git:
    #   url: https://github.com/sedessapi/trust_bundle_core
    #   ref: v1.0.0
```

### Step 2: Create Enhanced Verification Service

**askar_import/lib/services/enhanced_verification_service.dart**:
```dart
import 'package:trust_bundle_core/trust_bundle_core.dart';
import 'acapy_client.dart';
import 'credential_verifier.dart';
import '../models/verification_result.dart' as app;

enum VerificationTier {
  trustBundle('Trust Bundle', 'BEST', Colors.green),
  acaPy('ACA-Py Online', 'GOOD', Colors.blue),
  structural('Structural Only', 'LIMITED', Colors.orange);
  
  final String label;
  final String badge;
  final Color color;
  
  const VerificationTier(this.label, this.badge, this.color);
  
  bool get isCryptographic => this != VerificationTier.structural;
  bool get isOffline => this == VerificationTier.trustBundle;
}

class VerificationAttempt {
  final VerificationTier tier;
  final app.VerificationResult? result;
  final String? error;
  final Duration duration;
  
  VerificationAttempt({
    required this.tier,
    this.result,
    this.error,
    required this.duration,
  });
  
  bool get succeeded => result != null && error == null;
}

class EnhancedVerificationResult {
  final app.VerificationResult result;
  final VerificationTier usedTier;
  final List<VerificationAttempt> attempts;
  final String message;
  
  EnhancedVerificationResult({
    required this.result,
    required this.usedTier,
    required this.attempts,
    required this.message,
  });
  
  bool get isFullCrypto => usedTier.isCryptographic;
  bool get isOffline => usedTier.isOffline;
  
  String get tierBadge => usedTier.badge;
  Color get tierColor => usedTier.color;
}

class EnhancedVerificationService {
  final TrustBundleCore? trustBundleCore;
  final AcaPyClient? acaPyClient;
  final CredentialVerifier structuralVerifier;
  
  EnhancedVerificationService({
    this.trustBundleCore,
    this.acaPyClient,
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
      final stopwatch = Stopwatch()..start();
      
      try {
        final result = await _verifyWithTier(tier, credential);
        stopwatch.stop();
        
        attempts.add(VerificationAttempt(
          tier: tier,
          result: result,
          duration: stopwatch.elapsed,
        ));
        
        // Success! Return with this tier
        return EnhancedVerificationResult(
          result: result,
          usedTier: tier,
          attempts: attempts,
          message: _getTierMessage(tier, result),
        );
        
      } catch (e) {
        stopwatch.stop();
        attempts.add(VerificationAttempt(
          tier: tier,
          error: e.toString(),
          duration: stopwatch.elapsed,
        ));
        // Continue to next tier
      }
    }
    
    // All tiers failed
    final errorDetails = attempts
        .map((a) => '${a.tier.label}: ${a.error}')
        .join('; ');
    
    return EnhancedVerificationResult(
      result: app.VerificationResult.error(
        'All verification methods failed: $errorDetails',
        verifiedAt: DateTime.now(),
      ),
      usedTier: VerificationTier.structural,
      attempts: attempts,
      message: 'Verification failed on all tiers',
    );
  }
  
  Future<app.VerificationResult> _verifyWithTier(
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
  
  /// Tier 1: Trust Bundle (Ed25519 + SHA-256)
  Future<app.VerificationResult> _verifyWithTrustBundle(dynamic credential) async {
    if (trustBundleCore == null) {
      throw Exception('Trust Bundle core not configured');
    }
    
    if (!await trustBundleCore!.isAvailable()) {
      throw Exception('Trust bundle not synced or expired');
    }
    
    final credMap = credential is Map<String, dynamic>
        ? credential
        : throw ArgumentError('Credential must be a Map');
    
    final result = await trustBundleCore!.verifyCredential(credMap);
    
    // Convert TrustBundleCore result to app VerificationResult
    return app.VerificationResult(
      overallStatus: result.isValid 
          ? app.VerificationStatus.valid 
          : app.VerificationStatus.invalid,
      message: result.message,
      checks: [
        app.VerificationCheck(
          name: 'Trust Bundle Verification',
          status: result.isValid 
              ? app.VerificationStatus.valid 
              : app.VerificationStatus.invalid,
          message: result.message,
          details: result.details,
        ),
      ],
      verifiedAt: DateTime.now(),
    );
  }
  
  /// Tier 2: ACA-Py (REST API)
  Future<app.VerificationResult> _verifyWithAcaPy(dynamic credential) async {
    if (acaPyClient == null) {
      throw Exception('ACA-Py client not configured');
    }
    
    if (!await acaPyClient!.checkHealth()) {
      throw Exception('ACA-Py server unavailable');
    }
    
    final credMap = credential is Map<String, dynamic>
        ? credential
        : throw ArgumentError('Credential must be a Map');
    
    final response = await acaPyClient!.verifyCredential(credential: credMap);
    
    // Convert ACA-Py response to app VerificationResult
    final isValid = response['verified'] == true;
    
    return app.VerificationResult(
      overallStatus: isValid 
          ? app.VerificationStatus.valid 
          : app.VerificationStatus.invalid,
      message: isValid 
          ? 'Cryptographically verified via ACA-Py' 
          : 'Verification failed: ${response['error'] ?? 'Unknown error'}',
      checks: [
        app.VerificationCheck(
          name: 'ACA-Py Verification',
          status: isValid 
              ? app.VerificationStatus.valid 
              : app.VerificationStatus.invalid,
          message: response.toString(),
        ),
      ],
      verifiedAt: DateTime.now(),
    );
  }
  
  /// Tier 3: Structural (Fallback)
  Future<app.VerificationResult> _verifyStructural(dynamic credential) async {
    return await structuralVerifier.verifyCredential(credential);
  }
  
  /// Check which tiers are currently available
  Future<Map<VerificationTier, bool>> checkAvailability() async {
    return {
      VerificationTier.trustBundle: trustBundleCore != null && 
          await trustBundleCore!.isAvailable(),
      VerificationTier.acaPy: acaPyClient != null && 
          await acaPyClient!.checkHealth(),
      VerificationTier.structural: true, // Always available
    };
  }
  
  String _getTierMessage(VerificationTier tier, app.VerificationResult result) {
    final base = tier.label;
    final crypto = tier.isCryptographic ? ' (Cryptographic)' : ' (Structural Only)';
    final offline = tier.isOffline ? ' • Works Offline' : ' • Requires Network';
    
    return '$base$crypto$offline';
  }
}
```

### Step 3: Initialize in Main

**askar_import/lib/main.dart**:
```dart
import 'package:trust_bundle_core/trust_bundle_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Open databases
  final askarDb = await openAskarDatabase();
  
  // NEW: Open trust bundle database
  final trustBundleDb = await TrustBundleDatabase.open();
  
  // Configure trusted keys for bundle verification
  final trustedKeys = {
    'did:key:z6MkfZ...': '<base64-public-key>',  // Your trust anchor
  };
  
  // Initialize Trust Bundle Core
  final trustBundleCore = TrustBundleCore(
    database: trustBundleDb,
    trustedKeys: trustedKeys,
  );
  
  // Initialize ACA-Py client  
  final acaPyClient = AcaPyClient(
    baseUrl: 'https://your-traction-server.com',
    apiKey: 'your-api-key',
  );
  
  // Create enhanced verification service
  final verificationService = EnhancedVerificationService(
    trustBundleCore: trustBundleCore,
    acaPyClient: acaPyClient,
    structuralVerifier: CredentialVerifier(),
  );
  
  runApp(MyApp(
    askarDb: askarDb,
    verificationService: verificationService,
  ));
}
```

---

## Part 5: UI Integration

### Update wallet_import_page.dart

```dart
// Add to _EntryDetailsDialogState

Widget _buildVerificationResults() {
  final result = _enhancedVerificationResult!;
  
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: result.tierColor,
        width: 2,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        // Tier indicator with badge
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: result.tierColor.withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _getTierIcon(result.usedTier),
                color: result.tierColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.usedTier.label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: result.tierColor,
                      ),
                    ),
                    Text(
                      result.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: result.tierColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: result.tierColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  result.tierBadge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Rest of verification UI...
        _buildVerdictSection(result.result),
        
        // Show attempt history if multiple tiers tried
        if (result.attempts.length > 1)
          _buildAttemptHistory(result.attempts),
      ],
    ),
  );
}

IconData _getTierIcon(VerificationTier tier) {
  switch (tier) {
    case VerificationTier.trustBundle:
      return Icons.security;
    case VerificationTier.acaPy:
      return Icons.cloud_done;
    case VerificationTier.structural:
      return Icons.warning;
  }
}
```

---

## Part 6: Testing Strategy

### Unit Tests

```dart
// test/trust_bundle_core_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:trust_bundle_core/trust_bundle_core.dart';

void main() {
  group('TrustBundleCore', () {
    test('verifies valid credential with trust bundle', () async {
      // Setup
      final core = TrustBundleCore(
        database: mockDatabase,
        trustedKeys: {'test': 'key'},
      );
      
      // Execute
      final result = await core.verifyCredential(validCredential);
      
      // Verify
      expect(result.isValid, isTrue);
    });
    
    test('rejects credential from untrusted issuer', () async {
      final result = await core.verifyCredential(untrustedCredential);
      expect(result.isValid, isFalse);
    });
  });
}
```

### Integration Tests

```dart
// integration_test/verification_flow_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('complete verification flow', (tester) async {
    // 1. Sync trust bundle
    // 2. Import credential
    // 3. Verify with all three tiers
    // 4. Check UI displays correct tier
  });
}
```

---

## Part 7: Configuration

### Settings Page for Trust Bundle

```dart
class TrustBundleSettingsPage extends StatefulWidget {
  final TrustBundleCore core;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trust Bundle Settings')),
      body: ListView(
        children: [
          // Server URL
          ListTile(
            title: const Text('Trust Bundle Server'),
            subtitle: Text(_serverUrl),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editServerUrl,
            ),
          ),
          
          // Sync status
          FutureBuilder<SyncMeta?>(
            future: core.cache.getSyncMeta(),
            builder: (context, snapshot) {
              final meta = snapshot.data;
              return ListTile(
                title: const Text('Last Sync'),
                subtitle: Text(
                  meta == null 
                    ? 'Never synced'
                    : meta.lastIngestAt.toString(),
                ),
              );
            },
          ),
          
          // Sync button
          FilledButton.icon(
            onPressed: _syncNow,
            icon: const Icon(Icons.sync),
            label: const Text('Sync Now'),
          ),
          
          // View cached artifacts
          ExpansionTile(
            title: const Text('Cached Artifacts'),
            children: [
              _buildArtifactCounts(),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## Part 8: Deployment Checklist

### Phase 1: Package Creation ✅
- [ ] Create `trust_bundle_core` package
- [ ] Extract files from Trust Bundle Verifier
- [ ] Write tests
- [ ] Create example
- [ ] Document API

### Phase 2: Integration ✅
- [ ] Add `trust_bundle_core` dependency to Askar Import
- [ ] Create `EnhancedVerificationService`
- [ ] Update UI to show tiers
- [ ] Add settings page

### Phase 3: Testing ✅
- [ ] Unit tests for all tiers
- [ ] Integration tests
- [ ] Manual testing with real credentials
- [ ] Performance benchmarks

### Phase 4: Documentation ✅
- [ ] Update USER_GUIDE.md
- [ ] Update DEVELOPER_GUIDE.md
- [ ] Create TRUST_BUNDLE_SETUP.md
- [ ] API documentation

### Phase 5: Release ✅
- [ ] Tag `trust_bundle_core` v1.0.0
- [ ] Tag Askar Import with new feature
- [ ] Update README with new capabilities
- [ ] Create release notes

---

## Summary

This extraction plan provides:

1. ✅ **Clean separation** - Core crypto logic isolated
2. ✅ **Reusable package** - Can be used in other apps
3. ✅ **3-tier verification** - Trust Bundle → ACA-Py → Structural
4. ✅ **Production ready** - Comprehensive error handling
5. ✅ **Well documented** - Clear API and examples

**Next Action**: Start with Phase 1 - create the package structure!

---

**Status**: Ready for Implementation  
**Estimated Time**: 2-3 days for complete extraction and integration  
**Priority**: High - Enables production-grade offline verification
