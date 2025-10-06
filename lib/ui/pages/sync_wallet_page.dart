import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../services/askar_export_client.dart';
import '../../services/askar_ffi.dart';
import '../../services/app_settings_provider.dart';

class SyncWalletPage extends StatefulWidget {
  const SyncWalletPage({super.key});

  @override
  State<SyncWalletPage> createState() => _SyncWalletPageState();
}

class _SyncWalletPageState extends State<SyncWalletPage> {
  final AskarFfi _askarFfi = AskarFfi();

  // Fixed wallet configuration
  static const String _walletName = 'synced_wallet';
  static const String _walletKey =
      '8HH5gYEeNc3z7PYXmd54d4x6qAfCNrqQqEB3nS7Zfu7K';

  final _serverCtrl = TextEditingController(
    text: 'http://mary9.com:9070',
  );
  final _profileCtrl = TextEditingController(
    text: 'c938ac8c-7e8f-4a99-bbf6-333559e79fb6',
  );
  final _formKey = GlobalKey<FormState>();

  bool _busy = false;
  bool _isHealthy = false;
  String _status = 'Ready to sync';
  int _totalCredentialsInWallet = 0;
  List<Map<String, dynamic>> _credentials = [];
  AskarExportClient? _client;

  @override
  void initState() {
    super.initState();
    _checkHealthOnStart();
    _loadWalletCredentialCount();
  }

  @override
  void dispose() {
    _serverCtrl.dispose();
    _profileCtrl.dispose();
    _client?.dispose();
    super.dispose();
  }

  Future<void> _checkHealthOnStart() async {
    await _checkHealth();
  }

  Future<void> _loadWalletCredentialCount() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final walletPath = '${dir.path}/$_walletName.db';
      final walletFile = File(walletPath);

      if (!walletFile.existsSync()) {
        setState(() {
          _totalCredentialsInWallet = 0;
          _credentials = [];
        });
        return;
      }

      // Get credential count
      final categoriesResult = _askarFfi.listCategories(
        dbPath: walletPath,
        rawKey: _walletKey,
      );

      // Get credential list
      final entriesResult = _askarFfi.listEntries(
        dbPath: walletPath,
        rawKey: _walletKey,
      );

      if (categoriesResult['success'] == true && entriesResult['success'] == true) {
        final categories = categoriesResult['categories'] as Map<String, dynamic>? ?? {};
        final credentialCount = categories['credential'] as int? ?? 0;
        
        final entries = entriesResult['entries'] as List? ?? [];
        final creds = entries
            .where((e) => e['category'] == 'credential')
            .map((e) => e as Map<String, dynamic>)
            .toList();
        
        setState(() {
          _totalCredentialsInWallet = credentialCount;
          _credentials = creds;
        });
      } else {
        setState(() {
          _totalCredentialsInWallet = 0;
          _credentials = [];
        });
      }
    } catch (e) {
      setState(() {
        _totalCredentialsInWallet = 0;
        _credentials = [];
      });
    }
  }

  void _setStatus(String s) => setState(() => _status = s);

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() => _profileCtrl.text = data!.text!);
    }
  }

  Future<void> _pasteServerUrl() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() => _serverCtrl.text = data!.text!);
    }
  }

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Server URL is required';
    }
    final trimmedValue = value.trim();
    final uri = Uri.tryParse(trimmedValue);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  String? _validateProfile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Profile ID is required';
    }
    return null;
  }

  Future<void> _checkHealth() async {
    if (_serverCtrl.text.trim().isEmpty) return;

    try {
      _client = AskarExportClient(_serverCtrl.text.trim());
      final isHealthy = await _client!.healthz();

      if (mounted) {
        setState(() {
          _isHealthy = isHealthy;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isHealthy = false;
        });
      }
    }
  }

  Future<void> _syncWallet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _busy = true;
      _status = 'Starting sync...';
    });

    try {
      // Step 1: Check server health
      _setStatus('Checking server health...');
      _client = AskarExportClient(_serverCtrl.text.trim());
      final isHealthy = await _client!.healthz();

      if (!isHealthy) {
        throw Exception('Server health check failed');
      }

      setState(() => _isHealthy = true);

      // Step 2: Download wallet export
      _setStatus('Downloading wallet data...');
      final profile = _profileCtrl.text.trim();
      final jsonData = await _client!.downloadExport(profile: profile);

      _setStatus('Processing data...');

      // Step 3: Save to temporary file
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${dir.path}/sync_temp_$timestamp.json');
      await tempFile.writeAsString(jsonData);

      // Step 4: Prepare wallet path
      _setStatus('Preparing wallet...');
      final walletPath = '${dir.path}/$_walletName.db';
      final walletFile = File(walletPath);

      // Step 5: Create/recreate wallet (clear old data by deleting and recreating)
      if (walletFile.existsSync()) {
        _setStatus('Clearing old wallet data...');
        try {
          await walletFile.delete();
        } catch (e) {
          throw Exception('Failed to clear old wallet: $e');
        }
      }

      _setStatus('Creating fresh wallet...');
      final provisionResult = _askarFfi.provisionWallet(
        dbPath: walletPath,
        rawKey: _walletKey,
      );

      if (provisionResult['success'] != true) {
        throw Exception('Failed to create wallet: ${provisionResult['error']}');
      }

      // Step 6: Import data to wallet
      _setStatus('Importing credentials...');
      final importResult = _askarFfi.importBulkEntries(
        dbPath: walletPath,
        rawKey: _walletKey,
        jsonData: jsonData,
      );

      if (importResult['success'] == true) {
        final failed = importResult['failed'] as int? ?? 0;

        setState(() {
          _status = '✅ Sync completed successfully' +
              (failed > 0 ? ' ($failed items failed)' : '');
        });

        // Reload total credential count
        await _loadWalletCredentialCount();

        // Clean up temp file
        try {
          await tempFile.delete();
        } catch (_) {}

        // Show success snackbar with actual credential count
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully synced $_totalCredentialsInWallet credentials!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Import failed: ${importResult['error']}');
      }
    } catch (e) {
      if (mounted) {
        _setStatus('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = Provider.of<AppSettingsProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Wallet'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Server health indicator
            Row(
              children: [
                const Text(
                  'Server Status:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: appSettings.airplaneMode 
                        ? Colors.orange 
                        : (_isHealthy ? Colors.green : Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appSettings.airplaneMode 
                        ? 'Offline' 
                        : (_isHealthy ? 'Online' : 'Checking...'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (!_busy)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _checkHealth,
                    tooltip: 'Recheck health',
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Server URL field with paste button
            Row(
              children: [
                Expanded(
                  child: const Text(
                    'Export Server URL',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _pasteServerUrl,
                  icon: const Icon(Icons.paste, size: 18),
                  label: const Text('Paste'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _serverCtrl,
              decoration: const InputDecoration(
                hintText: 'http://mary9.com:9070',
                border: OutlineInputBorder(),
              ),
              validator: _validateUrl,
              onChanged: (_) => _checkHealth(),
            ),

            const SizedBox(height: 16),

            // Profile ID field with paste button
            Row(
              children: [
                Expanded(
                  child: const Text(
                    'Profile ID',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.paste, size: 18),
                  label: const Text('Paste'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _profileCtrl,
              decoration: const InputDecoration(
                hintText: 'Enter profile identifier',
                border: OutlineInputBorder(),
              ),
              validator: _validateProfile,
            ),

            const SizedBox(height: 24),

            // Sync button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: (_busy || appSettings.airplaneMode) ? null : _syncWallet,
                icon: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync),
                label: Text(_busy ? 'Syncing...' : 'Sync Wallet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Wallet info card
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wallet Configuration',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Wallet Name', _walletName),
                    _buildInfoRow('Auto-created', 'Yes, if needed'),
                    _buildInfoRow(
                      'Total Credentials',
                      _totalCredentialsInWallet > 0
                          ? '$_totalCredentialsInWallet'
                          : 'None',
                    ),
                    
                    // Show credential list if there are credentials
                    if (_credentials.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Credentials:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._credentials.map((cred) {
                        // Extract schema name from credential value
                        String displayName = cred['name'] ?? 'Unnamed';
                        try {
                          if (cred['value'] != null) {
                            final credValue = jsonDecode(cred['value']) as Map<String, dynamic>;
                            final schemaId = credValue['schema_id'] as String?;
                            if (schemaId != null) {
                              // Extract schema name from schema_id format: did:2:name:version
                              final parts = schemaId.split(':');
                              if (parts.length >= 3) {
                                displayName = parts[2]; // Get the schema name
                              }
                            }
                          }
                        } catch (e) {
                          // If parsing fails, keep the default name
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ID: ${cred['name'] ?? 'Unknown'}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                    
                    const SizedBox(height: 8),
                    const Text(
                      'Tip: Use "Verify Local" to test your synced credentials.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
