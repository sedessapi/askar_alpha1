import 'dart:convert';
import 'package:http/http.dart' as http;

/// Client for interacting with Traction ACA-Py REST API
class AcaPyClient {
  final String baseUrl;
  final String? apiKey;
  final http.Client _http;

  AcaPyClient({required this.baseUrl, this.apiKey, http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  /// Build headers with optional API key
  Map<String, String> _headers() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (apiKey != null) {
      headers['X-API-Key'] = apiKey!;
    }

    return headers;
  }

  /// Check if ACA-Py is ready
  Future<bool> checkHealth() async {
    try {
      final response = await _http
          .get(Uri.parse('$baseUrl/status/ready'), headers: _headers())
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get wallet DID
  Future<Map<String, dynamic>> getPublicDid() async {
    final response = await _http.get(
      Uri.parse('$baseUrl/wallet/did/public'),
      headers: _headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get public DID: ${response.body}');
    }
  }

  /// Create an out-of-band invitation (for connections)
  Future<Map<String, dynamic>> createInvitation({
    String? alias,
    bool autoAccept = true,
  }) async {
    final body = {
      'handshake_protocols': ['https://didcomm.org/didexchange/1.0'],
      'use_public_did': false,
      if (alias != null) 'alias': alias,
    };

    final response = await _http.post(
      Uri.parse('$baseUrl/out-of-band/create-invitation'),
      headers: _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create invitation: ${response.body}');
    }
  }

  /// Receive an out-of-band invitation
  Future<Map<String, dynamic>> receiveInvitation({
    required Map<String, dynamic> invitation,
    bool autoAccept = true,
  }) async {
    final params = {'auto_accept': autoAccept.toString()};

    final uri = Uri.parse(
      '$baseUrl/out-of-band/receive-invitation',
    ).replace(queryParameters: params);

    final response = await _http.post(
      uri,
      headers: _headers(),
      body: jsonEncode(invitation),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to receive invitation: ${response.body}');
    }
  }

  /// Get all connections
  Future<List<Map<String, dynamic>>> getConnections({
    String? state,
    String? alias,
  }) async {
    final params = <String, String>{};
    if (state != null) params['state'] = state;
    if (alias != null) params['alias'] = alias;

    final uri = Uri.parse(
      '$baseUrl/connections',
    ).replace(queryParameters: params);

    final response = await _http.get(uri, headers: _headers());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['results'] ?? []);
    } else {
      throw Exception('Failed to get connections: ${response.body}');
    }
  }

  /// Get credentials from wallet
  Future<List<Map<String, dynamic>>> getCredentials({
    int? count,
    int? start,
    String? wql,
  }) async {
    final params = <String, String>{};
    if (count != null) params['count'] = count.toString();
    if (start != null) params['start'] = start.toString();
    if (wql != null) params['wql'] = wql;

    final uri = Uri.parse(
      '$baseUrl/credentials',
    ).replace(queryParameters: params);

    final response = await _http.get(uri, headers: _headers());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['results'] ?? []);
    } else {
      throw Exception('Failed to get credentials: ${response.body}');
    }
  }

  /// Send proof presentation (respond to proof request)
  Future<Map<String, dynamic>> sendProofPresentation({
    required String presentationExchangeId,
    required Map<String, dynamic> requestedCredentials,
    Map<String, dynamic>? selfAttestedAttributes,
  }) async {
    final body = {
      'requested_credentials': requestedCredentials,
      if (selfAttestedAttributes != null)
        'self_attested_attributes': selfAttestedAttributes,
    };

    final response = await _http.post(
      Uri.parse(
        '$baseUrl/present-proof-2.0/records/$presentationExchangeId/send-presentation',
      ),
      headers: _headers(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send presentation: ${response.body}');
    }
  }

  /// Get proof presentation records
  Future<List<Map<String, dynamic>>> getProofRecords({
    String? connectionId,
    String? state,
    String? threadId,
  }) async {
    final params = <String, String>{};
    if (connectionId != null) params['connection_id'] = connectionId;
    if (state != null) params['state'] = state;
    if (threadId != null) params['thread_id'] = threadId;

    final uri = Uri.parse(
      '$baseUrl/present-proof-2.0/records',
    ).replace(queryParameters: params);

    final response = await _http.get(uri, headers: _headers());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['results'] ?? []);
    } else {
      throw Exception('Failed to get proof records: ${response.body}');
    }
  }

  /// Get credentials for proof request
  Future<List<Map<String, dynamic>>> getCredentialsForProofRequest({
    required String presentationExchangeId,
    int? count,
    int? start,
  }) async {
    final params = <String, String>{};
    if (count != null) params['count'] = count.toString();
    if (start != null) params['start'] = start.toString();

    final uri = Uri.parse(
      '$baseUrl/present-proof-2.0/records/$presentationExchangeId/credentials',
    ).replace(queryParameters: params);

    final response = await _http.get(uri, headers: _headers());

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get credentials for proof: ${response.body}');
    }
  }

  /// Verify a credential (basic verification)
  Future<Map<String, dynamic>> verifyCredential({
    required Map<String, dynamic> credential,
  }) async {
    final response = await _http.post(
      Uri.parse('$baseUrl/credential/verify'),
      headers: _headers(),
      body: jsonEncode(credential),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to verify credential: ${response.body}');
    }
  }

  /// Clean up resources
  void dispose() {
    _http.close();
  }
}
