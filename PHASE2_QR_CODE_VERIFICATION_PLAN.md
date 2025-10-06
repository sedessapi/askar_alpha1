# Phase 2: QR Code Verification Plan

## Executive Summary

Phase 2 introduces **QR code-based credential verification** for offline, peer-to-peer credential exchange. This approach aligns perfectly with Phase 1's offline-first architecture and provides the most natural user flow for how digital credentials are actually shared in the real world.

**Why QR Code First?**
- **Natural User Flow**: Matches how credentials are presented in real life (holder shows, verifier scans)
- **Works Offline**: Perfect continuation of Phase 1's offline capabilities
- **Faster Implementation**: 2-3 weeks vs 5-7 weeks for online verification
- **No Backend Dependency**: Verifier operates independently
- **Foundation for Phase 3**: Online verification enhances (not replaces) QR verification

**Timeline**: 2-3 weeks (10-15 days)
**Architecture**: Holder app generates QR → Verifier app scans → Offline Trust Bundle verification

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [QR Code Format Specification](#qr-code-format-specification)
3. [Phase 2 Sub-Phases](#phase-2-sub-phases)
4. [Detailed Implementation Plan](#detailed-implementation-plan)
5. [UI/UX Design](#uiux-design)
6. [Security Considerations](#security-considerations)
7. [Testing Strategy](#testing-strategy)
8. [Success Criteria](#success-criteria)
9. [Timeline & Resources](#timeline--resources)

---

## Architecture Overview

### High-Level Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                      QR CODE VERIFICATION FLOW                   │
└─────────────────────────────────────────────────────────────────┘

HOLDER DEVICE                           VERIFIER DEVICE
┌──────────────────┐                   ┌──────────────────┐
│  Askar Alpha1    │                   │  Askar Alpha1    │
│  (Holder Mode)   │                   │ (Verifier Mode)  │
└──────────────────┘                   └──────────────────┘
        │                                       │
        │ 1. Select Credential                  │
        ▼                                       │
┌──────────────────┐                           │
│ Open Wallet      │                           │
│ (synced_wallet)  │                           │
└──────────────────┘                           │
        │                                       │
        │ 2. Choose credential to share         │
        ▼                                       │
┌──────────────────┐                           │
│ Generate QR Code │                           │
│ (W3C VC format)  │                           │
└──────────────────┘                           │
        │                                       │
        │ 3. Display QR on screen               │
        ▼                                       │
┌──────────────────┐                           │
│   ████████████   │                           │
│   ██  QR  ████   │────────────────────────┐  │
│   ████████████   │                        │  │
└──────────────────┘                        │  │
                                            │  │
                                4. Scan QR  │  │
                                            │  │
                                            ▼  ▼
                                    ┌──────────────────┐
                                    │  QR Scanner      │
                                    │  (mobile_scanner)│
                                    └──────────────────┘
                                            │
                                            │ 5. Decode W3C VC
                                            ▼
                                    ┌──────────────────┐
                                    │ Parse Credential │
                                    │ JSON-LD          │
                                    └──────────────────┘
                                            │
                                            │ 6. Verify offline
                                            ▼
                                    ┌──────────────────┐
                                    │ Trust Bundle     │
                                    │ Verification     │
                                    │ (Phase 1 logic)  │
                                    └──────────────────┘
                                            │
                                            │ 7. Show result
                                            ▼
                                    ┌──────────────────┐
                                    │ ✅ BEST VERIFIED │
                                    │ Issuer: Trusted  │
                                    │ Status: Valid    │
                                    └──────────────────┘
```

### Key Components

1. **Holder Side**
   - Credential selection UI (from synced_wallet)
   - QR code generation service
   - Full-screen QR display with brightness boost
   - Credential data encoder (W3C VC JSON)

2. **Verifier Side**
   - QR scanner UI with camera preview
   - QR decoder service
   - Existing Trust Bundle verification (Phase 1)
   - Results display with verification tier

3. **Shared Components**
   - W3C VC JSON-LD parser
   - Error handling for malformed QR codes
   - Offline verification fallback logic

---

## QR Code Format Specification

### Data Structure

The QR code contains a **complete W3C Verifiable Credential** in JSON-LD format:

```json
{
  "@context": [
    "https://www.w3.org/2018/credentials/v1",
    "https://w3id.org/security/suites/ed25519-2020/v1"
  ],
  "id": "urn:uuid:3978344f-8596-4c3a-a978-8fcaba3903c5",
  "type": ["VerifiableCredential", "UniversityDegreeCredential"],
  "issuer": {
    "id": "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",
    "name": "Example University"
  },
  "issuanceDate": "2023-01-01T19:23:24Z",
  "expirationDate": "2025-12-31T23:59:59Z",
  "credentialSubject": {
    "id": "did:key:z6Mkg7S...",
    "givenName": "Alice",
    "familyName": "Smith",
    "degree": {
      "type": "BachelorDegree",
      "name": "Bachelor of Science and Arts"
    }
  },
  "proof": {
    "type": "Ed25519Signature2020",
    "created": "2023-01-01T19:23:24Z",
    "verificationMethod": "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK#z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",
    "proofPurpose": "assertionMethod",
    "proofValue": "z58DAdFfa9SkqZMVPxAQpic7ndSayn1PzZs6ZjWp1CktyGesjuTSwRdoWhAfGFCF5bppETSTojQCrfFPP2oumHKtz"
  }
}
```

### QR Code Encoding

- **Format**: JSON string (minified, no whitespace)
- **Encoding**: UTF-8
- **Error Correction**: High (30% recovery)
- **Version**: Auto-sized based on data length
- **Maximum Size**: ~2,953 bytes (version 40)

### Compression Strategy

For large credentials (> 2KB), apply gzip compression:

```dart
import 'dart:convert';
import 'dart:io';

String compressCredential(Map<String, dynamic> credential) {
  final json = jsonEncode(credential);
  final bytes = utf8.encode(json);
  final compressed = gzip.encode(bytes);
  final base64Compressed = base64Encode(compressed);
  
  // Add compression marker prefix
  return 'gzip:$base64Compressed';
}
```

Verifier detects `gzip:` prefix and decompresses before parsing.

---

## Phase 2 Sub-Phases

### Phase 2.1: QR Code Generation (Days 1-3)

**Goal**: Holder can generate QR code from any credential in their wallet.

**Deliverables**:
- QR generation service
- Credential-to-JSON encoder
- Basic QR display page
- Unit tests for encoding

**Technical Tasks**:
1. Add `qr_flutter: ^4.1.0` dependency
2. Create `lib/services/qr_code_service.dart`
3. Create `lib/ui/pages/holder_present_credential_page.dart`
4. Add "Share as QR" button to credential detail view
5. Implement brightness boost for QR display
6. Test with various credential sizes

**Key Code**: See [QR Generation Service](#qr-generation-service) below.

---

### Phase 2.2: QR Code Scanning (Days 4-6)

**Goal**: Verifier can scan QR codes and decode credential data.

**Deliverables**:
- QR scanner UI with camera preview
- QR decoder service
- Error handling for invalid QR codes
- Permission requests for camera access

**Technical Tasks**:
1. Add `mobile_scanner: ^5.0.0` dependency
2. Add camera permissions to iOS/Android manifests
3. Create `lib/ui/pages/verifier_scan_qr_page.dart`
4. Implement real-time QR detection
5. Add gzip decompression support
6. Test with malformed/corrupt QR codes

**Key Code**: See [QR Scanner Service](#qr-scanner-service) below.

---

### Phase 2.3: Offline Verification Flow (Days 7-9)

**Goal**: Integrate QR scanning with existing Trust Bundle verification.

**Deliverables**:
- End-to-end verification flow
- Verification tier display (BEST/GOOD/BASIC)
- Offline-first design (no network required)
- Results page with credential details

**Technical Tasks**:
1. Parse W3C VC JSON-LD from QR data
2. Extract issuer DID from credential
3. Call existing `TrustBundleService.verifyCredential()`
4. Display verification results
5. Handle edge cases (expired, revoked, unknown issuer)
6. Add scan history (optional)

**Integration Point**:
```dart
// In verifier_scan_qr_page.dart
final credential = await qrCodeService.decodeQR(qrData);
final result = await trustBundleService.verifyCredential(
  credential: credential,
  walletName: 'temp_scan', // In-memory, not persisted
);

// Show result in UI
if (result.tier == VerificationTier.BEST) {
  // Show green checkmark, "BEST VERIFIED"
}
```

---

### Phase 2.4: Enhanced Features (Days 10-12)

**Goal**: Polish UX and add production-ready features.

**Deliverables**:
- Scan history with timestamps
- Multiple credential batch sharing (multi-QR)
- QR code size optimization
- Accessibility improvements
- Animated transitions

**Technical Tasks**:
1. Persist scan history to local SQLite
2. Add "Share Multiple" option (generates paginated QRs)
3. Implement dynamic QR sizing based on data
4. Add VoiceOver/TalkBack support
5. Implement haptic feedback on successful scan
6. Add QR code expiration (time-limited presentations)

**Advanced Feature**: Time-limited QR codes
```dart
// Add timestamp to QR payload
final qrPayload = {
  'credential': credential,
  'generatedAt': DateTime.now().toIso8601String(),
  'expiresIn': 300, // 5 minutes
};

// Verifier checks expiration
final generatedAt = DateTime.parse(payload['generatedAt']);
final expiresIn = payload['expiresIn'];
if (DateTime.now().difference(generatedAt).inSeconds > expiresIn) {
  throw Exception('QR code expired');
}
```

---

### Phase 2.5: Testing & Refinement (Days 13-15)

**Goal**: Ensure production quality with comprehensive testing.

**Deliverables**:
- Unit tests (80%+ coverage)
- Widget tests for all pages
- Integration tests for full flow
- Performance benchmarks
- User acceptance testing

**Technical Tasks**:
1. Write unit tests for QR encoding/decoding
2. Test compression/decompression logic
3. Widget tests for QR display and scanner pages
4. Integration test: Generate QR → Scan → Verify → Result
5. Test on low-end devices (performance)
6. Test with poor lighting (camera)
7. Test with large credentials (2KB+)
8. Security audit (credential data exposure)

**Test Coverage Goals**:
- Unit tests: 85%+
- Widget tests: 70%+
- Integration tests: Key user flows (holder present, verifier scan)

---

## Detailed Implementation Plan

### QR Generation Service

**File**: `lib/services/qr_code_service.dart`

```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class QrCodeService {
  /// Maximum QR code data size in bytes (for version 40, high error correction)
  static const int maxQrDataSize = 2953;
  
  /// Generates QR code data string from a credential
  /// Returns base64-encoded string for QR widget
  String generateQrData({
    required Map<String, dynamic> credential,
    bool compress = true,
  }) {
    try {
      // Minify JSON (remove whitespace)
      final json = jsonEncode(credential);
      final bytes = utf8.encode(json);
      
      // Check if compression is needed
      if (compress && bytes.length > 1500) {
        debugPrint('[QR] Credential size ${bytes.length} bytes, compressing...');
        final compressed = gzip.encode(bytes);
        final base64Compressed = base64Encode(compressed);
        
        // Add compression marker
        final result = 'gzip:$base64Compressed';
        debugPrint('[QR] Compressed to ${result.length} bytes');
        
        if (result.length > maxQrDataSize) {
          throw Exception('Credential too large for QR code (${result.length} bytes)');
        }
        
        return result;
      }
      
      // No compression needed
      if (bytes.length > maxQrDataSize) {
        throw Exception('Credential too large for QR code (${bytes.length} bytes)');
      }
      
      debugPrint('[QR] Credential size ${bytes.length} bytes, no compression');
      return json;
    } catch (e) {
      debugPrint('[QR] Error generating QR data: $e');
      rethrow;
    }
  }
  
  /// Decodes QR code data string back to credential
  Map<String, dynamic> decodeQrData(String qrData) {
    try {
      // Check for compression marker
      if (qrData.startsWith('gzip:')) {
        debugPrint('[QR] Decompressing QR data...');
        final base64Data = qrData.substring(5); // Remove 'gzip:' prefix
        final compressed = base64Decode(base64Data);
        final bytes = gzip.decode(compressed);
        final json = utf8.decode(bytes);
        return jsonDecode(json) as Map<String, dynamic>;
      }
      
      // No compression, parse directly
      return jsonDecode(qrData) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[QR] Error decoding QR data: $e');
      throw Exception('Invalid QR code format');
    }
  }
  
  /// Validates that credential is suitable for QR encoding
  bool isCredentialQrCompatible(Map<String, dynamic> credential) {
    try {
      final json = jsonEncode(credential);
      final bytes = utf8.encode(json);
      
      // Even with compression, must fit in QR code
      if (bytes.length > maxQrDataSize * 2) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Estimates QR code size (for UI display)
  String estimateQrSize(Map<String, dynamic> credential) {
    final json = jsonEncode(credential);
    final bytes = utf8.encode(json);
    
    if (bytes.length < 1500) {
      return 'Small (~${bytes.length} bytes)';
    } else if (bytes.length < 2500) {
      return 'Medium (~${bytes.length} bytes)';
    } else {
      return 'Large (~${bytes.length} bytes)';
    }
  }
}
```

---

### QR Scanner Service

**File**: `lib/ui/pages/verifier_scan_qr_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../services/qr_code_service.dart';
import '../../services/trust_bundle_service.dart';
import '../../models/verification_result.dart';

class VerifierScanQrPage extends StatefulWidget {
  const VerifierScanQrPage({Key? key}) : super(key: key);

  @override
  State<VerifierScanQrPage> createState() => _VerifierScanQrPageState();
}

class _VerifierScanQrPageState extends State<VerifierScanQrPage> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleQrDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final String? qrData = barcodes.first.rawValue;
    if (qrData == null || qrData.isEmpty) return;
    
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });
    
    try {
      // Decode QR data
      final qrService = QrCodeService();
      final credential = qrService.decodeQrData(qrData);
      
      // Verify credential using Trust Bundle
      final trustBundleService = context.read<TrustBundleService>();
      final result = await trustBundleService.verifyCredential(
        credential: credential,
        walletName: 'temp_scan', // Not persisted
      );
      
      // Navigate to results page
      if (mounted) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationResultPage(result: result),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to verify credential: ${e.toString()}';
        _isProcessing = false;
      });
      
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Credential QR'),
        actions: [
          IconButton(
            icon: Icon(_scannerController.torchEnabled ? Icons.flash_on : Icons.flash_off),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleQrDetected,
            errorBuilder: (context, error, child) {
              return Center(
                child: Text(
                  'Camera error: ${error.errorDetails?.message}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            },
          ),
          
          // Scanning overlay
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Verifying credential...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          
          // Instructions
          if (!_isProcessing)
            Positioned(
              bottom: 32,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Point camera at QR code to verify credential',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

---

### Holder Present Credential Page

**File**: `lib/ui/pages/holder_present_credential_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/qr_code_service.dart';

class HolderPresentCredentialPage extends StatefulWidget {
  final Map<String, dynamic> credential;
  
  const HolderPresentCredentialPage({
    Key? key,
    required this.credential,
  }) : super(key: key);

  @override
  State<HolderPresentCredentialPage> createState() => _HolderPresentCredentialPageState();
}

class _HolderPresentCredentialPageState extends State<HolderPresentCredentialPage> {
  late String _qrData;
  late String _sizeEstimate;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Store original brightness
  double? _originalBrightness;

  @override
  void initState() {
    super.initState();
    _generateQrCode();
    _boostBrightness();
  }

  @override
  void dispose() {
    _restoreBrightness();
    super.dispose();
  }

  Future<void> _generateQrCode() async {
    try {
      final qrService = QrCodeService();
      
      // Check if credential is compatible
      if (!qrService.isCredentialQrCompatible(widget.credential)) {
        setState(() {
          _errorMessage = 'Credential is too large to encode in QR code';
          _isLoading = false;
        });
        return;
      }
      
      // Generate QR data
      final qrData = qrService.generateQrData(credential: widget.credential);
      final sizeEstimate = qrService.estimateQrSize(widget.credential);
      
      setState(() {
        _qrData = qrData;
        _sizeEstimate = sizeEstimate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate QR code: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _boostBrightness() async {
    try {
      // Get current brightness
      // Note: This requires screen_brightness package or platform channel
      // For now, just set to max
      await SystemChannels.platform.invokeMethod('SystemChrome.setApplicationSwitcherDescription', {
        'brightness': 1.0,
      });
    } catch (e) {
      debugPrint('Failed to boost brightness: $e');
    }
  }

  Future<void> _restoreBrightness() async {
    try {
      // Restore original brightness
      if (_originalBrightness != null) {
        await SystemChannels.platform.invokeMethod('SystemChrome.setApplicationSwitcherDescription', {
          'brightness': _originalBrightness,
        });
      }
    } catch (e) {
      debugPrint('Failed to restore brightness: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Present Credential'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Instructions
                    Container(
                      color: Colors.green.shade50,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Show this QR code to the verifier',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // QR Code
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: _qrData,
                            version: QrVersions.auto,
                            size: 300.0,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                          ),
                        ),
                      ),
                    ),
                    
                    // Credential info
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            widget.credential['type']?.last ?? 'Credential',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Size: $_sizeEstimate',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '💡 Keep screen bright for easy scanning',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
```

---

## UI/UX Design

### Holder Flow

1. **Entry Point**: "Share as QR" button on credential detail page
2. **QR Display**: Full-screen QR code with:
   - White background (optimal for scanning)
   - High error correction (30% recovery)
   - Auto brightness boost
   - Credential type label below QR
   - "Keep screen bright" tip
3. **Exit**: Back button returns to credential list

### Verifier Flow

1. **Entry Point**: "Scan Credential" button on home page or app bar
2. **Scanner UI**: Full-screen camera preview with:
   - Semi-transparent target area (guides user)
   - Torch toggle button
   - Instructions at bottom: "Point camera at QR code"
   - Auto-detect (no manual capture button)
3. **Processing**: Overlay with spinner and "Verifying..." message
4. **Results**: Navigate to verification result page showing:
   - Verification tier badge (BEST/GOOD/BASIC)
   - Issuer name and trust status
   - Credential details
   - Timestamp of verification

### Visual Design Principles

- **Contrast**: High contrast for QR visibility
- **Simplicity**: Minimal UI during scanning (don't distract)
- **Feedback**: Immediate visual feedback on scan success
- **Accessibility**: Large touch targets, VoiceOver support
- **Error Handling**: Clear error messages with recovery actions

---

## Security Considerations

### Holder Side

1. **Data Exposure**: QR code contains full credential data
   - **Risk**: Anyone can scan and see credential details
   - **Mitigation**: Add "Are you sure?" confirmation before displaying QR
   - **Future**: Implement selective disclosure (Phase 3)

2. **Screen Recording**: Someone could capture QR code
   - **Risk**: Credential replay attacks
   - **Mitigation**: Add time-limited QR codes (expires after 5 min)
   - **Detection**: Detect screen recording on iOS/Android (future)

3. **Over-the-Shoulder**: Someone could photograph QR code
   - **Risk**: Same as screen recording
   - **Mitigation**: Time-limited QR + user awareness training

### Verifier Side

1. **Malicious QR Codes**: Attacker provides fake credential
   - **Risk**: Injection attacks, buffer overflows
   - **Mitigation**: Strict JSON parsing, size limits, schema validation
   - **Defense**: Trust Bundle verification catches fake issuers

2. **Camera Permissions**: App needs camera access
   - **Risk**: Privacy concern
   - **Mitigation**: Request permission with clear explanation, only when needed

3. **Data Persistence**: Scanned credentials stored locally
   - **Risk**: Privacy violation if device stolen
   - **Mitigation**: Encrypt scan history, add auto-delete after 7 days

### Network Considerations

- **Offline First**: QR verification works without network (Phase 1 Trust Bundle)
- **No Server Calls**: Verifier doesn't send credential data to backend (privacy)
- **Local Only**: All verification happens on device

---

## Testing Strategy

### Unit Tests

**File**: `test/services/qr_code_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:askar_alpha1/services/qr_code_service.dart';

void main() {
  group('QrCodeService', () {
    late QrCodeService qrService;

    setUp(() {
      qrService = QrCodeService();
    });

    test('generates QR data from credential', () {
      final credential = {
        '@context': ['https://www.w3.org/2018/credentials/v1'],
        'id': 'urn:uuid:123',
        'type': ['VerifiableCredential'],
        'issuer': 'did:key:z6Mk...',
        'credentialSubject': {'name': 'Alice'},
      };

      final qrData = qrService.generateQrData(credential: credential);
      expect(qrData, isNotEmpty);
    });

    test('decodes QR data back to credential', () {
      final credential = {
        '@context': ['https://www.w3.org/2018/credentials/v1'],
        'id': 'urn:uuid:123',
        'type': ['VerifiableCredential'],
      };

      final qrData = qrService.generateQrData(credential: credential);
      final decoded = qrService.decodeQrData(qrData);

      expect(decoded['id'], equals('urn:uuid:123'));
      expect(decoded['type'], equals(['VerifiableCredential']));
    });

    test('compresses large credentials', () {
      // Create large credential (2KB+)
      final largeCredential = {
        '@context': ['https://www.w3.org/2018/credentials/v1'],
        'id': 'urn:uuid:123',
        'type': ['VerifiableCredential'],
        'credentialSubject': {
          'data': 'x' * 2000, // 2KB of data
        },
      };

      final qrData = qrService.generateQrData(
        credential: largeCredential,
        compress: true,
      );

      expect(qrData, startsWith('gzip:'));
      
      // Verify decompression works
      final decoded = qrService.decodeQrData(qrData);
      expect(decoded['credentialSubject']['data'], equals('x' * 2000));
    });

    test('throws error for oversized credentials', () {
      final oversizedCredential = {
        '@context': ['https://www.w3.org/2018/credentials/v1'],
        'id': 'urn:uuid:123',
        'credentialSubject': {
          'data': 'x' * 10000, // 10KB, too large even compressed
        },
      };

      expect(
        () => qrService.generateQrData(credential: oversizedCredential),
        throwsException,
      );
    });
  });
}
```

### Integration Tests

**File**: `integration_test/qr_verification_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:askar_alpha1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full QR verification flow', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Holder: Navigate to credentials list
    await tester.tap(find.text('Open Wallet'));
    await tester.pumpAndSettle();

    // Holder: Open a credential
    await tester.tap(find.text('UniversityDegreeCredential').first);
    await tester.pumpAndSettle();

    // Holder: Tap "Share as QR"
    await tester.tap(find.text('Share as QR'));
    await tester.pumpAndSettle();

    // Verify QR code is displayed
    expect(find.byType(QrImageView), findsOneWidget);

    // Simulate verifier scanning (in real test, would need mock scanner)
    // For now, just verify UI elements exist
    expect(find.text('Present Credential'), findsOneWidget);
  });
}
```

### Performance Benchmarks

- **QR Generation**: < 100ms for average credential (1KB)
- **QR Scanning**: < 500ms from detection to verification result
- **Large Credential**: < 200ms with compression (2KB)
- **Memory Usage**: < 50MB during scanning

---

## Success Criteria

### Phase 2.1 Success Metrics
- ✅ Holder can generate QR code from any credential
- ✅ QR code displays full-screen with high contrast
- ✅ Brightness auto-boosts when QR displayed
- ✅ Unit tests pass (QR encoding/decoding)

### Phase 2.2 Success Metrics
- ✅ Verifier can scan QR codes using camera
- ✅ QR detection happens automatically (no manual capture)
- ✅ Malformed QR codes show clear error messages
- ✅ Camera permissions requested with explanation

### Phase 2.3 Success Metrics
- ✅ Scanned credentials verified using Trust Bundle (Phase 1)
- ✅ Verification tier displayed (BEST/GOOD/BASIC)
- ✅ Works offline (no network required)
- ✅ Results page shows issuer name and credential details

### Phase 2.4 Success Metrics
- ✅ Scan history persisted locally
- ✅ Time-limited QR codes implemented (5 min expiry)
- ✅ Compression works for large credentials (2KB+)
- ✅ Accessibility: VoiceOver and TalkBack supported

### Phase 2.5 Success Metrics
- ✅ 80%+ unit test coverage
- ✅ All integration tests pass
- ✅ Performance benchmarks met (< 100ms QR gen, < 500ms scan)
- ✅ User acceptance testing completed
- ✅ Zero critical bugs in production

### Overall Phase 2 Success
- ✅ Holder can present credentials via QR code
- ✅ Verifier can scan and verify credentials offline
- ✅ Trust Bundle verification integrated seamlessly
- ✅ Production-ready quality (tests, performance, UX)
- ✅ Foundation laid for Phase 3 (online enhancements)

---

## Timeline & Resources

### Detailed Schedule

| Sub-Phase | Duration | Start | End | Key Deliverable |
|-----------|----------|-------|-----|-----------------|
| 2.1 QR Generation | 3 days | Day 1 | Day 3 | Holder can generate QR codes |
| 2.2 QR Scanning | 3 days | Day 4 | Day 6 | Verifier can scan QR codes |
| 2.3 Verification Flow | 3 days | Day 7 | Day 9 | End-to-end offline verification |
| 2.4 Enhanced Features | 3 days | Day 10 | Day 12 | Scan history, time-limited QR |
| 2.5 Testing & Refinement | 3 days | Day 13 | Day 15 | Production-ready quality |
| **Total** | **15 days** | **Day 1** | **Day 15** | **Phase 2 complete** |

### Resource Requirements

**Development**:
- 1 Flutter developer (full-time, 3 weeks)
- Familiarity with camera APIs and QR libraries

**Testing**:
- 2 physical devices (iOS + Android) for testing
- Good lighting conditions for camera testing
- Various QR code sizes for testing

**Tools & Libraries**:
- `qr_flutter: ^4.1.0` (QR generation)
- `mobile_scanner: ^5.0.0` (QR scanning)
- Existing Phase 1 Trust Bundle service

**External Dependencies**:
- None! Fully offline, no backend required

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| QR code too small on low-res screens | Medium | Medium | Dynamic sizing, test on various devices |
| Poor camera quality affects scanning | High | Medium | High error correction (30%), clear instructions |
| Large credentials don't fit in QR | Medium | High | Gzip compression, size validation |
| Battery drain from camera use | Low | Low | Optimize detection speed, auto-stop after scan |
| Privacy: QR code photographed | Medium | High | Time-limited QR codes, user warnings |

### Milestones

1. **Day 3**: QR generation works, holder can display credentials
2. **Day 6**: QR scanning works, verifier can decode credentials
3. **Day 9**: End-to-end verification flow complete
4. **Day 12**: Enhanced features (history, expiry) implemented
5. **Day 15**: All tests pass, production-ready

---

## Appendix: W3C VC Format

### Minimal W3C Verifiable Credential

```json
{
  "@context": [
    "https://www.w3.org/2018/credentials/v1"
  ],
  "type": ["VerifiableCredential"],
  "issuer": "did:key:z6Mk...",
  "issuanceDate": "2023-01-01T00:00:00Z",
  "credentialSubject": {
    "id": "did:key:z6Mk...",
    "claim": "value"
  },
  "proof": {
    "type": "Ed25519Signature2020",
    "created": "2023-01-01T00:00:00Z",
    "proofPurpose": "assertionMethod",
    "verificationMethod": "did:key:z6Mk...#key-1",
    "proofValue": "z..."
  }
}
```

### Extended W3C VC with Revocation

```json
{
  "@context": [
    "https://www.w3.org/2018/credentials/v1",
    "https://w3id.org/security/suites/ed25519-2020/v1"
  ],
  "id": "urn:uuid:3978344f-8596-4c3a-a978-8fcaba3903c5",
  "type": ["VerifiableCredential", "UniversityDegreeCredential"],
  "issuer": {
    "id": "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",
    "name": "Example University"
  },
  "issuanceDate": "2023-01-01T19:23:24Z",
  "expirationDate": "2025-12-31T23:59:59Z",
  "credentialSubject": {
    "id": "did:key:z6Mkg7S...",
    "givenName": "Alice",
    "familyName": "Smith",
    "degree": {
      "type": "BachelorDegree",
      "name": "Bachelor of Science and Arts"
    }
  },
  "credentialStatus": {
    "id": "https://example.edu/status/24",
    "type": "StatusList2021Entry",
    "statusPurpose": "revocation",
    "statusListIndex": "24",
    "statusListCredential": "https://example.edu/credentials/status/3"
  },
  "proof": {
    "type": "Ed25519Signature2020",
    "created": "2023-01-01T19:23:24Z",
    "verificationMethod": "did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK#z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK",
    "proofPurpose": "assertionMethod",
    "proofValue": "z58DAdFfa9SkqZMVPxAQpic7ndSayn1PzZs6ZjWp1CktyGesjuTSwRdoWhAfGFCF5bppETSTojQCrfFPP2oumHKtz"
  }
}
```

---

## Phase 2 → Phase 3 Transition

Once Phase 2 (QR Code) is complete, Phase 3 (Online Verification) will **enhance** the QR flow:

1. **Selective Disclosure**: QR contains proof request, not full credential
2. **Real-Time Revocation**: Online check augments offline verification
3. **Audit Trail**: Backend logs verification events
4. **Advanced Proofs**: Zero-knowledge predicates (age > 18 without revealing birthdate)

Phase 2 establishes the **foundation** (holder presents, verifier scans), and Phase 3 adds **online capabilities** for when network is available.

---

## Conclusion

Phase 2 delivers a **production-ready QR code verification system** that:

✅ Works completely offline (Trust Bundle verification)  
✅ Provides natural user experience (holder shows, verifier scans)  
✅ Integrates seamlessly with Phase 1 architecture  
✅ Lays foundation for Phase 3 online enhancements  
✅ Delivers value in 2-3 weeks  

This is the **fastest path to a working verifiable credentials app** that users can actually use in real-world scenarios.

---

**Next Steps**:
1. ✅ Approve Phase 2 plan
2. Rename existing Phase 2 → Phase 3
3. Start Phase 2.1: QR Generation (Day 1)
4. Tag milestone: `phase2_qr_planning`

