import 'dart:convert';
import 'package:trust_bundle_core/trust_bundle_core.dart' as tbc;
import 'credential_verifier.dart';
import 'acapy_client.dart';
import '../models/verification_result.dart';

/// Enhanced verification result with 3-tier verification
class EnhancedVerificationResult {
  final VerificationResult structuralResult;
  final VerificationResult? trustBundleResult;
  final String tier;
  final String tierDescription;
  final bool success;
  final String message;
  final Map<String, dynamic>? details;

  EnhancedVerificationResult({
    required this.structuralResult,
    this.trustBundleResult,
    required this.tier,
    required this.tierDescription,
    required this.success,
    required this.message,
    this.details,
  });

  /// Get color for tier
  String get tierColor {
    switch (tier) {
      case 'BEST':
        return '#4CAF50'; // Green
      case 'GOOD':
        return '#2196F3'; // Blue
      case 'BASIC':
        return '#FFC107'; // Amber
      default:
        return '#F44336'; // Red
    }
  }
}

/// Enhanced verification service with 3-tier verification logic
class EnhancedVerificationService {
  final tbc.VerifierService verifierService;
  final AcaPyClient? acaPyClient;

  EnhancedVerificationService({
    required this.verifierService,
    this.acaPyClient,
  });

  /// Verify credential with 3-tier logic:
  /// BEST - Trust Bundle (offline, fast, trusted)
  /// GOOD - Online Ledger (online, slower, cryptographically verified)
  /// BASIC - Structural only (offline, minimal verification)
  Future<EnhancedVerificationResult> verifyCredential(
    dynamic credentialData,
  ) async {
    // 1. Parse credential
    Map<String, dynamic> credential;
    if (credentialData is String) {
      credential = jsonDecode(credentialData) as Map<String, dynamic>;
    } else if (credentialData is Map<String, dynamic>) {
      credential = credentialData;
    } else {
      return EnhancedVerificationResult(
        structuralResult: VerificationResult.error('Invalid credential type'),
        tier: 'FAILED',
        tierDescription: 'Invalid credential format',
        success: false,
        message: 'Credential must be a JSON string or Map',
      );
    }

    // 2. Always do structural verification first
    final structuralResult = await CredentialVerifier.verify(credential);

    // If structural verification fails, stop here
    if (structuralResult.overallStatus == VerificationStatus.invalid) {
      return EnhancedVerificationResult(
        structuralResult: structuralResult,
        tier: 'FAILED',
        tierDescription: 'Structural validation failed',
        success: false,
        message: 'Credential has structural issues',
      );
    }

    // 3. Try BEST tier - Trust Bundle verification (offline, fast)
    try {
      final bundleResult = await verifierService.verifyCredential(credential);

      if (bundleResult.success && bundleResult.tier == tbc.VerificationTier.best) {
        return EnhancedVerificationResult(
          structuralResult: structuralResult,
          tier: 'BEST',
          tierDescription: 'Verified using offline Trust Bundle',
          success: true,
          message: bundleResult.message,
          details: bundleResult.details,
        );
      }
    } catch (e) {
      print('Trust Bundle verification failed: $e');
      // Fall through to next tier
    }

    // 4. Try GOOD tier - Online ledger verification
    if (acaPyClient != null) {
      try {
        final isHealthy = await acaPyClient!.checkHealth();

        if (isHealthy) {
          final acaPyResult = await acaPyClient!.verifyCredential(
            credential: credential,
          );

          if (acaPyResult['verified'] == true) {
            return EnhancedVerificationResult(
              structuralResult: structuralResult,
              tier: 'GOOD',
              tierDescription: 'Verified using online ledger',
              success: true,
              message: 'Credential cryptographically verified via online ledger',
              details: acaPyResult,
            );
          }
        }
      } catch (e) {
        print('Online verification failed: $e');
        // Fall through to BASIC tier
      }
    }

    // 5. Fall back to BASIC tier - Structural only
    return EnhancedVerificationResult(
      structuralResult: structuralResult,
      tier: 'BASIC',
      tierDescription: 'Basic structural verification only',
      success: structuralResult.overallStatus == VerificationStatus.valid ||
          structuralResult.overallStatus == VerificationStatus.warning,
      message: structuralResult.overallStatus == VerificationStatus.valid
          ? 'Credential is structurally valid (basic verification only)'
          : 'Credential structure is valid with warnings',
    );
  }
}
