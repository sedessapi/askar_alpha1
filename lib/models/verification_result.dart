import 'package:flutter/material.dart';

/// Status of an individual verification check
enum CheckStatus {
  passed, // Check passed successfully
  warning, // Check passed with warnings
  failed, // Check failed
  skipped, // Check was skipped (e.g., optional check, offline)
}

/// Overall status of credential verification
enum VerificationStatus {
  valid, // All critical checks passed
  warning, // Passed but with warnings
  invalid, // One or more critical checks failed
}

/// Individual verification check result
class VerificationCheck {
  final String category; // e.g., "Structure", "Dates", "Signature"
  final String name; // e.g., "Required Fields", "Expiration Date"
  final CheckStatus status;
  final String message; // Human-readable message
  final String? details; // Optional detailed information

  const VerificationCheck({
    required this.category,
    required this.name,
    required this.status,
    required this.message,
    this.details,
  });

  /// Get icon for check status
  String get icon {
    switch (status) {
      case CheckStatus.passed:
        return '✅';
      case CheckStatus.warning:
        return '⚠️';
      case CheckStatus.failed:
        return '❌';
      case CheckStatus.skipped:
        return '⏭️';
    }
  }

  /// Get color-coded status text
  String get statusText {
    switch (status) {
      case CheckStatus.passed:
        return 'Passed';
      case CheckStatus.warning:
        return 'Warning';
      case CheckStatus.failed:
        return 'Failed';
      case CheckStatus.skipped:
        return 'Skipped';
    }
  }
}

/// Complete verification result for a credential
class VerificationResult {
  final VerificationStatus overallStatus;
  final List<VerificationCheck> checks;
  final DateTime verifiedAt;
  final String? error; // Error message if verification couldn't complete

  const VerificationResult({
    required this.overallStatus,
    required this.checks,
    required this.verifiedAt,
    this.error,
  });

  /// Get summary statistics
  Map<String, int> get statistics {
    return {
      'passed': checks.where((c) => c.status == CheckStatus.passed).length,
      'warning': checks.where((c) => c.status == CheckStatus.warning).length,
      'failed': checks.where((c) => c.status == CheckStatus.failed).length,
      'skipped': checks.where((c) => c.status == CheckStatus.skipped).length,
      'total': checks.length,
    };
  }

  /// Get summary text
  String get summary {
    final stats = statistics;
    final parts = <String>[];

    if (stats['passed']! > 0) {
      parts.add('${stats['passed']} passed');
    }
    if (stats['warning']! > 0) {
      parts.add('${stats['warning']} warnings');
    }
    if (stats['failed']! > 0) {
      parts.add('${stats['failed']} failed');
    }
    if (stats['skipped']! > 0) {
      parts.add('${stats['skipped']} skipped');
    }

    return parts.join(', ');
  }

  /// Get overall status icon
  String get statusIcon {
    switch (overallStatus) {
      case VerificationStatus.valid:
        return '✅';
      case VerificationStatus.warning:
        return '⚠️';
      case VerificationStatus.invalid:
        return '❌';
    }
  }

  /// Get overall status icon as IconData
  IconData get statusIconData {
    switch (overallStatus) {
      case VerificationStatus.valid:
        return Icons.check_circle;
      case VerificationStatus.warning:
        return Icons.warning;
      case VerificationStatus.invalid:
        return Icons.cancel;
    }
  }

  /// Get overall status text
  String get statusText {
    switch (overallStatus) {
      case VerificationStatus.valid:
        return 'Valid';
      case VerificationStatus.warning:
        return 'Valid with Warnings';
      case VerificationStatus.invalid:
        return 'Invalid';
    }
  }

  /// Group checks by category
  Map<String, List<VerificationCheck>> get checksByCategory {
    final Map<String, List<VerificationCheck>> grouped = {};

    for (final check in checks) {
      grouped.putIfAbsent(check.category, () => []);
      grouped[check.category]!.add(check);
    }

    return grouped;
  }

  /// Create a failure result with error message
  factory VerificationResult.error(String errorMessage) {
    return VerificationResult(
      overallStatus: VerificationStatus.invalid,
      checks: [
        VerificationCheck(
          category: 'Error',
          name: 'Verification Failed',
          status: CheckStatus.failed,
          message: errorMessage,
        ),
      ],
      verifiedAt: DateTime.now(),
      error: errorMessage,
    );
  }

  /// Generate a text report of the verification
  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('Credential Verification Report');
    buffer.writeln('Generated: ${verifiedAt.toIso8601String()}');
    buffer.writeln('Status: $statusIcon $statusText');
    buffer.writeln('Summary: $summary');
    buffer.writeln();

    final grouped = checksByCategory;
    for (final category in grouped.keys) {
      buffer.writeln('$category:');
      for (final check in grouped[category]!) {
        buffer.writeln('  ${check.icon} ${check.name}: ${check.message}');
        if (check.details != null) {
          buffer.writeln('     ${check.details}');
        }
      }
      buffer.writeln();
    }

    return buffer.toString();
  }
}
