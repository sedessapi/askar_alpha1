import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/askar_ffi.dart';
import '../../services/enhanced_verification_service.dart';
import '../../services/app_settings_provider.dart';

class VerifyLocalPage extends StatefulWidget {
  const VerifyLocalPage({super.key});

  @override
  State<VerifyLocalPage> createState() => _VerifyLocalPageState();
}

class _VerifyLocalPageState extends State<VerifyLocalPage> {
  final AskarFfi _askarFfi = AskarFfi();

  bool _isLoading = false;
  bool _walletOpen = false;
  List<Map<String, dynamic>> _credentials = [];
  Map<String, EnhancedVerificationResult?> _verificationResults = {};

  String? _walletPath;
  final TextEditingController _walletNameCtrl = TextEditingController(
    text: 'synced_wallet',
  );
  final TextEditingController _walletKeyCtrl = TextEditingController(
    text: '8HH5gYEeNc3z7PYXmd54d4x6qAfCNrqQqEB3nS7Zfu7K',
  );

  @override
  void dispose() {
    _walletNameCtrl.dispose();
    _walletKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _openWallet() async {
    final walletName = _walletNameCtrl.text.trim();
    final walletKey = _walletKeyCtrl.text.trim();

    if (walletName.isEmpty || walletKey.isEmpty) {
      _showSnackBar('Please enter wallet name and key');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get documents directory and construct wallet path
      final docsDir = await getApplicationDocumentsDirectory();
      final dbPath = '${docsDir.path}/$walletName.db';

      // Check if wallet exists
      if (!File(dbPath).existsSync()) {
        _showSnackBar(
            'Wallet not found. Please create or import a wallet first.');
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _walletPath = dbPath;
        _walletOpen = true;
      });
      await _loadCredentials();
      _showSnackBar('Wallet opened successfully');
    } catch (e) {
      _showSnackBar('Error opening wallet: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCredentials() async {
    if (_walletPath == null) return;

    setState(() => _isLoading = true);

    try {
      final walletKey = _walletKeyCtrl.text.trim();
      final result = _askarFfi.listEntries(
        dbPath: _walletPath!,
        rawKey: walletKey,
      );

      if (result['success'] == true) {
        final entries = result['entries'] as List<dynamic>? ?? [];
        // Filter to only credential entries
        final credEntries = entries
            .where((e) => e['category'] == 'credential')
            .map((e) => e as Map<String, dynamic>)
            .toList();

        setState(() {
          _credentials = credEntries;
          _verificationResults.clear();
        });
      } else {
        _showSnackBar('Error: ${result['error']}');
      }
    } catch (e) {
      _showSnackBar('Error loading credentials: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCredential(
      String credentialId, Map<String, dynamic> credential) async {
    if (_walletPath == null) return;

    setState(() => _isLoading = true);

    try {
      final enhancedService =
          Provider.of<EnhancedVerificationService>(context, listen: false);
      final appSettings =
          Provider.of<AppSettingsProvider>(context, listen: false);

      // Get the credential value
      final credValue = credential['value'];
      Map<String, dynamic> credentialData;

      if (credValue is String) {
        credentialData = jsonDecode(credValue) as Map<String, dynamic>;
      } else if (credValue is Map) {
        credentialData = credValue as Map<String, dynamic>;
      } else {
        _showSnackBar('Invalid credential format');
        return;
      }

      // Run enhanced verification with airplane mode flag
      final result = await enhancedService.verifyCredential(
        credentialData,
        isOffline: appSettings.airplaneMode,
      );

      setState(() {
        _verificationResults[credentialId] = result;
      });

      _showSnackBar('Verification complete: ${result.tier}');
    } catch (e) {
      _showSnackBar('Error verifying credential: $e');
      setState(() {
        _verificationResults[credentialId] = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Local'),
        actions: [
          if (_walletOpen)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload Credentials',
              onPressed: _isLoading ? null : _loadCredentials,
            ),
        ],
      ),
      body: _walletOpen ? _buildCredentialsList() : _buildWalletForm(),
    );
  }

  Widget _buildWalletForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Open Wallet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _walletNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Wallet Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _walletKeyCtrl,
            decoration: const InputDecoration(
              labelText: 'Wallet Key',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _openWallet,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.lock_open),
            label: Text(_isLoading ? 'Opening...' : 'Open Wallet'),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsList() {
    if (_isLoading && _credentials.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_credentials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No credentials found in wallet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _credentials.length,
      itemBuilder: (context, index) {
        final cred = _credentials[index];
        final credId = cred['name'] as String? ?? 'credential_$index';
        final verificationResult = _verificationResults[credId];

        return _buildCredentialCard(credId, cred, verificationResult);
      },
    );
  }

  Widget _buildCredentialCard(
    String credentialId,
    Map<String, dynamic> credential,
    EnhancedVerificationResult? verificationResult,
  ) {
    // Parse credential data
    final name = credential['name'] as String? ?? 'Unknown';
    final category = credential['category'] as String? ?? 'credential';

    // Try to extract credential attributes for display
    Map<String, dynamic>? attributes;
    try {
      final value = credential['value'];
      if (value is String) {
        attributes = jsonDecode(value) as Map<String, dynamic>?;
      } else if (value is Map) {
        attributes = value as Map<String, dynamic>;
      }
    } catch (_) {
      // Ignore parsing errors
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getCategoryIcon(category),
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Show verification result if available
            if (verificationResult != null) ...[
              const SizedBox(height: 16),
              _buildVerificationResult(verificationResult),
            ],

            // Show some attributes if available
            if (attributes != null && attributes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              ...attributes.entries.take(3).map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          '${entry.key}:',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],

            const SizedBox(height: 16),

            // Verify button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () => _verifyCredential(credentialId, credential),
                icon: const Icon(Icons.verified_user),
                label: const Text('Verify'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationResult(EnhancedVerificationResult result) {
    // Parse hex color string to Color
    final colorValue =
        int.parse(result.tierColor.replaceFirst('#', ''), radix: 16);
    final color = Color(0xFF000000 | colorValue);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildTierBadge(result.tier, color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result.tierDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Icon(
                result.success ? Icons.check_circle : Icons.error,
                color: result.success ? Colors.green : Colors.red,
              ),
            ],
          ),
          if (result.details != null && result.details!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...result.details!.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4),
                child: Text(
                  '• ${entry.key}: ${entry.value}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildTierBadge(String tier, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tier,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'credential':
        return Icons.badge;
      case 'key':
        return Icons.vpn_key;
      case 'config':
        return Icons.settings;
      default:
        return Icons.description;
    }
  }
}
