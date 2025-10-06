import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:trust_bundle_core/trust_bundle_core.dart';

class TrustBundleProvider with ChangeNotifier {
  final IngestionService _ingestionService;
  final DbService _dbService;
  final BundleClient _bundleClient;
  StreamSubscription<IngestionProgress>? _ingestionSubscription;

  TrustBundleProvider({
    required IngestionService ingestionService,
    required DbService dbService,
    required BundleClient bundleClient,
  })  : _ingestionService = ingestionService,
        _dbService = dbService,
        _bundleClient = bundleClient {
    _bundleUrl = _bundleClient.baseUrl;
  }

  DateTime? _lastSynced;
  int _schemaCount = 0;
  int _credDefCount = 0;
  bool _isLoading = false;
  bool? _isHealthy;
  late String _bundleUrl;

  String _progressMessage = '';
  double _progressValue = 0.0;

  // Bundle data for viewing
  Map<String, dynamic>? _bundleData;

  DateTime? get lastSynced => _lastSynced;
  int get schemaCount => _schemaCount;
  int get credDefCount => _credDefCount;
  bool get isLoading => _isLoading;
  bool? get isHealthy => _isHealthy;
  String get bundleUrl => _bundleUrl;
  String get progressMessage => _progressMessage;
  double get progressValue => _progressValue;
  Map<String, dynamic>? get bundleData => _bundleData;

  Map<String, dynamic>? _bundlePreview;
  Map<String, dynamic>? get bundlePreview => _bundlePreview;
  String? _previewError;
  String? get previewError => _previewError;
  Map<String, dynamic>? _rawBundle; // Store raw bundle for saving

  @override
  void dispose() {
    _ingestionSubscription?.cancel();
    super.dispose();
  }

  Future<void> checkHealth() async {
    _isLoading = true;
    notifyListeners();
    _isHealthy = await _bundleClient.checkHealth();
    _isLoading = false;
    notifyListeners();
  }

  void setBundleUrl(String url) {
    _bundleClient.setBaseUrl(url);
    _bundleUrl = _bundleClient.baseUrl;
    _isHealthy = null; // Reset health status when URL changes
    _bundlePreview = null; // Clear preview when URL changes
    _rawBundle = null; // Clear raw bundle when URL changes
    notifyListeners();
  }

  Future<void> previewBundle() async {
    _isLoading = true;
    _bundlePreview = null;
    _previewError = null;
    _rawBundle = null;
    notifyListeners();

    try {
      print('TrustBundleProvider: Starting preview bundle...');
      final previewData = await _ingestionService.previewBundle();
      _bundlePreview = previewData;
      _rawBundle =
          previewData['rawBundle'] as Map<String, dynamic>?; // Store raw bundle
      print('TrustBundleProvider: Preview successful - $_bundlePreview');
      _isHealthy = true;
    } catch (e) {
      print('TrustBundleProvider: Preview failed - $e');
      _isHealthy = false;
      _bundlePreview = null;
      _rawBundle = null;
      _previewError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncBundle() async {
    if (_rawBundle == null) {
      _previewError = 'Please preview the bundle first';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _isHealthy = null;
    _progressMessage = 'Starting save...';
    _progressValue = 0.0;
    notifyListeners();

    await _ingestionSubscription?.cancel();
    _ingestionSubscription =
        _ingestionService.savePreviewedBundle(_rawBundle!).listen(
      (progress) {
        _progressMessage = progress.message;
        if (progress.total > 0) {
          _progressValue = progress.current / progress.total;
        } else {
          _progressValue = 0;
        }

        if (progress.status == IngestionStatus.complete) {
          _isHealthy = true;
          _isLoading = false;
          _updateCounts(); // Refresh counts after successful save
        }
        notifyListeners();
      },
      onError: (error) {
        _progressMessage = 'Error: $error';
        _progressValue = 1.0; // Show full bar in red
        _isHealthy = false;
        _isLoading = false;
        notifyListeners();
      },
      onDone: () {
        if (_isLoading) {
          // This handles cases where the stream completes without an error or explicit complete status
          _isLoading = false;
          notifyListeners();
        }
      },
    );
  }

  /// Combined sync and save: downloads bundle and immediately saves to database
  Future<void> syncAndSaveBundle() async {
    _isLoading = true;
    _bundlePreview = null;
    _previewError = null;
    _rawBundle = null;
    _isHealthy = null;
    _progressMessage = 'Clearing old data...';
    _progressValue = 0.0;
    notifyListeners();

    try {
      // Clear all existing trust bundle data before syncing new bundle
      await _dbService.clearAllTrustBundleData();
      _progressMessage = 'Downloading bundle...';
      notifyListeners();
    } catch (e) {
      _progressMessage = 'Error clearing data: $e';
      _isHealthy = false;
      _isLoading = false;
      _previewError = e.toString();
      notifyListeners();
      return;
    }

    await _ingestionSubscription?.cancel();
    _ingestionSubscription = _ingestionService.ingestBundle().listen(
      (progress) {
        _progressMessage = progress.message;
        if (progress.total > 0) {
          _progressValue = progress.current / progress.total;
        } else {
          _progressValue = 0;
        }

        if (progress.status == IngestionStatus.complete) {
          _isHealthy = true;
          _isLoading = false;
          _updateCounts(); // Refresh counts after successful save
        }
        notifyListeners();
      },
      onError: (error) {
        _progressMessage = 'Error: $error';
        _progressValue = 1.0; // Show full bar in red
        _isHealthy = false;
        _isLoading = false;
        _previewError = error.toString();
        notifyListeners();
      },
      onDone: () {
        if (_isLoading) {
          _isLoading = false;
          notifyListeners();
        }
      },
    );
  }

  Future<void> _updateCounts() async {
    // Get the first bundle record to find the last sync time.
    final bundle = await _dbService.isar.bundleRecs.get(1);
    if (bundle != null) {
      _lastSynced = bundle.lastUpdated;
      // Parse and store bundle data for UI viewing
      try {
        _bundleData = json.decode(bundle.content);
      } catch (e) {
        print('Error parsing bundle content: $e');
        _bundleData = null;
      }
    }
    _schemaCount = await _dbService.isar.schemaRecs.count();
    _credDefCount = await _dbService.isar.credDefRecs.count();
    notifyListeners();
  }

  Future<void> loadInitialData() async {
    await _updateCounts();
  }
}
