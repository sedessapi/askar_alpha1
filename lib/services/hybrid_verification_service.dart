import 'dart:convert';
import 'credential_verifier.dart';
import 'acapy_client.dart';
import '../models/verification_result.dart';

enum VerificationMode {
  offline, // Structural validation only
  online, // Full cryptographic verification via ACA-Py
}

/// Result of verification including mode used
class HybridVerificationResult {
  final VerificationResult result;
  final VerificationMode mode;
  final String message;
  final Map<String, dynamic>? acaPyResponse;

  HybridVerificationResult({
    required this.result,
    required this.mode,
    required this.message,
    this.acaPyResponse,
  });
}

/// Hybrid verification service that works offline and online
class HybridVerificationService {
  final AcaPyClient? acaPyClient;

  HybridVerificationService({this.acaPyClient});

  /// Verify credential with automatic mode selection
  Future<HybridVerificationResult> verifyCredential({
    required dynamic credential,
    bool preferOnline = true,
  }) async {
    // Try online verification first if preferred and available
    if (preferOnline && acaPyClient != null) {
      try {
        // Check if ACA-Py is reachable
        final isHealthy = await acaPyClient!.checkHealth();

        if (isHealthy) {
          return await _verifyOnline(credential);
        }
      } catch (e) {
        // Fall through to offline verification
        print('Online verification failed: $e');
      }
    }

    // Fall back to offline verification
    return await _verifyOffline(credential);
  }

  /// Force offline verification (structural only)
  Future<HybridVerificationResult> verifyOffline(dynamic credential) async {
    return await _verifyOffline(credential);
  }

  /// Force online verification (requires connectivity)
  Future<HybridVerificationResult> verifyOnline(dynamic credential) async {
    if (acaPyClient == null) {
      throw Exception('ACA-Py client not configured');
    }

    return await _verifyOnline(credential);
  }

  /// Private: Offline structural verification
  Future<HybridVerificationResult> _verifyOffline(dynamic credential) async {
    final result = await CredentialVerifier.verify(credential);

    return HybridVerificationResult(
      result: result,
      mode: VerificationMode.offline,
      message: result.overallStatus == VerificationStatus.valid
          ? 'Credential is structurally valid (offline verification only - '
                'signatures not cryptographically verified)'
          : result.overallStatus == VerificationStatus.warning
          ? 'Credential structure is valid with warnings (offline '
                'verification - signatures not verified)'
          : 'Credential has structural issues (offline verification)',
    );
  }

  /// Private: Online cryptographic verification via ACA-Py
  Future<HybridVerificationResult> _verifyOnline(dynamic credential) async {
    try {
      // Parse credential
      Map<String, dynamic> credentialMap;
      if (credential is String) {
        credentialMap = jsonDecode(credential);
      } else if (credential is Map<String, dynamic>) {
        credentialMap = credential;
      } else {
        throw ArgumentError('Invalid credential type');
      }

      // Call ACA-Py verification endpoint
      final acaPyResult = await acaPyClient!.verifyCredential(
        credential: credentialMap,
      );

      // Also run structural verification
      final structuralResult = await CredentialVerifier.verify(credential);

      // Combine results
      final isValid = acaPyResult['verified'] == true;
      final acaPyErrors = acaPyResult['error'] as String?;

      // Create combined verification result
      final combinedResult = _combineResults(
        structuralResult,
        isValid,
        acaPyErrors,
      );

      return HybridVerificationResult(
        result: combinedResult,
        mode: VerificationMode.online,
        message: isValid
            ? 'Credential is cryptographically valid (verified by ACA-Py)'
            : 'Credential verification failed: ${acaPyErrors ?? "Unknown error"}',
        acaPyResponse: acaPyResult,
      );
    } catch (e) {
      // If online verification fails, fall back to offline
      print('Online verification error: $e');
      return await _verifyOffline(credential);
    }
  }

  /// Combine structural and cryptographic verification results
  VerificationResult _combineResults(
    VerificationResult structural,
    bool cryptoValid,
    String? cryptoError,
  ) {
    final checks = List<VerificationCheck>.from(structural.checks);

    // Add cryptographic verification check
    checks.add(
      VerificationCheck(
        category: 'Cryptographic',
        name: 'Signature Verification',
        status: cryptoValid ? CheckStatus.passed : CheckStatus.failed,
        message: cryptoValid
            ? 'Cryptographic signature is valid'
            : 'Cryptographic signature verification failed',
        details: cryptoError,
      ),
    );

    // Overall status: must pass both structural AND cryptographic checks
    final overallStatus = !cryptoValid
        ? VerificationStatus.invalid
        : structural.overallStatus == VerificationStatus.invalid
        ? VerificationStatus.invalid
        : structural.overallStatus == VerificationStatus.warning
        ? VerificationStatus.warning
        : VerificationStatus.valid;

    return VerificationResult(
      overallStatus: overallStatus,
      checks: checks,
      verifiedAt: DateTime.now(),
    );
  }

  /// Check if online verification is available
  Future<bool> isOnlineAvailable() async {
    if (acaPyClient == null) return false;

    try {
      return await acaPyClient!.checkHealth();
    } catch (e) {
      return false;
    }
  }
}
