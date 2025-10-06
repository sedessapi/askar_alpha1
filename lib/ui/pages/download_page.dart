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

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final _serverCtrl = TextEditingController(
    text: 'http://mary9.com:9070',
  );
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

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Server URL is required';
    }
    final trimmedValue = value.trim();
    final uri = Uri.tryParse(trimmedValue);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Please enter a valid URL (e.g., http://example.com:9070)';
    }
    return null;
  }

  String? _validateProfile(String? value) {
    if (value == null) return null;
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) return null;

    final serverUrl = _serverCtrl.text.trim();
    if (serverUrl.isEmpty) {
      return 'Please fill in the Server URL first';
    }
    return null;
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

  Future<void> _checkHealth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _busy = true;
      _status = 'Checking server health...';
    });

    try {
      _client = AskarExportClient(_serverCtrl.text.trim());
      final isHealthy = await _client!.healthz();

      if (mounted) {
        _setStatus(
          isHealthy
              ? '✓ Server is healthy and responding'
              : 'Server responded but health check failed',
        );
      }
    } catch (e) {
      if (mounted) _setStatus('Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _download() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _busy = true;
      _status = 'Connecting to server...';
      _savedPath = null;
      _categoryCount = 0;
      _recordCount = 0;
    });

    try {
      _client = AskarExportClient(_serverCtrl.text.trim());
      final profile = _profileCtrl.text.trim();

      // Profile is required by the server
      if (profile.isEmpty) {
        throw Exception('Profile name is required');
      }

      _setStatus('Downloading export data...');
      final jsonData = await _client!.downloadExport(profile: profile);

      _setStatus('Processing JSON data...');
      final jsonMap = json.decode(jsonData) as Map<String, dynamic>;
      final categories = <String>{};
      var recordCount = 0;

      if (jsonMap.containsKey('entries')) {
        final entries = jsonMap['entries'] as List;
        for (final entry in entries) {
          if (entry is Map && entry.containsKey('category')) {
            categories.add(entry['category'] as String);
          }
        }
        recordCount = entries.length;
      }

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'askar_export_$timestamp.json';
      final file = File('${dir.path}/$fileName');

      _setStatus('Saving to disk...');
      await file.writeAsString(jsonData);

      if (mounted) {
        setState(() {
          _savedPath = file.path;
          _categoryCount = categories.length;
          _recordCount = recordCount;
          _status = '✓ Download complete!';
        });
      }
    } catch (e) {
      if (mounted) _setStatus('Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _viewFile(String path) async {
    try {
      final file = File(path);
      final contents = await file.readAsString();

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JsonViewerPage(
              filePath: path,
              jsonContent: contents,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reading file: $e')),
        );
      }
    }
  }

  Future<void> _showSavedFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) =>
              f.path.endsWith('.json') && f.path.contains('askar_export'))
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path));

      if (!mounted) return;

      if (files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No saved export files found')),
        );
        return;
      }

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

                return ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(fileName),
                  subtitle: Text(
                      '${(file.lengthSync() / 1024).toStringAsFixed(1)} KB'),
                  onTap: () {
                    Navigator.pop(context);
                    _viewFile(file.path);
                  },
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _status.toLowerCase().contains('error') ||
            _status.toLowerCase().contains('fail')
        ? Theme.of(context).colorScheme.error
        : (_status.toLowerCase().contains('complete') ||
                _status.toLowerCase().contains('✓'))
            ? Colors.green
            : Theme.of(context).colorScheme.outline;

    return Scaffold(
      appBar: AppBar(title: const Text('Download Askar Export')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Form(
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
                      onInvoke: (_) => _pasteServerUrl(),
                    ),
                  },
                  child: TextFormField(
                    controller: _serverCtrl,
                    validator: _validateUrl,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'http://example.com:9070',
                      prefixIcon: Icon(Icons.cloud),
                      helperText:
                          'Enter the Askar export server URL (⌘+V to paste)',
                    ),
                  ),
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
                      onInvoke: (_) => _pasteFromClipboard(),
                    ),
                  },
                  child: TextFormField(
                    controller: _profileCtrl,
                    validator: _validateProfile,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'tenant_1 (optional)',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                      helperText:
                          'Enter the profile/tenant name to export (⌘+V to paste)',
                    ),
                  ),
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
                    label:
                        Text(_busy ? 'Downloading...' : 'Download Export JSON'),
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
            ],
          ),
        ),
      ),
    );
  }
}
