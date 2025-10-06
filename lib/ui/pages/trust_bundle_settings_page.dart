import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/trust_bundle_provider.dart';

class TrustBundleSettingsPage extends StatefulWidget {
  const TrustBundleSettingsPage({super.key});

  @override
  State<TrustBundleSettingsPage> createState() =>
      _TrustBundleSettingsPageState();
}

class _TrustBundleSettingsPageState extends State<TrustBundleSettingsPage> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TrustBundleProvider>();
      provider.loadInitialData();
      _urlController.text = provider.bundleUrl;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trust Bundle'),
      ),
      body: Consumer<TrustBundleProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildUrlCard(provider),
              const SizedBox(height: 16),
              if (provider.previewError != null) ...[
                _buildErrorCard(provider.previewError!),
                const SizedBox(height: 16),
              ],
              if (provider.bundlePreview != null) ...[
                _buildPreviewCard(provider),
                const SizedBox(height: 16),
                _buildExpandableTrustedIssuersCard(provider),
                const SizedBox(height: 16),
                _buildExpandableSchemasCard(provider),
                const SizedBox(height: 16),
                _buildExpandableCredDefsCard(provider),
                const SizedBox(height: 16),
              ],
              _buildStatusCard(provider),
              const SizedBox(height: 16),
              _buildDeveloperToolsCard(),
              const SizedBox(height: 16),
              if (provider.isLoading)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: provider.progressValue,
                      backgroundColor: Colors.grey[300],
                      color: provider.isHealthy == false ? Colors.red : null,
                    ),
                    const SizedBox(height: 8),
                    Text(provider.progressMessage),
                    const SizedBox(height: 16),
                  ],
                ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          provider.isLoading ? null : provider.previewBundle,
                      icon: const Icon(Icons.preview),
                      label: const Text('Preview Bundle'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          provider.isLoading || provider.bundlePreview == null
                              ? null
                              : provider.syncBundle,
                      icon: const Icon(Icons.save),
                      label: const Text('Save to Database'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Preview Error',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(error, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(TrustBundleProvider provider) {
    final preview = provider.bundlePreview!;
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.preview, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Bundle Preview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPreviewRow('Network', preview['network'] ?? 'Unknown'),
            _buildPreviewRow(
                'Version', preview['bundleVersion']?.toString() ?? 'Unknown'),
            _buildPreviewRow(
                'Schemas', preview['schemaCount']?.toString() ?? '0'),
            _buildPreviewRow('Credential Definitions',
                preview['credDefCount']?.toString() ?? '0'),
            if (preview['generatedAt'] != null)
              _buildPreviewRow('Generated', preview['generatedAt']),
            if (preview['expiresAt'] != null)
              _buildPreviewRow('Expires', preview['expiresAt']),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlCard(TrustBundleProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Endpoint',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Bundle URL',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => provider.setBundleUrl(value),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          await provider.checkHealth();
                        },
                  child: const Text('Check Health'),
                ),
                if (provider.isLoading && provider.isHealthy == null)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (provider.isHealthy != null)
                  Icon(
                    provider.isHealthy! ? Icons.check_circle : Icons.error,
                    color: provider.isHealthy! ? Colors.green : Colors.red,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(TrustBundleProvider provider) {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.storage, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Database Contents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusRow(
              'Last Synced',
              provider.lastSynced != null
                  ? _formatDateTime(provider.lastSynced!)
                  : 'Never',
            ),
            _buildStatusRow(
              'Schemas',
              provider.schemaCount.toString(),
            ),
            _buildStatusRow(
              'Credential Definitions',
              provider.credDefCount.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperToolsCard() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.bug_report, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Developer Tools',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Expanded(
                        child: Text(
                          'Isar Inspector (Debug Mode)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Inspect the database in detail:\n'
                    '• Check terminal for "ISAR CONNECT STARTED"\n'
                    '• Click the https://inspect.isar.dev/... URL\n'
                    '• Browse schemas, cred defs, and bundles live',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      _showIsarInspectorDialog(context);
                    },
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('How to Access'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: BorderSide(color: Colors.orange.shade300),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showIsarInspectorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bug_report, color: Colors.orange),
            SizedBox(width: 8),
            Text('Isar Inspector Access'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'The Isar Inspector is a web-based database viewer that works in debug mode.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'How to Access:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('1. Check your terminal or console output'),
              SizedBox(height: 4),
              Text('2. Look for this banner:'),
              SizedBox(height: 8),
              Card(
                color: Colors.black87,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '╔══════════════════════════════╗\n'
                    '║   ISAR CONNECT STARTED     ║\n'
                    '╚══════════════════════════════╝',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text('3. Click the URL that looks like:'),
              SizedBox(height: 4),
              Text(
                'https://inspect.isar.dev/3.1.0+1/#/...',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'What You Can Do:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Browse all database collections'),
              Text('• Search and filter records'),
              Text('• View schemas and cred defs in detail'),
              Text('• Export data for analysis'),
              Text('• Execute custom queries'),
              SizedBox(height: 16),
              Text(
                'Note: This only works while the app is running in debug mode.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableTrustedIssuersCard(TrustBundleProvider provider) {
    final preview = provider.bundlePreview!;
    final trustedIssuers = (preview['trustedIssuers'] as List?) ?? [];

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.verified_user, color: Colors.green),
        title: Text('Trusted Issuers (${trustedIssuers.length})'),
        children: trustedIssuers.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No trusted issuers found'),
                )
              ]
            : trustedIssuers.map<Widget>((issuer) {
                final did = issuer['did'] as String? ?? 'Unknown';
                final schemaIds = (issuer['schema_ids'] as List?) ?? [];
                final credDefIds = (issuer['cred_def_ids'] as List?) ?? [];

                return ExpansionTile(
                  title: Text(
                    did,
                    style:
                        const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                  ),
                  children: [
                    if (schemaIds.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Schema IDs:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...schemaIds.map<Widget>((id) => Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, top: 4.0),
                                  child: Text(
                                    id.toString(),
                                    style: const TextStyle(
                                        fontSize: 12, fontFamily: 'monospace'),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    if (credDefIds.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Credential Definition IDs:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...credDefIds.map<Widget>((id) => Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, top: 4.0),
                                  child: Text(
                                    id.toString(),
                                    style: const TextStyle(
                                        fontSize: 12, fontFamily: 'monospace'),
                                  ),
                                )),
                          ],
                        ),
                      ),
                  ],
                );
              }).toList(),
      ),
    );
  }

  Widget _buildExpandableSchemasCard(TrustBundleProvider provider) {
    final preview = provider.bundlePreview!;
    final schemas = (preview['schemas'] as List?) ?? [];

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.description, color: Colors.blue),
        title: Text('Schemas (${schemas.length})'),
        children: schemas.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No schemas found'),
                )
              ]
            : schemas.map<Widget>((schema) {
                final id = schema['id'] as String? ?? 'Unknown';
                final name = schema['name'] as String? ?? 'Unknown';
                final version = schema['version'] as String? ?? 'Unknown';
                final attrNames = (schema['attrNames'] as List?) ?? [];

                return ExpansionTile(
                  title: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Version: $version',
                      style: const TextStyle(fontSize: 12)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: $id',
                            style: const TextStyle(
                                fontSize: 12, fontFamily: 'monospace'),
                          ),
                          const SizedBox(height: 8),
                          if (attrNames.isNotEmpty) ...[
                            const Text(
                              'Attributes:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: attrNames
                                  .map<Widget>((attr) => Chip(
                                        label: Text(attr.toString()),
                                        backgroundColor: Colors.blue.shade50,
                                      ))
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
      ),
    );
  }

  Widget _buildExpandableCredDefsCard(TrustBundleProvider provider) {
    final preview = provider.bundlePreview!;
    final credDefs = (preview['credDefs'] as List?) ?? [];

    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.key, color: Colors.orange),
        title: Text('Credential Definitions (${credDefs.length})'),
        children: credDefs.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No credential definitions found'),
                )
              ]
            : credDefs.map<Widget>((credDef) {
                final id = credDef['id'] as String? ?? 'Unknown';
                final type = credDef['type'] as String? ?? 'Unknown';
                final tag = credDef['tag'] as String? ?? 'Unknown';
                final schemaId = credDef['schemaId']?.toString() ?? 'Unknown';

                return ExpansionTile(
                  title: Text(
                    tag,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle:
                      Text('Type: $type', style: const TextStyle(fontSize: 12)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: $id',
                            style: const TextStyle(
                                fontSize: 12, fontFamily: 'monospace'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Schema ID: $schemaId',
                            style: const TextStyle(
                                fontSize: 12, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
      ),
    );
  }
}
