import 'dart:convert';
import 'package:http/http.dart' as http;

class BundleClient {
  final http.Client _client;
  String _baseUrl;

  BundleClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? 'http://mary4.com:9090';

  String get baseUrl => _baseUrl;

  void setBaseUrl(String url) {
    // Basic validation to ensure it's a valid base URL format
    if (url.startsWith('http://') || url.startsWith('https://')) {
      _baseUrl = url;
    }
  }

  Future<Map<String, dynamic>> fetchBundle() async {
    final response = await _client.get(Uri.parse('$_baseUrl/bundle'));

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load bundle: ${response.statusCode}');
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/healthz'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
