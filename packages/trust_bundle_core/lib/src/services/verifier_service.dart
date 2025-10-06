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
      print('🔎 VerifierService: Starting credential verification');
      print('📄 Credential structure: ${credential.keys.toList()}');

      // 1. Extract issuer, schemaId, credDefId from credential
      // Handle multiple credential formats (W3C VC, AnonCreds, etc.)
      String? issuer = credential['issuer'] as String?;
      final schemaId = credential['schema_id'] as String?;
      final credDefId = credential['cred_def_id'] as String?;

      // For AnonCreds format, extract issuer from schema_id or cred_def_id
      // Schema ID format: <issuer_did>:2:<schema_name>:<version>
      // Cred Def ID format: <issuer_did>:3:CL:<schema_seq_no>:<tag>
      if (issuer == null && schemaId != null) {
        final parts = schemaId.split(':');
        if (parts.length >= 2) {
          issuer = parts[0];
          print('📝 Extracted issuer from schema_id: $issuer');
        }
      }

      if (issuer == null && credDefId != null) {
        final parts = credDefId.split(':');
        if (parts.length >= 2) {
          issuer = parts[0];
          print('📝 Extracted issuer from cred_def_id: $issuer');
        }
      }

      print('🔑 Extracted values:');
      print('   Issuer: $issuer');
      print('   Schema ID: $schemaId');
      print('   Cred Def ID: $credDefId');

      if (issuer == null || schemaId == null || credDefId == null) {
        print('❌ Missing required fields!');
        return VerificationResult(
          success: false,
          tier: VerificationTier.failed,
          message:
              'Credential missing required fields (issuer, schema_id, cred_def_id)',
        );
      }

      // 2. Get the latest bundle (assuming ID 1 is the current bundle)
      print('📦 Looking up bundle with ID 1...');
      final bundle = await dbService.isar.bundleRecs.get(1);

      if (bundle == null) {
        print('❌ No bundle found in database');
        return VerificationResult(
          success: false,
          tier: VerificationTier.noBundle,
          message: 'No trust bundle found in database',
        );
      }

      print('✅ Bundle found: ${bundle.bundleId}');
      final bundleContent = json.decode(bundle.content) as Map<String, dynamic>;

      // 3. Check if issuer is trusted
      print('👥 Checking trusted issuers...');

      // Parse trusted issuers - they might be stored as objects with 'did' field
      // or as plain DID strings
      final trustedIssuersRaw = bundleContent['trusted_issuers'] as List?;
      final List<String> trustedIssuers = [];

      if (trustedIssuersRaw != null) {
        for (var entry in trustedIssuersRaw) {
          if (entry is String) {
            trustedIssuers.add(entry);
          } else if (entry is Map) {
            final did = entry['did'] as String?;
            if (did != null) {
              trustedIssuers.add(did);
            }
          }
        }
      }

      print('📝 Trusted issuers count: ${trustedIssuers.length}');
      if (trustedIssuers.isNotEmpty) {
        print(
          '📝 First few trusted issuers: ${trustedIssuers.take(3).toList()}',
        );
      }
      print('📝 Looking for issuer: $issuer');

      if (!trustedIssuers.contains(issuer)) {
        print('❌ Issuer not trusted: $issuer');
        return VerificationResult(
          success: false,
          tier: VerificationTier.failed,
          message: 'Issuer is not in the trusted issuers list',
          details: {
            'issuer': issuer,
            'trusted_issuers_count': trustedIssuers.length,
            'trusted_issuers_sample': trustedIssuers.take(5).toList(),
          },
        );
      }

      print('✅ Issuer is trusted');

      // 4. Lookup schema
      print('📋 Looking up schema: $schemaId');
      final schema = await dbService.isar.schemaRecs.getBySchemaId(schemaId);
      if (schema == null) {
        print('❌ Schema not found');
        return VerificationResult(
          success: false,
          tier: VerificationTier.failed,
          message: 'Schema not found in trust bundle',
          details: {'schema_id': schemaId},
        );
      }

      print('✅ Schema found: ${schema.schemaId}');

      // 5. Lookup credential definition
      print('🔑 Looking up cred def: $credDefId');
      final credDef = await dbService.isar.credDefRecs.getByCredDefId(
        credDefId,
      );
      if (credDef == null) {
        print('❌ Cred def not found');
        return VerificationResult(
          success: false,
          tier: VerificationTier.failed,
          message: 'Credential definition not found in trust bundle',
          details: {'cred_def_id': credDefId},
        );
      }

      print('✅ Cred def found');

      // 6. All checks passed
      print('🎉 All checks passed - BEST tier verification!');
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
    } catch (e, stackTrace) {
      print('❌ Verification error: $e');
      print('Stack trace: $stackTrace');
      return VerificationResult(
        success: false,
        tier: VerificationTier.failed,
        message: 'Verification error: $e',
      );
    }
  }
}
