import 'dart:convert';
import '../models/verification_result.dart';

/// Service for verifying W3C Verifiable Credentials
class CredentialVerifier {
  /// Verify a credential from its JSON string or Map
  static Future<VerificationResult> verify(dynamic credentialData) async {
    final checks = <VerificationCheck>[];

    try {
      // Parse JSON - handle both String and Map inputs
      final Map<String, dynamic> credential;

      if (credentialData is Map<String, dynamic>) {
        // Already a Map, use directly
        credential = credentialData;
      } else if (credentialData is String) {
        // JSON string, parse it
        try {
          final parsed = jsonDecode(credentialData);
          if (parsed is Map<String, dynamic>) {
            credential = parsed;
          } else {
            return VerificationResult.error(
              'Invalid credential format: expected JSON object, got ${parsed.runtimeType}',
            );
          }
        } catch (e) {
          return VerificationResult.error('Invalid JSON: $e');
        }
      } else {
        return VerificationResult.error(
          'Invalid input type: expected String or Map, got ${credentialData.runtimeType}',
        );
      }

      // Detect data type
      final dataType = _detectDataType(credential);

      // Only verify if it's a credential or credential-like data
      if (dataType != 'credential' && dataType != 'verifiable-credential') {
        return VerificationResult(
          overallStatus: VerificationStatus.warning,
          checks: [
            VerificationCheck(
              category: 'Info',
              name: 'Data Type',
              status: CheckStatus.skipped,
              message: 'Not a Verifiable Credential',
              details: 'This appears to be: $dataType. Verification skipped.',
            ),
          ],
          verifiedAt: DateTime.now(),
        );
      }

      // Run all verification checks
      checks.addAll(await _checkStructure(credential));
      checks.addAll(await _checkDates(credential));
      checks.addAll(await _checkSignature(credential));
      checks.addAll(await _checkDIDs(credential));

      // Determine overall status
      final hasFailed = checks.any((c) => c.status == CheckStatus.failed);
      final hasWarning = checks.any((c) => c.status == CheckStatus.warning);

      final overallStatus = hasFailed
          ? VerificationStatus.invalid
          : (hasWarning
                ? VerificationStatus.warning
                : VerificationStatus.valid);

      return VerificationResult(
        overallStatus: overallStatus,
        checks: checks,
        verifiedAt: DateTime.now(),
      );
    } catch (e) {
      return VerificationResult.error('Verification error: $e');
    }
  }

  /// Check credential structure and required fields
  static Future<List<VerificationCheck>> _checkStructure(
    Map<String, dynamic> credential,
  ) async {
    final checks = <VerificationCheck>[];

    // Check @context
    if (credential.containsKey('@context')) {
      final context = credential['@context'];
      if (context is List && context.isNotEmpty) {
        checks.add(
          const VerificationCheck(
            category: 'Structure',
            name: '@context',
            status: CheckStatus.passed,
            message: '@context field present and valid',
          ),
        );
      } else {
        checks.add(
          const VerificationCheck(
            category: 'Structure',
            name: '@context',
            status: CheckStatus.warning,
            message: '@context must be a non-empty array',
          ),
        );
      }
    } else {
      checks.add(
        const VerificationCheck(
          category: 'Structure',
          name: '@context',
          status: CheckStatus.warning,
          message: '@context field missing (not W3C format)',
        ),
      );
    }

    // Check type
    if (credential.containsKey('type')) {
      final type = credential['type'];
      if (type is List) {
        final hasVC = type.contains('VerifiableCredential');
        checks.add(
          VerificationCheck(
            category: 'Structure',
            name: 'type',
            status: hasVC ? CheckStatus.passed : CheckStatus.warning,
            message: hasVC
                ? 'Contains VerifiableCredential type'
                : 'Missing VerifiableCredential type',
            details: 'Types: ${type.join(", ")}',
          ),
        );
      } else if (type is String) {
        checks.add(
          VerificationCheck(
            category: 'Structure',
            name: 'type',
            status: CheckStatus.warning,
            message: 'type should be an array',
            details: 'Type: $type',
          ),
        );
      } else {
        checks.add(
          const VerificationCheck(
            category: 'Structure',
            name: 'type',
            status: CheckStatus.warning,
            message: 'type field has unexpected format',
          ),
        );
      }
    } else {
      checks.add(
        const VerificationCheck(
          category: 'Structure',
          name: 'type',
          status: CheckStatus.warning,
          message: 'type field missing (not W3C format)',
        ),
      );
    }

    // Check credentialSubject
    if (credential.containsKey('credentialSubject')) {
      final subject = credential['credentialSubject'];
      if (subject is Map && subject.isNotEmpty) {
        checks.add(
          VerificationCheck(
            category: 'Structure',
            name: 'credentialSubject',
            status: CheckStatus.passed,
            message: 'Credential subject present',
            details: 'Contains ${subject.length} properties',
          ),
        );
      } else {
        checks.add(
          const VerificationCheck(
            category: 'Structure',
            name: 'credentialSubject',
            status: CheckStatus.warning,
            message: 'Credential subject is empty or invalid',
          ),
        );
      }
    } else {
      // Check for alternative credential formats (Indy/AnonCreds)
      if (credential.containsKey('values') || credential.containsKey('attrs')) {
        // AnonCreds format - check for required fields
        final hasSchemaId = credential.containsKey('schema_id');
        final hasCredDefId = credential.containsKey('cred_def_id');
        final hasSignature =
            credential.containsKey('signature') ||
            credential.containsKey('signature_correctness_proof');

        checks.add(
          VerificationCheck(
            category: 'Structure',
            name: 'credentialSubject',
            status: CheckStatus.passed,
            message: 'AnonCreds/Indy credential format detected',
            details:
                'Has values${hasSchemaId ? ", schema_id" : ""}${hasCredDefId ? ", cred_def_id" : ""}${hasSignature ? ", signature" : ""}',
          ),
        );

        // Additional AnonCreds structure checks
        if (!hasSchemaId) {
          checks.add(
            const VerificationCheck(
              category: 'Structure',
              name: 'schema_id',
              status: CheckStatus.warning,
              message: 'schema_id missing (optional for AnonCreds)',
            ),
          );
        }

        if (!hasCredDefId) {
          checks.add(
            const VerificationCheck(
              category: 'Structure',
              name: 'cred_def_id',
              status: CheckStatus.warning,
              message: 'cred_def_id missing (optional for AnonCreds)',
            ),
          );
        }
      } else {
        checks.add(
          const VerificationCheck(
            category: 'Structure',
            name: 'credentialSubject',
            status: CheckStatus.warning,
            message: 'credentialSubject field missing (not W3C format)',
          ),
        );
      }
    }

    // Check issuer
    if (credential.containsKey('issuer')) {
      final issuer = credential['issuer'];
      final issuerString = issuer is String
          ? issuer
          : (issuer is Map ? issuer['id'] : null);
      if (issuerString != null && issuerString.isNotEmpty) {
        checks.add(
          VerificationCheck(
            category: 'Structure',
            name: 'issuer',
            status: CheckStatus.passed,
            message: 'Issuer present',
            details: issuerString.length > 50
                ? '${issuerString.substring(0, 50)}...'
                : issuerString,
          ),
        );
      } else {
        checks.add(
          const VerificationCheck(
            category: 'Structure',
            name: 'issuer',
            status: CheckStatus.warning,
            message: 'Invalid issuer format',
          ),
        );
      }
    } else {
      checks.add(
        const VerificationCheck(
          category: 'Structure',
          name: 'issuer',
          status: CheckStatus.warning,
          message: 'issuer field missing (not W3C format)',
        ),
      );
    }

    // Check proof or signature
    final hasProof = credential.containsKey('proof');
    final hasSignature = credential.containsKey('signature');
    final hasSignatureCorrectnessProof = credential.containsKey(
      'signature_correctness_proof',
    );
    final hasWitness = credential.containsKey('witness');

    if (hasProof || hasSignature || hasSignatureCorrectnessProof) {
      final signatureType = hasProof
          ? 'W3C proof'
          : hasSignatureCorrectnessProof
          ? 'AnonCreds signature_correctness_proof'
          : 'Signature';

      checks.add(
        VerificationCheck(
          category: 'Structure',
          name: 'proof',
          status: CheckStatus.passed,
          message:
              '$signatureType present${hasWitness ? " (with witness)" : ""}',
        ),
      );
    } else {
      checks.add(
        const VerificationCheck(
          category: 'Structure',
          name: 'proof',
          status: CheckStatus.warning,
          message: 'proof field missing (not W3C format)',
        ),
      );
    }

    return checks;
  }

  /// Check dates (issuance, expiration)
  static Future<List<VerificationCheck>> _checkDates(
    Map<String, dynamic> credential,
  ) async {
    final checks = <VerificationCheck>[];
    final now = DateTime.now();

    // Check issuanceDate
    if (credential.containsKey('issuanceDate')) {
      try {
        final issuanceDateStr = credential['issuanceDate'] as String;
        final issuanceDate = DateTime.parse(issuanceDateStr);

        if (issuanceDate.isAfter(now)) {
          checks.add(
            VerificationCheck(
              category: 'Dates',
              name: 'issuanceDate',
              status: CheckStatus.failed,
              message: 'Issued in the future',
              details: 'Issuance date: ${_formatDate(issuanceDate)}',
            ),
          );
        } else {
          checks.add(
            VerificationCheck(
              category: 'Dates',
              name: 'issuanceDate',
              status: CheckStatus.passed,
              message: 'Valid issuance date',
              details: 'Issued on ${_formatDate(issuanceDate)}',
            ),
          );
        }
      } catch (e) {
        checks.add(
          VerificationCheck(
            category: 'Dates',
            name: 'issuanceDate',
            status: CheckStatus.failed,
            message: 'Invalid date format',
            details: e.toString(),
          ),
        );
      }
    } else {
      checks.add(
        const VerificationCheck(
          category: 'Dates',
          name: 'issuanceDate',
          status: CheckStatus.warning,
          message: 'issuanceDate field missing (optional)',
        ),
      );
    }

    // Check expirationDate
    if (credential.containsKey('expirationDate')) {
      try {
        final expirationDateStr = credential['expirationDate'] as String;
        final expirationDate = DateTime.parse(expirationDateStr);

        if (expirationDate.isBefore(now)) {
          checks.add(
            VerificationCheck(
              category: 'Dates',
              name: 'expirationDate',
              status: CheckStatus.failed,
              message: 'Credential has expired',
              details: 'Expired on ${_formatDate(expirationDate)}',
            ),
          );
        } else {
          final daysUntilExpiry = expirationDate.difference(now).inDays;
          final status = daysUntilExpiry <= 30
              ? CheckStatus.warning
              : CheckStatus.passed;
          final message = daysUntilExpiry <= 30
              ? 'Expires soon ($daysUntilExpiry days)'
              : 'Valid expiration date';

          checks.add(
            VerificationCheck(
              category: 'Dates',
              name: 'expirationDate',
              status: status,
              message: message,
              details: 'Expires on ${_formatDate(expirationDate)}',
            ),
          );
        }
      } catch (e) {
        checks.add(
          VerificationCheck(
            category: 'Dates',
            name: 'expirationDate',
            status: CheckStatus.failed,
            message: 'Invalid date format',
            details: e.toString(),
          ),
        );
      }
    } else {
      checks.add(
        const VerificationCheck(
          category: 'Dates',
          name: 'expirationDate',
          status: CheckStatus.passed,
          message: 'No expiration date (credential does not expire)',
        ),
      );
    }

    return checks;
  }

  /// Check signature/proof structure
  static Future<List<VerificationCheck>> _checkSignature(
    Map<String, dynamic> credential,
  ) async {
    final checks = <VerificationCheck>[];

    final proof = credential['proof'];
    if (proof == null) {
      checks.add(
        const VerificationCheck(
          category: 'Signature',
          name: 'Proof Structure',
          status: CheckStatus.skipped,
          message: 'No proof object to verify',
        ),
      );
      return checks;
    }

    if (proof is! Map) {
      checks.add(
        const VerificationCheck(
          category: 'Signature',
          name: 'Proof Structure',
          status: CheckStatus.failed,
          message: 'Proof must be an object',
        ),
      );
      return checks;
    }

    // Check required proof fields
    final requiredFields = [
      'type',
      'created',
      'proofPurpose',
      'verificationMethod',
    ];
    final missingFields = <String>[];

    for (final field in requiredFields) {
      if (!proof.containsKey(field) || proof[field] == null) {
        missingFields.add(field);
      }
    }

    if (missingFields.isEmpty) {
      checks.add(
        VerificationCheck(
          category: 'Signature',
          name: 'Proof Structure',
          status: CheckStatus.passed,
          message: 'Proof structure valid',
          details: 'Type: ${proof['type']}, Purpose: ${proof['proofPurpose']}',
        ),
      );
    } else {
      checks.add(
        VerificationCheck(
          category: 'Signature',
          name: 'Proof Structure',
          status: CheckStatus.failed,
          message: 'Missing proof fields',
          details: 'Missing: ${missingFields.join(", ")}',
        ),
      );
    }

    // Check for proofValue or signature
    if (proof.containsKey('proofValue') ||
        proof.containsKey('jws') ||
        proof.containsKey('signatureValue')) {
      checks.add(
        const VerificationCheck(
          category: 'Signature',
          name: 'Signature Data',
          status: CheckStatus.passed,
          message: 'Signature data present',
          details:
              'Note: Cryptographic verification requires public key resolution',
        ),
      );
    } else {
      checks.add(
        const VerificationCheck(
          category: 'Signature',
          name: 'Signature Data',
          status: CheckStatus.failed,
          message: 'No signature data found',
        ),
      );
    }

    return checks;
  }

  /// Check DID formats
  static Future<List<VerificationCheck>> _checkDIDs(
    Map<String, dynamic> credential,
  ) async {
    final checks = <VerificationCheck>[];

    // DID regex pattern
    final didPattern = RegExp(r'^did:[a-z0-9]+:[a-zA-Z0-9._%-]+$');

    // Check issuer DID
    final issuer = credential['issuer'];
    final issuerDID = issuer is String
        ? issuer
        : (issuer is Map ? issuer['id'] : null);

    if (issuerDID != null) {
      if (didPattern.hasMatch(issuerDID)) {
        checks.add(
          VerificationCheck(
            category: 'DIDs',
            name: 'Issuer DID',
            status: CheckStatus.passed,
            message: 'Issuer DID format valid',
            details: issuerDID.length > 50
                ? '${issuerDID.substring(0, 50)}...'
                : issuerDID,
          ),
        );
      } else {
        checks.add(
          VerificationCheck(
            category: 'DIDs',
            name: 'Issuer DID',
            status: CheckStatus.warning,
            message: 'Issuer is not a DID format',
            details: 'May be a URL or other identifier',
          ),
        );
      }
    }

    // Check credentialSubject.id DID
    final subject = credential['credentialSubject'];
    if (subject is Map && subject.containsKey('id')) {
      final subjectId = subject['id'] as String?;
      if (subjectId != null) {
        if (didPattern.hasMatch(subjectId)) {
          checks.add(
            VerificationCheck(
              category: 'DIDs',
              name: 'Subject DID',
              status: CheckStatus.passed,
              message: 'Subject DID format valid',
              details: subjectId.length > 50
                  ? '${subjectId.substring(0, 50)}...'
                  : subjectId,
            ),
          );
        } else {
          checks.add(
            const VerificationCheck(
              category: 'DIDs',
              name: 'Subject DID',
              status: CheckStatus.warning,
              message: 'Subject ID is not a DID format',
            ),
          );
        }
      }
    }

    // Check proof verificationMethod DID
    final proof = credential['proof'];
    if (proof is Map && proof.containsKey('verificationMethod')) {
      final verificationMethod = proof['verificationMethod'] as String?;
      if (verificationMethod != null) {
        // Verification method can be a full DID URL (did:...#key-1)
        final didUrlPattern = RegExp(
          r'^did:[a-z0-9]+:[a-zA-Z0-9._%-]+(?:#[a-zA-Z0-9._%-]+)?$',
        );
        if (didUrlPattern.hasMatch(verificationMethod)) {
          checks.add(
            VerificationCheck(
              category: 'DIDs',
              name: 'Verification Method',
              status: CheckStatus.passed,
              message: 'Verification method DID format valid',
              details: verificationMethod.length > 50
                  ? '${verificationMethod.substring(0, 50)}...'
                  : verificationMethod,
            ),
          );
        } else {
          checks.add(
            const VerificationCheck(
              category: 'DIDs',
              name: 'Verification Method',
              status: CheckStatus.warning,
              message: 'Verification method is not a DID format',
            ),
          );
        }
      }
    }

    return checks;
  }

  /// Format date for display
  static String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Detect the type of data stored
  static String _detectDataType(Map<String, dynamic> data) {
    // Check for Verifiable Credential markers
    if (data.containsKey('@context') && data.containsKey('type')) {
      final type = data['type'];
      if (type is List) {
        if (type.contains('VerifiableCredential')) {
          return 'verifiable-credential';
        }
      }
    }

    // Check for AnonCreds/Indy credential format
    // AnonCreds credentials have schema_id, cred_def_id, and values/signature
    if (data.containsKey('schema_id') && data.containsKey('cred_def_id')) {
      return 'credential';
    }

    // Check for raw Indy credential format (values + signature)
    if (data.containsKey('values') && data.containsKey('signature')) {
      return 'credential';
    }

    // Check for credential offer or request
    if (data.containsKey('cred_def_id') && !data.containsKey('values')) {
      return 'credential-offer-or-request';
    }

    // Check for connection record
    if (data.containsKey('connection_id') || data.containsKey('their_did')) {
      return 'connection';
    }

    // Check for schema
    if (data.containsKey('schema') && data.containsKey('version')) {
      return 'schema';
    }

    // Check for schema definition (different format)
    if (data.containsKey('attrNames') ||
        data.containsKey('name') && data.containsKey('ver')) {
      return 'schema';
    }

    // Check for credential definition
    if (data.containsKey('tag') || data.containsKey('primary')) {
      return 'credential-definition';
    }

    // Check for revocation registry
    if (data.containsKey('revocDefType') || data.containsKey('revocRegDefId')) {
      return 'revocation-registry';
    }

    // Check for DID document
    if (data.containsKey('did') || data.containsKey('verkey')) {
      return 'did-document';
    }

    // Check for raw Indy credential format
    if (data.containsKey('values') && data.containsKey('signature')) {
      return 'credential';
    }

    return 'unknown';
  }
}
