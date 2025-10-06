import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Custom exceptions for better error handling
class AskarExportException implements Exception {
  final String message;
  final Object? originalError;
  final int? statusCode;

  AskarExportException(
    this.message, {
    this.originalError,
    this.statusCode,
  });

  @override
  String toString() {
    final status = statusCode != null ? ' (Status Code: $statusCode)' : '';
    if (originalError != null) {
      return 'AskarExportException: $message$status\n--- Original Error ---\n$originalError';
    }
    return 'AskarExportException: $message$status';
  }
}

class AskarExportClient {
  final String baseUrl;
  final http.Client _http;

  AskarExportClient(this.baseUrl, {http.Client? httpClient})
      : _http = httpClient ?? http.Client() {
    // Validate base URL format
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || (!uri.hasScheme || !uri.hasAuthority)) {
      throw ArgumentError('Invalid base URL: $baseUrl');
    }
  }

  /// Properly dispose of HTTP client resources
  void dispose() {
    _http.close();
  }

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    try {
      return Uri.parse(baseUrl).replace(
        path: '${Uri.parse(baseUrl).path}$path',
        queryParameters: queryParams,
      );
    } catch (e) {
      throw AskarExportException(
        'Invalid URL construction: $path',
        originalError: e,
      );
    }
  }

  /// Check server health with better error reporting
  Future<bool> healthz() async {
    try {
      final response = await _http
          .get(_buildUri('/healthz'))
          .timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } on SocketException catch (e) {
      debugPrint('--- AskarExportClient SocketException ---');
      debugPrint(e.toString());
      throw AskarExportException(
        'Network connection failed. Check server URL and connectivity.',
        originalError: e,
      );
    } on HttpException catch (e) {
      debugPrint('--- AskarExportClient HttpException ---');
      debugPrint(e.toString());
      throw AskarExportException(
        'HTTP error during health check: ${e.message}',
        originalError: e,
      );
    } on FormatException catch (e) {
      debugPrint('--- AskarExportClient FormatException ---');
      debugPrint(e.toString());
      throw AskarExportException(
        'Invalid server response format during health check',
        originalError: e,
      );
    } catch (e) {
      debugPrint('--- AskarExportClient Generic Exception ---');
      debugPrint(e.toString());
      throw AskarExportException(
        'Health check failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Downloads export with comprehensive error handling and validation
  Future<String> downloadExport({
    required String profile,
    bool pretty = false,
  }) async {
    // Input validation
    if (profile.trim().isEmpty) {
      throw AskarExportException('Profile name cannot be empty');
    }

    // Sanitize profile name (basic validation)
    final sanitizedProfile = profile.trim();
    if (sanitizedProfile.contains(RegExp(r'[<>:"/\\|?*]'))) {
      throw AskarExportException('Profile name contains invalid characters');
    }

    try {
      final response = await _http
          .get(
            _buildUri('/export', {
              'profile': sanitizedProfile,
              'pretty': pretty ? 'true' : 'false',
              'download': 'false', // we want inline body
            }),
          )
          .timeout(const Duration(seconds: 30));

      // Handle different HTTP status codes
      switch (response.statusCode) {
        case 200:
          break; // Success, continue processing
        case 404:
          throw AskarExportException(
            'Profile "$sanitizedProfile" not found',
            statusCode: 404,
          );
        case 401:
          throw AskarExportException(
            'Authentication required',
            statusCode: 401,
          );
        case 403:
          throw AskarExportException(
            'Access denied for profile "$sanitizedProfile"',
            statusCode: 403,
          );
        case 500:
          throw AskarExportException(
            'Server internal error. Please try again later.',
            statusCode: 500,
          );
        default:
          throw AskarExportException(
            'Export failed with status ${response.statusCode}: ${response.body}',
            statusCode: response.statusCode,
          );
      }

      // Validate response body is valid JSON
      try {
        final decodedJson = jsonDecode(response.body);

        // Basic validation that we have expected structure
        if (decodedJson is! Map<String, dynamic>) {
          throw AskarExportException(
            'Invalid export format: expected JSON object',
          );
        }

        return response.body;
      } on FormatException catch (e) {
        throw AskarExportException(
          'Server returned invalid JSON format',
          originalError: e,
        );
      }
    } on SocketException catch (e) {
      debugPrint('--- AskarExportClient SocketException ---');
      debugPrint(e.toString());
      throw AskarExportException(
        'Network connection failed during export download',
        originalError: e,
      );
    } on HttpException catch (e) {
      debugPrint('--- AskarExportClient HttpException ---');
      debugPrint(e.toString());
      throw AskarExportException(
        'HTTP error during export: ${e.message}',
        originalError: e,
      );
    } catch (e) {
      debugPrint('--- AskarExportClient Generic Exception ---');
      debugPrint(e.toString());
      if (e is AskarExportException) rethrow;
      throw AskarExportException(
        'Export download failed: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
