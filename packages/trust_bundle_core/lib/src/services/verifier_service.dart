import 'dart:convert';
import '../models/bundle_rec.dart';
import '../models/schema_rec.dart';
import '../models/cred_def_rec.dart';
import '../services/db_service.dart';

/// Verification tier indicating the level of trust
enum VerificationTier {
  best, // Verified using offline trust bundle
  good, // Verified using online ledger
  basic, // Basic structural verification only
  failed, // Verification failed
  noBundle, // No trust bundle available
}

/// Result of credential verification
class VerificationResult {
  final bool success;
  final VerificationTier tier;
  final String message;
  final Map<String, dynamic>? details;

  VerificationResult({
    required this.success,
    required this.tier,
    required this.message,
    this.details,
  });

  /// Get user-friendly tier name
  String get tierName {
    switch (tier) {
      case VerificationTier.best:
        return 'BEST';
      case VerificationTier.good:
        return 'GOOD';
      case VerificationTier.basic:
        return 'BASIC';
      case VerificationTier.failed:
        return 'FAILED';
      case VerificationTier.noBundle:
        return 'NO BUNDLE';
    }
  }

  /// Get tier description
  String get tierDescription {
    switch (tier) {
      case VerificationTier.best:
        return 'Verified using offline Trust Bundle';
      case VerificationTier.good:
        return 'Verified using online ledger';
      case VerificationTier.basic:
        return 'Basic structural verification';
      case VerificationTier.failed:
        return 'Verification failed';
      case VerificationTier.noBundle:
        return 'No trust bundle available';
    }
  }
}

/// Service for verifying credentials using the trust bundle
class VerifierService {
  final DbService dbService;

  VerifierService(this.dbService);

  /// Verify a credential using the trust bundle
  Future<VerificationResult> verifyCredential(
    Map<String, dynamic> credential,
  ) async {
    try {
      // 1. Extract issuer, schemaId, credDefId from credential
      final issuer = credential['issuer'] as String?;
      final schemaId = credential['schema_id'] as String?;
      final credDefId = credential['cred_def_id'] as String?;

      if (issuer == null || schemaId == null || credDefId == null) {
        return VerificationResult(
          success: false,
          tier: VerificationTier.failed,
          message: 'Credential missing required fields (issuer, schema_id, cred_def_id)',
        );
      }

      // 2. Get the latest bundle (assuming ID 1 is the current bundle)
      final bundle = await dbService.isar.bundleRecs.get(1);

      if (bundle == null) {
        return VerificationResult(
          success: false,
          tier: VerificationTier.noBundle,
          message: 'No trust bundle found in database',
        );
      }

      final bundleContent = json.decode(bundle.content) as Map<String, dynamic>;

      // 3. Check if issuer is trusted
      final trustedIssuers = (bundleContent['trusted_issuers'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      if (!trustedIssuers.contains(issuer)) {
        return VerificationResult(
          success: false,
          tier: VerificationTier.failed,
          message: 'Issuer is not in the trusted issuers list',
          details: {
            'issuer': issuer,
            'trusted_issuers_count': trustedIssuers.length,
          },
        );
      }

      // 4. Lookup schema
      final schema = await dbService.isar.schemaRecs.getBySchemaId(schemaId);
      if (schema == null) {
        return VerificationResult(
          success: false,
          tier: VerificationTier.failed,
          message: 'Schema not found in trust bundle',
          details: {
            'schema_id': schemaId,
          },
        );
      }

      // 5. Lookup credential definition
      final credDef = await dbService.isar.credDefRecs.getByCredDefId(credDefId);
      if (credDef == null) {
        return VerificationResult(
          success: false,
          tier: VerificationTier.failed,
          message: 'Credential definition not found in trust bundle',
          details: {
            'cred_def_id': credDefId,
          },
        );
      }

      // 6. All checks passed
      return VerificationResult(
        success: true,
        tier: VerificationTier.best,
        message: 'Credential verified using Trust Bundle',
        details: {
          'issuer': issuer,
          'schema_id': schemaId,
          'cred_def_id': credDefId,
          'bundle_version': bundleContent['bundle_version'],
          'network': bundleContent['network'],
        },
      );
    } catch (e) {
      return VerificationResult(
        success: false,
        tier: VerificationTier.failed,
        message: 'Verification error: $e',
      );
    }
  }
}
