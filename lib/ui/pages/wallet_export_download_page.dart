import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/askar_export_client.dart';
import 'json_viewer_page.dart';

/// Intent for paste action
class _PasteIntent extends Intent {
  const _PasteIntent();
}

class WalletExportDownloadPage extends StatefulWidget {
  const WalletExportDownloadPage({super.key});

  @override
  State<WalletExportDownloadPage> createState() =>
      _WalletExportDownloadPageState();
}

class _WalletExportDownloadPageState extends State<WalletExportDownloadPage> {
  final _serverCtrl = TextEditingController(
    text: 'http://mary9.com:9070',
  ); // Android emulator → host loopback
  final _profileCtrl = TextEditingController(
    text: 'c938ac8c-7e8f-4a99-bbf6-333559e79fb6',
  );
  final _formKey = GlobalKey<FormState>();

  bool _busy = false;
  String _status = 'Ready';
  String? _savedPath;
  int _categoryCount = 0;
  int _recordCount = 0;
  AskarExportClient? _client;

  @override
  void dispose() {
    _serverCtrl.dispose();
    _profileCtrl.dispose();
    _client?.dispose();
    super.dispose();
  }

  /// Validates URL format
  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Server URL is required';
    }

    final trimmedValue = value.trim();
    final uri = Uri.tryParse(trimmedValue);

    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Please enter a valid URL (e.g., http://mary9.com:9070)';
    }

    if (!['http', 'https'].contains(uri.scheme.toLowerCase())) {
      return 'URL must use http or https protocol';
    }

    return null;
  }

  /// Validates profile name
  String? _validateProfile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Profile name is required';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'Profile name must be at least 2 characters';
    }

    if (trimmedValue.contains(RegExp(r'[<>:"/\\|?*]'))) {
      return 'Profile name contains invalid characters';
    }

    return null;
  }

  /// Creates or reuses HTTP client
  AskarExportClient _getClient() {
    final serverUrl = _serverCtrl.text.trim();
    if (_client == null || _client!.baseUrl != serverUrl) {
      _client?.dispose();
      _client = AskarExportClient(serverUrl);
    }
    return _client!;
  }

  void _setStatus(String s) => setState(() => _status = s);

  /// Paste content from clipboard into profile field
  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
        _profileCtrl.text = clipboardData.text!.trim();
        _setStatus('Pasted profile name from clipboard');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile name pasted from clipboard'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clipboard is empty or contains no text'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to paste from clipboard: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Paste content from clipboard into server URL field
  Future<void> _pasteServerUrl() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
        _serverCtrl.text = clipboardData.text!.trim();
        _setStatus('Pasted server URL from clipboard');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Server URL pasted from clipboard'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clipboard is empty or contains no text'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to paste from clipboard: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Opens a viewer to display the JSON file contents
  Future<void> _viewFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File no longer exists'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final content = await file.readAsString();
      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              JsonViewerPage(filePath: filePath, jsonContent: content),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reading file: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _checkHealth() async {
    // Validate input first
    if (_validateUrl(_serverCtrl.text) != null) {
      _setStatus('Please enter a valid server URL');
      return;
    }

    setState(() {
      _busy = true;
      _savedPath = null;
      _categoryCount = 0;
      _recordCount = 0;
    });

    try {
      final client = _getClient();
      final isHealthy = await client.healthz();
      _setStatus(isHealthy ? 'Server healthy ✓' : 'Server not responding');
    } on AskarExportException catch (e) {
      _setStatus('Health check failed: ${e.message}');
    } catch (e) {
      _setStatus('Health check error: ${e.toString()}');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _download() async {
    // Validate inputs first
    final urlError = _validateUrl(_serverCtrl.text);
    final profileError = _validateProfile(_profileCtrl.text);

    if (urlError != null) {
      _setStatus('Server URL: $urlError');
      return;
    }

    if (profileError != null) {
      _setStatus('Profile: $profileError');
      return;
    }

    final profile = _profileCtrl.text.trim();

    setState(() {
      _busy = true;
      _savedPath = null;
      _categoryCount = 0;
      _recordCount = 0;
    });

    try {
      final client = _getClient();
      _setStatus('Downloading export for "$profile"...');
      final body = await client.downloadExport(profile: profile, pretty: false);

      // Compute quick summary (categories & total items)
      final map = jsonDecode(body) as Map<String, dynamic>;
      int cats = 0;
      int items = 0;
      map.forEach((k, v) {
        cats++;
        if (v is List) items += v.length;
      });
      _categoryCount = cats;
      _recordCount = items;

      // Save to app documents dir with improved file naming
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now()
          .toUtc()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')[0];
      final sanitizedProfile = profile.replaceAll(RegExp(r'[^\w\-_]'), '_');
      final filename = 'askar_export_${sanitizedProfile}_$timestamp.json';
      final file = File('${dir.path}/$filename');

      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(map));
      _savedPath = file.path;

      _setStatus(
        'Download complete ✓: $_recordCount records in $_categoryCount categories',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to $filename'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Copy Path',
              onPressed: () {
                // Could implement clipboard copy here
              },
            ),
          ),
        );
      }
    } on AskarExportException catch (e) {
      final errorMessage = 'Export failed: ${e.message}';
      _setStatus(errorMessage);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      final errorMessage = 'Download failed: ${e.toString()}';
      _setStatus(errorMessage);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() => _busy = false);
    }
  }

  /// Shows a list of all saved export files
  Future<void> _showSavedFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = await dir
          .list()
          .where(
            (entity) => entity is File && entity.path.contains('askar_export_'),
          )
          .cast<File>()
          .toList();

      if (files.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No saved export files found')),
          );
        }
        return;
      }

      // Sort by modification date (newest first)
      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Saved Export Files'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  final fileName = file.path.split('/').last;
                  final modifiedDate = file.lastModifiedSync();

                  return ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(fileName),
                    subtitle: Text(
                      'Modified: ${modifiedDate.toString().split('.')[0]}',
                    ),
                    onTap: () {
                      Navigator.of(context).pop(); // Close dialog
                      _viewFile(file.path);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete File'),
                            content: Text('Delete $fileName?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await file.delete();
                          if (context.mounted) {
                            Navigator.of(context).pop(); // Close main dialog
                            _showSavedFiles(); // Refresh the list
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading files: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor =
        _status.toLowerCase().contains('error') ||
            _status.toLowerCase().contains('fail')
        ? Theme.of(context).colorScheme.error
        : (_status.toLowerCase().contains('complete')
              ? Colors.green
              : Theme.of(context).colorScheme.outline);

    return Scaffold(
      appBar: AppBar(title: const Text('Download Askar Export (Phase 1)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Server URL',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: _pasteServerUrl,
                            icon: const Icon(Icons.content_paste, size: 16),
                            label: const Text('Paste'),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _serverCtrl.clear(),
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('Clear'),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _serverCtrl,
                    validator: _validateUrl,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'http://mary9.com:9070',
                      prefixIcon: Icon(Icons.link),
                      helperText:
                          'Enter the server URL with protocol (http/https)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Profile (sub-wallet) name',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: _pasteFromClipboard,
                            icon: const Icon(Icons.content_paste, size: 16),
                            label: const Text('Paste'),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _profileCtrl.clear(),
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('Clear'),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Shortcuts(
                    shortcuts: <LogicalKeySet, Intent>{
                      LogicalKeySet(
                        LogicalKeyboardKey.meta,
                        LogicalKeyboardKey.keyV,
                      ): const _PasteIntent(),
                    },
                    child: Actions(
                      actions: <Type, Action<Intent>>{
                        _PasteIntent: CallbackAction<_PasteIntent>(
                          onInvoke: (_PasteIntent intent) =>
                              _pasteFromClipboard(),
                        ),
                      },
                      child: TextFormField(
                        controller: _profileCtrl,
                        validator: _validateProfile,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'tenant_1',
                          prefixIcon: Icon(Icons.account_balance_wallet),
                          helperText:
                              'Enter the profile/tenant name to export (⌘+V to paste)',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: _busy ? null : _checkHealth,
                  icon: const Icon(Icons.monitor_heart),
                  label: const Text('Check Health'),
                ),
                FilledButton.icon(
                  onPressed: _busy ? null : _download,
                  icon: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: Text(
                    _busy ? 'Downloading...' : 'Download Export JSON',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info, color: statusColor),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Status: $_status')),
                  ],
                ),
              ),
            ),
            if (_savedPath != null) ...[
              const SizedBox(height: 8),
              SelectableText(
                'Saved file: $_savedPath',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _viewFile(_savedPath!),
                icon: const Icon(Icons.visibility),
                label: const Text('View File Contents'),
              ),
            ],
            if (_recordCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Summary: $_recordCount records across $_categoryCount categories',
              ),
            ],
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Saved Files',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showSavedFiles,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('View All Files'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Next step (Phase 2): Import JSON into an on-device Askar wallet.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'In the next iteration, we will:\n'
              '• Create/Unlock a local Askar wallet\n'
              '• Map categories to wallet records\n'
              '• Import keys/records into the device wallet (secure storage)\n'
              '• Optionally re-encrypt with a device-held passphrase',
            ),
          ],
        ),
      ),
    );
  }
}
