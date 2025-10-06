import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global app settings provider
/// Manages app-wide settings like airplane mode (offline simulation)
class AppSettingsProvider extends ChangeNotifier {
  static const String _airplaneModeKey = 'airplane_mode';
  
  bool _airplaneMode = false;
  bool _isInitialized = false;

  /// Whether airplane mode is enabled (simulates offline)
  bool get airplaneMode => _airplaneMode;

  /// Whether the provider has been initialized from storage
  bool get isInitialized => _isInitialized;

  /// Initialize settings from persistent storage
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _airplaneMode = prefs.getBool(_airplaneModeKey) ?? false;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error loading app settings: $e');
      _isInitialized = true;
    }
  }

  /// Toggle airplane mode on/off
  Future<void> setAirplaneMode(bool enabled) async {
    if (_airplaneMode == enabled) return;
    
    _airplaneMode = enabled;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_airplaneModeKey, enabled);
      print('✈️ Airplane mode ${enabled ? "ENABLED" : "DISABLED"}');
    } catch (e) {
      print('Error saving airplane mode setting: $e');
    }
  }

  /// Check if network operations are allowed
  bool get isOnline => !_airplaneMode;

  /// Check if network operations are blocked
  bool get isOffline => _airplaneMode;
}
