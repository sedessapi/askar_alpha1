import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JsonViewerPage extends StatefulWidget {
  final String filePath;
  final String jsonContent;

  const JsonViewerPage({
    super.key,
    required this.filePath,
    required this.jsonContent,
  });

  @override
  State<JsonViewerPage> createState() => _JsonViewerPageState();
}

class _JsonViewerPageState extends State<JsonViewerPage> {
  bool _showFormatted = true;
  bool _showSummary = true;
  Map<String, dynamic>? _parsedJson;
  String? _formattedJson;

  @override
  void initState() {
    super.initState();
    _parseJson();
  }

  void _parseJson() {
    try {
      _parsedJson = jsonDecode(widget.jsonContent) as Map<String, dynamic>;
      _formattedJson = const JsonEncoder.withIndent('  ').convert(_parsedJson);
    } catch (e) {
      // Handle parsing error
      _parsedJson = null;
      _formattedJson = null;
    }
  }

  Widget _buildSummary() {
    if (_parsedJson == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Error: Could not parse JSON content',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final categories = <String, int>{};
    int totalRecords = 0;

    _parsedJson!.forEach((key, value) {
      if (value is List) {
        categories[key] = value.length;
        totalRecords += value.length;
      } else if (value is Map) {
        categories[key] = 1;
        totalRecords += 1;
      } else {
        categories[key] = 0;
      }
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Text('Total Records: $totalRecords'),
                Text('Categories: ${categories.length}'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Category Breakdown:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            // Use a constrained container to prevent overflow
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categories.entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 4),
                          child: Text(
                            '${entry.key}: ${entry.value} items',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJsonContent() {
    final content = _showFormatted && _formattedJson != null
        ? _formattedJson!
        : widget.jsonContent;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'JSON Content',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('JSON copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy to clipboard',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  content,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.filePath.split('/').last;

    return Scaffold(
      appBar: AppBar(
        title: Text('View: $fileName', overflow: TextOverflow.ellipsis),
        actions: [
          if (_formattedJson != null)
            IconButton(
              onPressed: () {
                setState(() {
                  _showFormatted = !_showFormatted;
                });
              },
              icon: Icon(_showFormatted ? Icons.code_off : Icons.code),
              tooltip: _showFormatted ? 'Show raw JSON' : 'Show formatted JSON',
            ),
          IconButton(
            onPressed: () {
              setState(() {
                _showSummary = !_showSummary;
              });
            },
            icon: Icon(_showSummary ? Icons.visibility_off : Icons.visibility),
            tooltip: _showSummary ? 'Hide summary' : 'Show summary',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_showSummary) ...[
              // Use flexible instead of fixed padding to prevent overflow
              Flexible(
                flex: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildSummary(),
                ),
              ),
            ],
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildJsonContent(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final file = File(widget.filePath);
          if (file.existsSync()) {
            final size = file.lengthSync();
            final sizeKB = (size / 1024).toStringAsFixed(1);
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('File Information'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Path:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SelectableText(
                          widget.filePath,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Size: $sizeKB KB'),
                        const SizedBox(height: 8),
                        Text('Records: ${_parsedJson?.length ?? 'Unknown'}'),
                      ],
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
          }
        },
        icon: const Icon(Icons.info),
        label: const Text('File Info'),
      ),
    );
  }
}
