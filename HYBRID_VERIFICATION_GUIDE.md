# Hybrid Verification: Offline + Online with Traction ACA-Py

Complete guide for implementing hybrid verification that works offline (structural validation) and online (cryptographic verification via Traction ACA-Py).

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Setup Instructions](#setup-instructions)
4. [Implementation Guide](#implementation-guide)
5. [Usage Examples](#usage-examples)
6. [Testing](#testing)
7. [Troubleshooting](#troubleshooting)

---

## Overview

### Verification Modes

#### **Offline Mode** (Current Implementation)
- ✅ Works without internet connection
- ✅ Structural validation of credentials
- ✅ Format detection (W3C VC, AnonCreds)
- ✅ Field validation
- ❌ **No cryptographic signature verification**
- ❌ **No revocation checking**

#### **Online Mode** (New - via Traction ACA-Py)
- ✅ Full cryptographic verification
- ✅ Signature validation against public keys
- ✅ Revocation status checking
- ✅ DID resolution
- ✅ Schema/CredDef validation
- ❌ Requires internet connection
- ❌ Requires ACA-Py server access

### Hybrid Approach

The app automatically:
1. **Tries online verification** if connected to Traction ACA-Py
2. **Falls back to offline** if no connection
3. **Shows verification mode** to user (Offline/Online)
4. **Allows manual mode selection** for testing

---

## Architecture

```
┌─────────────────────────────────────────────┐
│      Flutter App (Holder Wallet)           │
│                                             │
│  ┌────────────────────────────────────┐    │
│  │  HybridVerificationService         │    │
│  │  - Auto mode selection             │    │
│  │  - Offline fallback                │    │
│  └────────────────────────────────────┘    │
│           │                   │             │
│           ↓                   ↓             │
│  ┌──────────────┐    ┌─────────────────┐   │
│  │   Offline    │    │    Online       │   │
│  │  Verifier    │    │  ACA-Py Client  │   │
│  └──────────────┘    └─────────────────┘   │
│                              │              │
└──────────────────────────────┼──────────────┘
                               │
                    Network Detection
                               │
┌──────────────────────────────┼──────────────┐
│  Traction ACA-Py (Remote Server)            │
│                                              │
│  REST API Endpoints:                         │
│  - /status/ready (health check)              │
│  - /credential/verify (verification)         │
│  - /present-proof-2.0/* (proof protocol)     │
│  - /connections/* (connection management)    │
│  - /credentials/* (credential management)    │
└──────────────────────────────────────────────┘
```

---

## Setup Instructions

### Step 1: Add Dependencies

Update `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.5.0
  path_provider: ^2.1.5
  # Note: connectivity_plus removed to avoid dependency
  # We'll use http health check instead
```

Run:
```bash
flutter pub get
```

### Step 2: Configure Traction ACA-Py Connection

Create configuration file or add to settings:

```dart
// lib/config/acapy_config.dart
class AcaPyConfig {
  static const String baseUrl = 'https://your-traction-server.com';
  static const String? apiKey = 'your-api-key-if-required';
  
  // Optional: Tenant-specific endpoint
  static const String? tenantId = 'your-tenant-id';
  
  static String get fullUrl {
    if (tenantId != null) {
      return '$baseUrl/tenant/$tenantId';
    }
    return baseUrl;
  }
}
```

### Step 3: Initialize Services

In your main.dart or app initialization:

```dart
import 'package:askar_import/services/acapy_client.dart';
import 'package:askar_import/services/hybrid_verification_service.dart';
import 'package:askar_import/config/acapy_config.dart';

// Initialize ACA-Py client
final acaPyClient = AcaPyClient(
  baseUrl: AcaPyConfig.fullUrl,
  apiKey: AcaPyConfig.apiKey,
);

// Initialize hybrid verification service
final verificationService = HybridVerificationService(
  acaPyClient: acaPyClient,
);

// Check initial connectivity
final isOnline = await verificationService.isOnlineAvailable();
print('ACA-Py connection: ${isOnline ? 'Online' : 'Offline'}');
```

---

## Implementation Guide

### Phase 1: Update UI to Show Verification Mode

Update the wallet_import_page.dart to display verification mode:

```dart
// In _EntryDetailsDialogState

Future<void> _verifyCredential() async {
  setState(() {
    _isVerifying = true;
    _verificationResult = null;
  });

  try {
    final value = widget.entry['value'];
    if (value == null) {
      setState(() {
        _verificationResult = VerificationResult.error(
          'No credential data found',
          verifiedAt: DateTime.now(),
        );
      });
      return;
    }

    // Use hybrid verification service
    final hybridResult = await _hybridVerificationService.verifyCredential(
      credential: value,
      preferOnline: true, // Try online first
    );

    setState(() {
      _verificationResult = hybridResult.result;
      _verificationMode = hybridResult.mode;
      _verificationMessage = hybridResult.message;
    });

    // Auto-scroll to results
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  } catch (e) {
    setState(() {
      _verificationResult = VerificationResult.error(
        'Failed to verify: $e',
        verifiedAt: DateTime.now(),
      );
    });
  } finally {
    setState(() {
      _isVerifying = false;
    });
  }
}
```

### Phase 2: Update Verification Results UI

Add mode indicator to the results display:

```dart
Widget _buildVerificationResults() {
  final result = _verificationResult!;
  
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: _getStatusColor(result.overallStatus),
        width: 2,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        // Mode indicator at top
        Container(
          padding: const EdgeInsets.all(8),
          color: _verificationMode == VerificationMode.online
              ? Colors.green.shade50
              : Colors.orange.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _verificationMode == VerificationMode.online
                    ? Icons.cloud_done
                    : Icons.cloud_off,
                size: 16,
                color: _verificationMode == VerificationMode.online
                    ? Colors.green
                    : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                _verificationMode == VerificationMode.online
                    ? 'ONLINE VERIFICATION (Cryptographic)'
                    : 'OFFLINE VERIFICATION (Structural Only)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _verificationMode == VerificationMode.online
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ),
        
        // Existing verification verdict display
        _buildVerdictSection(result),
        
        // Additional message about verification type
        if (_verificationMessage != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              _verificationMessage!,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        
        // Rest of verification results...
      ],
    ),
  );
}
```

### Phase 3: Add Manual Mode Selection (Optional)

Add buttons to let users choose verification mode:

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Expanded(
      child: FilledButton.tonalIcon(
        onPressed: _isVerifying ? null : () => _verifyCredential(forceOffline: true),
        icon: const Icon(Icons.cloud_off),
        label: const Text('Verify Offline'),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: FilledButton.icon(
        onPressed: _isVerifying ? null : () => _verifyCredential(forceOnline: true),
        icon: const Icon(Icons.cloud_done),
        label: const Text('Verify Online'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.green,
        ),
      ),
    ),
  ],
)
```

---

## Usage Examples

### Example 1: Automatic Mode Selection

```dart
// App automatically chooses best mode
final result = await hybridVerificationService.verifyCredential(
  credential: credentialJson,
  preferOnline: true, // Try online first, fall back to offline
);

print('Mode: ${result.mode}');
print('Status: ${result.result.overallStatus}');
print('Message: ${result.message}');
```

### Example 2: Force Offline Verification

```dart
// Useful for testing or when you know there's no connection
final result = await hybridVerificationService.verifyOffline(
  credentialJson,
);

print('Verified offline: ${result.result.overallStatus}');
```

### Example 3: Force Online Verification

```dart
// Requires connection, throws error if ACA-Py unavailable
try {
  final result = await hybridVerificationService.verifyOnline(
    credentialJson,
  );
  
  print('Cryptographically verified: ${result.acaPyResponse}');
} catch (e) {
  print('Online verification failed: $e');
}
```

### Example 4: Check Availability Before Verifying

```dart
final isOnline = await hybridVerificationService.isOnlineAvailable();

if (isOnline) {
  print('ACA-Py is reachable - can do cryptographic verification');
} else {
  print('Offline mode only - structural validation');
}
```

---

## Testing

### Test Offline Mode

1. **Disable network** or **stop Traction server**
2. **Verify credential** - should show "OFFLINE VERIFICATION"
3. **Check results** - structural validation only
4. **Verify verdict** - shows warning about no crypto verification

### Test Online Mode

1. **Ensure Traction ACA-Py is running** and accessible
2. **Verify credential** - should show "ONLINE VERIFICATION"
3. **Check results** - includes cryptographic signature check
4. **Verify verdict** - shows full verification status

### Test Fallback Behavior

1. **Start with online mode** working
2. **Verify a credential** - should use online
3. **Disconnect network** mid-session
4. **Verify another credential** - should fall back to offline
5. **Reconnect network**
6. **Verify again** - should return to online mode

### Test ACA-Py Integration

```bash
# Test health endpoint
curl https://your-traction-server.com/status/ready

# Test credential verification (with valid credential JSON)
curl -X POST https://your-traction-server.com/credential/verify \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -d @credential.json
```

---

## Troubleshooting

### Issue: Always Shows Offline Mode

**Possible Causes:**
- Traction ACA-Py URL incorrect
- API key missing or incorrect
- Network connectivity issue
- Firewall blocking connection
- CORS issues (if web)

**Solutions:**
1. Check ACA-Py URL in config
2. Test health endpoint manually: `curl https://your-server/status/ready`
3. Verify API key if required
4. Check network connectivity
5. Look at Flutter console for error messages

### Issue: Online Verification Fails

**Possible Causes:**
- Credential format not supported by ACA-Py
- Missing schema/cred-def on ledger
- Invalid signature
- Network timeout

**Solutions:**
1. Check credential format (W3C or AnonCreds)
2. Verify schema/cred-def exist on ledger
3. Check ACA-Py logs for errors
4. Increase timeout in http client
5. Fall back to offline verification

### Issue: Slow Verification

**Causes:**
- Network latency to Traction server
- ACA-Py processing time
- Ledger query time

**Solutions:**
1. Use offline mode for quick structural check
2. Cache verification results
3. Show loading indicator
4. Consider using local ACA-Py instance

### Issue: Certificate/SSL Errors

**Solutions:**
```dart
// For development only - accept self-signed certificates
// DO NOT use in production!
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = 
          (X509Certificate cert, String host, int port) => true;
  }
}

// In main.dart
void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}
```

---

## Next Steps

### Phase 4: Implement Proof Presentation

Once verification is working, implement full proof protocol:

1. **Receive proof requests** from verifiers
2. **Show proof request to user** - what's being asked
3. **Select credentials** to fulfill request
4. **Generate proof** using ACA-Py
5. **Send proof** back to verifier

See **PROOF_PROTOCOL_GUIDE.md** (to be created) for details.

### Phase 5: Add Connection Management

Implement DIDComm connections:

1. **Create/receive invitations**
2. **Establish connections** with verifiers
3. **Store connection records**
4. **Handle proof requests** over established connections

### Phase 6: Add Notifications

Implement event handling:

1. **WebSocket connection** to ACA-Py
2. **Listen for events** (proof requests, credential offers)
3. **Show notifications** to user
4. **Handle events** appropriately

---

## API Reference

### HybridVerificationService

```dart
class HybridVerificationService {
  /// Verify with automatic mode selection
  Future<HybridVerificationResult> verifyCredential({
    required dynamic credential,
    bool preferOnline = true,
  });
  
  /// Force offline verification
  Future<HybridVerificationResult> verifyOffline(dynamic credential);
  
  /// Force online verification (throws if unavailable)
  Future<HybridVerificationResult> verifyOnline(dynamic credential);
  
  /// Check if online mode is available
  Future<bool> isOnlineAvailable();
}
```

### AcaPyClient

```dart
class AcaPyClient {
  /// Check server health
  Future<bool> checkHealth();
  
  /// Verify credential cryptographically
  Future<Map<String, dynamic>> verifyCredential({
    required Map<String, dynamic> credential,
  });
  
  /// Get credentials from wallet
  Future<List<Map<String, dynamic>>> getCredentials({
    int? count,
    int? start,
    String? wql,
  });
  
  /// Send proof presentation
  Future<Map<String, dynamic>> sendProofPresentation({
    required String presentationExchangeId,
    required Map<String, dynamic> requestedCredentials,
    Map<String, dynamic>? selfAttestedAttributes,
  });
  
  // ... more methods
}
```

---

## Configuration Examples

### Development Configuration

```dart
class AcaPyConfig {
  static const String baseUrl = 'http://localhost:8031';
  static const String? apiKey = null; // No auth in dev
}
```

### Production Configuration

```dart
class AcaPyConfig {
  static const String baseUrl = 'https://traction.example.com';
  static const String apiKey = String.fromEnvironment('ACAPY_API_KEY');
  static const String tenantId = String.fromEnvironment('TENANT_ID');
}
```

### Multi-Tenant Configuration

```dart
class AcaPyConfig {
  static String baseUrl(String tenantId) {
    return 'https://traction.example.com/tenant/$tenantId';
  }
  
  static String apiKey(String tenantId) {
    // Fetch from secure storage
    return SecureStorage.getApiKey(tenantId);
  }
}
```

---

**Version**: 1.0.0  
**Last Updated**: October 4, 2025  
**Status**: Implementation Ready
