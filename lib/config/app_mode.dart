import 'package:shared_preferences/shared_preferences.dart';

/// Enum representing the three app modes
enum AppMode {
  holder('holder', 'Holder', 'Manage your credentials'),
  verifier('verifier', 'Verifier', 'Verify credentials from others'),
  hybrid('hybrid', 'Hybrid', 'Both holder and verifier');

  const AppMode(this.id, this.displayName, this.description);

  final String id;
  final String displayName;
  final String description;

  static AppMode fromId(String id) {
    return AppMode.values.firstWhere(
      (mode) => mode.id == id,
      orElse: () => AppMode.holder,
    );
  }
}

/// Configuration class for managing app mode
class AppModeConfig {
  static const String _modeKey = 'app_mode';
  static AppMode _currentMode = AppMode.holder;
  static bool _isInitialized = false;

  /// Get the current app mode
  static AppMode get current => _currentMode;

  /// Check if holder functionality is enabled
  static bool get isHolderEnabled =>
      _currentMode == AppMode.holder || _currentMode == AppMode.hybrid;

  /// Check if verifier functionality is enabled
  static bool get isVerifierEnabled =>
      _currentMode == AppMode.verifier || _currentMode == AppMode.hybrid;

  /// Initialize and load the saved mode from SharedPreferences
  static Future<void> loadMode() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedModeId = prefs.getString(_modeKey);

      if (savedModeId != null) {
        _currentMode = AppMode.fromId(savedModeId);
      }

      _isInitialized = true;
    } catch (e) {
      // If loading fails, use default mode
      _currentMode = AppMode.holder;
      _isInitialized = true;
    }
  }

  /// Set and persist the app mode
  static Future<void> setMode(AppMode mode) async {
    _currentMode = mode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_modeKey, mode.id);
    } catch (e) {
      // Handle error silently, mode is still set in memory
    }
  }

  /// Get a description of what features are available in current mode
  static String get currentModeDescription {
    switch (_currentMode) {
      case AppMode.holder:
        return 'Store and manage your credentials, present them when needed';
      case AppMode.verifier:
        return 'Scan and verify credentials from others';
      case AppMode.hybrid:
        return 'Full functionality: manage your credentials and verify others';
    }
  }
}
