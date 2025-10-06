import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../services/askar_ffi.dart';
import '../../services/credential_verifier.dart';
import '../../models/verification_result.dart';

class CredentialsPage extends StatefulWidget {
  const CredentialsPage({super.key});

  @override
  State<CredentialsPage> createState() => _CredentialsPageState();
}

class _CredentialsPageState extends State<CredentialsPage> {
  final AskarFfi _askarFfi = AskarFfi();

  // Wallet management
  String? _walletPath;
  String? _walletKey;
  final TextEditingController _walletNameCtrl = TextEditingController(
    text: 'my_wallet',
  );
  final TextEditingController _walletKeyCtrl = TextEditingController(
    text: '8HH5gYEeNc3z7PYXmd54d4x6qAfCNrqQqEB3nS7Zfu7K',
  );

  // Import state
  String _status = 'Ready';
  bool _busy = false;
  List<File> _availableExports = [];
  File? _selectedExport;

  // Import results
  Map<String, dynamic>? _importResults;
  Map<String, dynamic>? _walletStats;

  @override
  void initState() {
    super.initState();
    _loadAvailableExports();
  }

  @override
  void dispose() {
    _walletNameCtrl.dispose();
    _walletKeyCtrl.dispose();
    super.dispose();
  }

  void _setStatus(String s) => setState(() => _status = s);

  Future<void> _loadAvailableExports() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = await dir
          .list()
          .where(
            (entity) => entity is File && entity.path.contains('askar_export_'),
          )
          .cast<File>()
          .toList();

      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      setState(() {
        _availableExports = files;
      });
    } catch (e) {
      _setStatus('Error loading exports: $e');
    }
  }

  Future<void> _createWallet() async {
    final walletName = _walletNameCtrl.text.trim();
    final walletKey = _walletKeyCtrl.text.trim();

    if (walletName.isEmpty) {
      _setStatus('Please enter a wallet name');
      return;
    }

    if (walletKey.isEmpty) {
      _setStatus('Please enter a wallet key');
      return;
    }

    setState(() {
      _busy = true;
      _importResults = null;
      _walletStats = null;
    });

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final walletPath = p.join(docsDir.path, '$walletName.db');

      _setStatus('Creating wallet...');

      final result = _askarFfi.provisionWallet(
        dbPath: walletPath,
        rawKey: walletKey,
      );

      if (result['success'] == true) {
        setState(() {
          _walletPath = walletPath;
          _walletKey = walletKey;
        });
        _setStatus('✓ Wallet created successfully at: $walletPath');
        await _loadWalletStats();
      } else {
        _setStatus('Error creating wallet: ${result['error']}');
      }
    } catch (e) {
      _setStatus('Exception: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _loadWalletStats() async {
    if (_walletPath == null || _walletKey == null) return;

    try {
      final result = _askarFfi.listCategories(
        dbPath: _walletPath!,
        rawKey: _walletKey!,
      );

      if (result['success'] == true) {
        setState(() {
          _walletStats = result;
        });
      }
    } catch (e) {
      debugPrint('Error loading wallet stats: $e');
    }
  }

  Future<void> _importSelectedFile() async {
    if (_selectedExport == null) {
      _setStatus('Please select an export file');
      return;
    }

    if (_walletPath == null || _walletKey == null) {
      _setStatus('Please create or open a wallet first');
      return;
    }

    setState(() {
      _busy = true;
      _importResults = null;
    });

    try {
      _setStatus('Reading export file...');
      final jsonContent = await _selectedExport!.readAsString();

      _setStatus('Importing entries into wallet...');
      final result = _askarFfi.importBulkEntries(
        dbPath: _walletPath!,
        rawKey: _walletKey!,
        jsonData: jsonContent,
      );

      if (result['success'] == true) {
        setState(() {
          _importResults = result;
        });
        _setStatus(
          '✓ Import complete: ${result['imported']} imported, ${result['failed']} failed',
        );
        await _loadWalletStats();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully imported ${result['imported']} entries!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        _setStatus('Import failed: ${result['error']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Import failed: ${result['error']}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      _setStatus('Exception during import: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _busy = false);
    }
  }

  Widget _buildWalletSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet),
                const SizedBox(width: 8),
                Text(
                  'Wallet Management',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _walletNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Wallet Name',
                hintText: 'my_wallet',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _walletKeyCtrl,
              decoration: const InputDecoration(
                labelText: 'Wallet Key (Base58)',
                hintText: '8HH5gYEeNc3z7PYXmd54d4x6qAfCNrqQqEB3nS7Zfu7K',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
                helperText: '32-byte key encoded as Base58',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy ? null : _createWallet,
              icon: const Icon(Icons.add_circle),
              label: const Text('Create New Wallet'),
            ),
            if (_walletPath != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✓ Wallet Active',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _walletPath!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_walletStats != null) ...[
              const SizedBox(height: 12),
              _buildWalletStatsCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWalletStatsCard() {
    final categories =
        _walletStats!['categories'] as Map<String, dynamic>? ?? {};
    final total = _walletStats!['total'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Wallet Contents',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: _showDetailedEntriesDialog,
                icon: const Icon(Icons.list_alt, size: 18),
                label: const Text('View All'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Total Entries: $total'),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Categories:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...categories.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(left: 12, top: 2),
                child: Text('• ${entry.key}: ${entry.value}'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showDetailedEntriesDialog() async {
    if (_walletPath == null || _walletKey == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No wallet loaded')));
      return;
    }

    setState(() {
      _busy = true;
      _status = 'Loading wallet entries...';
    });

    try {
      final result = _askarFfi.listEntries(
        dbPath: _walletPath!,
        rawKey: _walletKey!,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        final entries = result['entries'] as List? ?? [];

        showDialog(
          context: context,
          builder: (context) => _buildEntriesDialog(entries),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${result['error']}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load entries: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _status = 'Ready';
        });
      }
    }
  }

  Widget _buildEntriesDialog(List entries) {
    // Group entries by category
    final Map<String, List<Map<String, dynamic>>> groupedEntries = {};
    for (var entry in entries) {
      final category = entry['category'] ?? 'uncategorized';
      groupedEntries.putIfAbsent(category, () => []);
      groupedEntries[category]!.add(entry as Map<String, dynamic>);
    }

    // Sort categories with 'credential' first, then alphabetically
    final sortedCategories = groupedEntries.keys.toList()
      ..sort((a, b) {
        // Put 'credential' or 'credentials' at the top
        if (a.toLowerCase() == 'credential' ||
            a.toLowerCase() == 'credentials') {
          return -1;
        }
        if (b.toLowerCase() == 'credential' ||
            b.toLowerCase() == 'credentials') {
          return 1;
        }
        // Then sort alphabetically
        return a.toLowerCase().compareTo(b.toLowerCase());
      });

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_open,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Wallet Entries (${entries.length} total)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: entries.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No entries found in wallet',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: sortedCategories.map((category) {
                        final categoryEntries = groupedEntries[category]!;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ExpansionTile(
                            leading: Icon(
                              _getCategoryIcon(category),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(
                              category,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text('${categoryEntries.length} entries'),
                            initiallyExpanded: true,
                            children: categoryEntries.map((entry) {
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.key, size: 18),
                                title: Text(
                                  entry['name'] ?? 'Unnamed',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                subtitle: entry['value'] != null
                                    ? Text(
                                        'Value: ${_truncateValue(entry['value'])}',
                                        style: const TextStyle(fontSize: 12),
                                      )
                                    : null,
                                trailing: entry['tags'] != null &&
                                        (entry['tags'] as List).isNotEmpty
                                    ? Chip(
                                        label: Text(
                                          '${(entry['tags'] as List).length} tags',
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        visualDensity: VisualDensity.compact,
                                      )
                                    : null,
                                onTap: () =>
                                    _showEntryDetailsDialog(context, entry),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'credentials':
      case 'credential':
        return Icons.card_membership;
      case 'connections':
      case 'connection':
        return Icons.people;
      case 'dids':
      case 'did':
        return Icons.fingerprint;
      case 'schemas':
      case 'schema':
        return Icons.schema;
      case 'keys':
      case 'key':
        return Icons.vpn_key;
      default:
        return Icons.label;
    }
  }

  String _truncateValue(dynamic value) {
    final str = value.toString();
    if (str.length <= 50) return str;
    return '${str.substring(0, 47)}...';
  }

  void _showEntryDetailsDialog(
    BuildContext context,
    Map<String, dynamic> entry,
  ) {
    showDialog(
      context: context,
      builder: (context) => _EntryDetailsDialog(entry: entry),
    );
  }

  Widget _buildExportSelectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.file_download),
                const SizedBox(width: 8),
                Text(
                  'Select Export File',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: _loadAvailableExports,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh list',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_availableExports.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('No export files found. Download exports first.'),
                ),
              )
            else
              ..._availableExports.map((file) {
                final fileName = file.path.split(Platform.pathSeparator).last;
                final isSelected = _selectedExport?.path == file.path;

                return Card(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    leading: Icon(
                      Icons.insert_drive_file,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(fileName),
                    subtitle: Text(
                      'Modified: ${file.lastModifiedSync().toString().split('.')[0]}',
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedExport = file;
                      });
                      _setStatus('Selected: $fileName');
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildImportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.upload_file),
                const SizedBox(width: 8),
                Text(
                  'Import to Wallet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed:
                  (_busy || _walletPath == null || _selectedExport == null)
                      ? null
                      : _importSelectedFile,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(_busy ? 'Importing...' : 'Import Selected File'),
            ),
            if (_importResults != null) ...[
              const SizedBox(height: 16),
              _buildImportResultsCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImportResultsCard() {
    final imported = _importResults!['imported'] ?? 0;
    final failed = _importResults!['failed'] ?? 0;
    final categories =
        _importResults!['categories'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Import Results',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 8),
          Text('✓ Successfully imported: $imported entries'),
          if (failed > 0) Text('⚠ Failed: $failed entries'),
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'By Category:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            ...categories.entries.map((entry) {
              final stats = entry.value as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(left: 12, top: 2),
                child: Text(
                  '• ${entry.key}: ${stats['imported']} imported, ${stats['failed']} failed',
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import to Askar Wallet (Phase 2)')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWalletSection(),
            const SizedBox(height: 16),
            _buildExportSelectionSection(),
            const SizedBox(height: 16),
            _buildImportSection(),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: _status.contains('✓')
                          ? Colors.green
                          : (_status.contains('Error') ||
                                  _status.contains('fail'))
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Status: $_status',
                        style: TextStyle(
                          color: _status.contains('✓')
                              ? Colors.green
                              : (_status.contains('Error') ||
                                      _status.contains('fail'))
                                  ? Theme.of(context).colorScheme.error
                                  : null,
                        ),
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
}

// Dialog widget for displaying credential details and verification
class _EntryDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> entry;

  const _EntryDetailsDialog({required this.entry});

  @override
  State<_EntryDetailsDialog> createState() => _EntryDetailsDialogState();
}

class _EntryDetailsDialogState extends State<_EntryDetailsDialog> {
  VerificationResult? _verificationResult;
  bool _isVerifying = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _verifyCredential() async {
    setState(() {
      _isVerifying = true;
      _verificationResult = null;
    });

    try {
      final value = widget.entry['value'];
      if (value == null) {
        setState(() {
          _verificationResult = VerificationResult.error(
            'No credential data found',
          );
        });
        return;
      }

      final result = await CredentialVerifier.verify(value);
      setState(() {
        _verificationResult = result;
      });

      // Auto-scroll to results after a brief delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _verificationResult = VerificationResult.error('Failed to verify: $e');
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  Future<void> _copyJsonToClipboard() async {
    try {
      final value = widget.entry['value'];
      if (value == null) {
        _showSnackBar('No data to copy', isError: true);
        return;
      }

      String jsonString;
      if (value is String) {
        // Already a string, try to parse and pretty-print it
        try {
          final parsed = jsonDecode(value);
          jsonString = const JsonEncoder.withIndent('  ').convert(parsed);
        } catch (e) {
          // If parsing fails, use as-is
          jsonString = value;
        }
      } else if (value is Map || value is List) {
        // Convert to pretty JSON
        jsonString = const JsonEncoder.withIndent('  ').convert(value);
      } else {
        jsonString = value.toString();
      }

      await Clipboard.setData(ClipboardData(text: jsonString));
      _showSnackBar('JSON copied to clipboard!');
    } catch (e) {
      _showSnackBar('Failed to copy: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.entry['category'] ?? 'uncategorized';
    final name = widget.entry['name'] ?? 'Entry Details';

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(_getCategoryIcon(category)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 16)),
        ],
      ),
      content: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Category', widget.entry['category'] ?? 'N/A'),
            _buildDetailRow('Name', widget.entry['name'] ?? 'N/A'),
            const Divider(),
            const Text('Value:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                widget.entry['value']?.toString() ?? 'N/A',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            if (widget.entry['tags'] != null &&
                (widget.entry['tags'] as List).isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Tags:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (widget.entry['tags'] as List).map((tag) {
                  return Chip(
                    label: Text(
                      tag.toString(),
                      style: const TextStyle(fontSize: 11),
                    ),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: _isVerifying ? null : _verifyCredential,
                icon: _isVerifying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.verified_user),
                label: Text(
                  _isVerifying ? 'Verifying...' : 'Verify Credential',
                ),
              ),
            ),
            if (_verificationResult != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300, width: 2),
                    bottom: BorderSide(color: Colors.grey.shade300, width: 2),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'VERIFICATION RESULTS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildVerificationResults(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: _copyJsonToClipboard,
          icon: const Icon(Icons.copy),
          label: const Text('Copy JSON'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildVerificationResults() {
    final result = _verificationResult!;
    final stats = result.statistics;
    final hasCriticalIssues = stats['failed']! > 0;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _getStatusColor(result.overallStatus),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Prominent Overall Verdict
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _getStatusColor(result.overallStatus).withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  result.statusIconData,
                  color: _getStatusColor(result.overallStatus),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  result.statusText.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _getStatusColor(result.overallStatus),
                    fontSize: 24,
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      result.overallStatus,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getVerdictDescription(result.overallStatus),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: _getStatusColor(result.overallStatus),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (result.summary.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    result.summary,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Quick Summary Statistics
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(color: Colors.grey.shade50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatChip('✓', stats['passed']!, Colors.green),
                if (stats['warning']! > 0)
                  _buildStatChip('⚠', stats['warning']!, Colors.orange),
                if (stats['failed']! > 0)
                  _buildStatChip('✗', stats['failed']!, Colors.red),
                if (stats['skipped']! > 0)
                  _buildStatChip('○', stats['skipped']!, Colors.grey),
              ],
            ),
          ),
          // Critical Issues First (if any)
          if (hasCriticalIssues) ...[
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Critical Issues Found:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...result.checks
                      .where((c) => c.status == CheckStatus.failed)
                      .map(
                        (check) => Padding(
                          padding: const EdgeInsets.only(left: 28, top: 4),
                          child: Text(
                            '• ${check.name}: ${check.message}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade900,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
          // Collapsible Detailed Checks
          ExpansionTile(
            title: const Text(
              'View Detailed Checks',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            initiallyExpanded: false,
            children: result.checksByCategory.entries.map((categoryEntry) {
              return ExpansionTile(
                title: Text(
                  categoryEntry.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                tilePadding: const EdgeInsets.only(left: 32, right: 16),
                initiallyExpanded: false,
                children: categoryEntry.value.map((check) {
                  return ListTile(
                    dense: true,
                    leading: Text(
                      check.icon,
                      style: TextStyle(
                        fontSize: 20,
                        color: _getCheckStatusColor(check.status),
                      ),
                    ),
                    title: Text(check.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(check.message),
                        if (check.details != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            check.details!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String icon, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(color: color, fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.valid:
        return Colors.green;
      case VerificationStatus.warning:
        return Colors.orange;
      case VerificationStatus.invalid:
        return Colors.red;
    }
  }

  String _getVerdictDescription(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.valid:
        return '✓ Credential is structurally valid';
      case VerificationStatus.warning:
        return '⚠ Valid but has warnings';
      case VerificationStatus.invalid:
        return '✗ Credential has critical issues';
    }
  }

  Color _getCheckStatusColor(CheckStatus status) {
    switch (status) {
      case CheckStatus.passed:
        return Colors.green;
      case CheckStatus.warning:
        return Colors.orange;
      case CheckStatus.failed:
        return Colors.red;
      case CheckStatus.skipped:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'credentials':
      case 'credential':
        return Icons.card_membership;
      case 'connections':
      case 'connection':
        return Icons.people;
      case 'dids':
      case 'did':
        return Icons.fingerprint;
      case 'schemas':
      case 'schema':
        return Icons.schema;
      case 'keys':
      case 'key':
        return Icons.vpn_key;
      default:
        return Icons.label;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
