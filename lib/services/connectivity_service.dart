import 'dart:async';
import 'package:http/http.dart' as http;

/// Service to detect ACA-Py server availability
///
/// This service monitors connectivity to the Traction ACA-Py server by
/// periodically checking the health endpoint. It's simpler and more reliable
/// than using connectivity_plus since we only care if ACA-Py is reachable.
class ConnectivityService {
  final String acaPyBaseUrl;

  // Stream to notify listeners of connectivity changes
  final _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  Timer? _serverCheckTimer;

  ConnectivityService(this.acaPyBaseUrl) {
    _initConnectivity();
    _startServerHealthCheck();
  }

  /// Initialize connectivity monitoring
  Future<void> _initConnectivity() async {
    // Check initial connectivity
    await _checkServerHealth();
  }

  /// Start periodic server health checks (every 30 seconds)
  void _startServerHealthCheck() {
    _serverCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkServerHealth(),
    );
  }

  /// Check if ACA-Py server is reachable and healthy
  Future<bool> _checkServerHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse('$acaPyBaseUrl/status/ready'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      final isHealthy = response.statusCode == 200;
      _setOnlineStatus(isHealthy);
      return isHealthy;
    } catch (e) {
      _setOnlineStatus(false);
      return false;
    }
  }

  /// Update online status and notify listeners
  void _setOnlineStatus(bool status) {
    if (_isOnline != status) {
      _isOnline = status;
      _connectivityController.add(status);
    }
  }

  /// Force check connectivity now
  Future<bool> checkConnectivity() async {
    await _checkServerHealth();
    return _isOnline;
  }

  /// Clean up resources
  void dispose() {
    _serverCheckTimer?.cancel();
    _connectivityController.close();
  }
}
