// lib/ui/pages/json_viewer_page.dart
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

  Map<String, dynamic>? _root; // parsed JSON root
  String? _formattedJson;

  // --- Generic totals ---
  int _totalRecords = 0;
  final Map<String, int> _countsByCategory = {}; // all records per category
  final Map<String, Set<String>> _tagKeysByCategory = {};

  // --- Credentials-focused metrics (from a single chosen category) ---
  String? _primaryCredCategory; // e.g., "credential"
  int _totalCredentials = 0;
  final Set<String> _allSchemaIds = {};
  final Set<String> _allCredDefIds = {};

  static const _prefCredCats = <String>{
    'credential',
    'credentials',
    'anoncreds/credential',
    'acapy::credential',
  };

  @override
  void initState() {
    super.initState();
    _parseAndSummarize();
  }

  void _parseAndSummarize() {
    try {
      _root = jsonDecode(widget.jsonContent) as Map<String, dynamic>;
      _formattedJson = const JsonEncoder.withIndent('  ').convert(_root);

      // Reset summaries
      _totalRecords = 0;
      _countsByCategory.clear();
      _tagKeysByCategory.clear();

      _primaryCredCategory = null;
      _totalCredentials = 0;
      _allSchemaIds.clear();
      _allCredDefIds.clear();

      // Expect structure: { "<category>": [ { name, value, tags }, ... ], ... }
      _root!.forEach((category, items) {
        int categoryAllCount = 0;
        final tagKeys = <String>{};

        void processRow(Map<String, dynamic> row) {
          categoryAllCount++;

          final tags = row['tags'];
          if (tags is Map) {
            for (final k in tags.keys) {
              tagKeys.add(k.toString());
            }
          }
        }

        if (items is List) {
          for (final row in items) {
            if (row is Map<String, dynamic>) processRow(row);
          }
        } else if (items is Map<String, dynamic>) {
          processRow(items);
        }

        _countsByCategory[category] = categoryAllCount;
        _tagKeysByCategory[category] = tagKeys;
        _totalRecords += categoryAllCount;
      });

      // Choose the primary credential category
      _primaryCredCategory = _chooseCredentialCategory(_countsByCategory.keys);

      // Compute totals from that single category only
      if (_primaryCredCategory != null) {
        _totalCredentials = _countsByCategory[_primaryCredCategory!] ?? 0;
        _summarizeCredIdsFromCategory(_primaryCredCategory!);
      }

      setState(() {});
    } catch (e) {
      _root = null;
      _formattedJson = null;
      setState(() {});
    }
  }

  String? _chooseCredentialCategory(Iterable<String> categories) {
    if (categories.isEmpty) return null;

    // Prefer exact names (case-insensitive)
    final lowerSet = {for (final c in categories) c.toLowerCase(): c};

    for (final pref in _prefCredCats) {
      final hit = lowerSet[pref.toLowerCase()];
      if (hit != null) return hit;
    }

    // Fallback: first category whose name is exactly "credential" ignoring case
    for (final c in categories) {
      if (c.toLowerCase() == 'credential') return c;
    }

    // Last fallback: a category containing "credential" but not obvious non-credential words
    for (final c in categories) {
      final lc = c.toLowerCase();
      if (lc.contains('credential') &&
          !lc.contains('definition') &&
          !lc.contains('def') &&
          !lc.contains('offer') &&
          !lc.contains('request') &&
          !lc.contains('presentation')) {
        return c;
      }
    }

    return null;
    // If still null, we show 0 credentials (no chosen category).
  }

  void _summarizeCredIdsFromCategory(String cat) {
    final items = _root?[cat];
    if (items == null) return;

    Iterable<Map<String, dynamic>> rows;
    if (items is List) {
      rows = items.whereType<Map<String, dynamic>>();
    } else if (items is Map<String, dynamic>) {
      rows = [items];
    } else {
      rows = const Iterable.empty();
    }

    for (final row in rows) {
      final value = row['value'];
      if (value is! Map<String, dynamic>) continue;

      final sch = _extractSchemaId(value);
      final cd = _extractCredDefId(value);
      if (sch != null && sch.isNotEmpty) _allSchemaIds.add(sch);
      if (cd != null && cd.isNotEmpty) _allCredDefIds.add(cd);
    }
  }

  String? _extractSchemaId(Map<String, dynamic> v) {
    final s = v['schema_id'] ?? v['schemaId'];
    return s?.toString();
  }

  String? _extractCredDefId(Map<String, dynamic> v) {
    final c = v['cred_def_id'] ?? v['credDefId'];
    return c?.toString();
  }

  // ---------------- UI ----------------

  Widget _buildCredentialsSummaryCard() {
    if (_root == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Error: Could not parse JSON content',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    final allCats = _countsByCategory.keys.toList()..sort();
    final distinctSchemas = _allSchemaIds.length;
    final distinctCredDefs = _allCredDefIds.length;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + copy summary
            Row(
              children: [
                const Icon(Icons.verified_user_outlined),
                const SizedBox(width: 8),
                Text(
                  'Credentials Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Tooltip(
                  message: 'Copy credentials summary JSON',
                  child: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      final summary = {
                        'credential_category': _primaryCredCategory,
                        'total_credentials': _totalCredentials,
                        'distinct_schema_ids': distinctSchemas,
                        'distinct_cred_def_ids': distinctCredDefs,
                        'all_categories_count': allCats.length,
                        'all_records': _totalRecords,
                      };
                      Clipboard.setData(
                        ClipboardData(
                          text: const JsonEncoder.withIndent(
                            '  ',
                          ).convert(summary),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Credentials summary copied'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Top-line pills (credentials-first)
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _InfoPill(
                  label: 'Total Credentials',
                  value: '$_totalCredentials',
                  highlight: true,
                ),
                _InfoPill(
                  label: 'Category',
                  value: _primaryCredCategory ?? '—',
                ),
                _InfoPill(label: 'Distinct Schemas', value: '$distinctSchemas'),
                _InfoPill(
                  label: 'Distinct CredDefs',
                  value: '$distinctCredDefs',
                ),
                _InfoPill(label: 'All Categories', value: '${allCats.length}'),
                _InfoPill(label: 'All Records', value: '$_totalRecords'),
              ],
            ),

            const SizedBox(height: 10),
            Text(
              'Note: “Total Credentials” is taken from the "${_primaryCredCategory ?? '—'}" category.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCategoriesCard() {
    if (_root == null) return const SizedBox.shrink();

    final categories = _countsByCategory.keys.toList();
    categories.sort((a, b) {
      final ca = _countsByCategory[a] ?? 0;
      final cb = _countsByCategory[b] ?? 0;
      final byCount = cb.compareTo(ca);
      return byCount != 0 ? byCount : a.compareTo(b);
    });

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Row(
          children: [
            const Icon(Icons.analytics_outlined),
            const SizedBox(width: 8),
            Text(
              'All Categories',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text('${categories.length}'),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: Scrollbar(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (_, i) {
                    final cat = categories[i];
                    final count = _countsByCategory[cat] ?? 0;
                    final tagKeys =
                        _tagKeysByCategory[cat]?.toList() ?? <String>[];
                    tagKeys.sort();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              cat,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text('$count'),
                              visualDensity: VisualDensity.compact,
                            ),
                            if (_primaryCredCategory != null &&
                                cat == _primaryCredCategory)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Chip(
                                  label: const Text('credentials'),
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                ),
                              ),
                          ],
                        ),
                        if (tagKeys.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Tag Keys:',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: tagKeys
                                .map(
                                  (k) => Chip(
                                    visualDensity: VisualDensity.compact,
                                    label: Text(k),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonViewer() {
    final content = _showFormatted && _formattedJson != null
        ? _formattedJson!
        : widget.jsonContent;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header with actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.data_object),
                const SizedBox(width: 8),
                Text(
                  'JSON Content',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Tooltip(
                  message: _showFormatted
                      ? 'Show raw JSON'
                      : 'Show formatted JSON',
                  child: IconButton(
                    icon: Icon(_showFormatted ? Icons.code_off : Icons.code),
                    onPressed: () =>
                        setState(() => _showFormatted = !_showFormatted),
                  ),
                ),
                Tooltip(
                  message: 'Copy JSON to clipboard',
                  child: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: content));
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('JSON copied to clipboard'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Scrollable viewer
          SizedBox(
            height: 360,
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 800),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SelectableText(
                      content,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFileInfoDialog() async {
    try {
      final file = File(widget.filePath);
      if (!file.existsSync()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File no longer exists')),
          );
        }
        return;
      }
      final size = file.lengthSync();
      final sizeKB = (size / 1024).toStringAsFixed(1);
      final modified = await file.lastModified();

      if (!mounted) return;
      final categoriesCount = _countsByCategory.length;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('File Information'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Path:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Tooltip(
                      message: 'Copy path to clipboard',
                      child: IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.filePath),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('File path copied to clipboard'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
                SelectableText(
                  widget.filePath,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text('Size: $sizeKB KB'),
                Text('Modified: ${modified.toLocal()}'),
                const SizedBox(height: 8),
                Text('Total Credentials: $_totalCredentials'),
                Text('Credential Category: ${_primaryCredCategory ?? '—'}'),
                Text('Distinct Schemas: ${_allSchemaIds.length}'),
                Text('Distinct CredDefs: ${_allCredDefIds.length}'),
                Text('Categories: $categoriesCount'),
                Text('Records: $_totalRecords'),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reading file info: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.filePath.split(Platform.pathSeparator).last;

    return Scaffold(
      appBar: AppBar(
        title: Text('View: $fileName', overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: _showSummary ? 'Hide summary' : 'Show summary',
            icon: Icon(_showSummary ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _showSummary = !_showSummary),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: ListView(
            children: [
              if (_showSummary) ...[
                _buildCredentialsSummaryCard(),
                const SizedBox(height: 12),
                _buildAllCategoriesCard(),
                const SizedBox(height: 12),
              ],
              _buildJsonViewer(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showFileInfoDialog,
        icon: const Icon(Icons.info_outline),
        label: const Text('File Info'),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _InfoPill({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = highlight
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest;
    final fg = highlight ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: fg, fontWeight: FontWeight.w600),
          ),
          Text(value, style: TextStyle(color: fg)),
        ],
      ),
    );
  }
}
