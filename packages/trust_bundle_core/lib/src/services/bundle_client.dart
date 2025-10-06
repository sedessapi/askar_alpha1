import 'dart:convert';
import 'package:http/http.dart' as http;

class BundleClient {
  final http.Client _client;
  final Uri _bundleUri;

  BundleClient({http.Client? client, Uri? bundleUri})
      : _client = client ?? http.Client(),
        _bundleUri = bundleUri ?? Uri.parse('http://mary9.com:9090/bundle');

  Future<Map<String, dynamic>> fetchBundle() async {
    final response = await _client.get(_bundleUri);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load bundle');
    }
  }
}
