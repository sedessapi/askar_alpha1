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
        title: const Text('Sync Bundle'),
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
              // Only show the database contents card if there is data in the database
              if (provider.lastSynced != null ||
                  provider.schemaCount > 0 ||
                  provider.credDefCount > 0) ...[
                _buildStatusCard(provider),
                const SizedBox(height: 16),
              ],
              if (provider.bundleData != null) ...[
                _buildExpandableTrustedIssuersCard(provider),
                const SizedBox(height: 16),
                _buildExpandableSchemasCard(provider),
                const SizedBox(height: 16),
                _buildExpandableCredDefsCard(provider),
                const SizedBox(height: 16),
              ],
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading ? null : provider.syncAndSaveBundle,
                  icon: const Icon(Icons.cloud_download),
                  label: const Text('Sync Bundle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
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

  Widget _buildExpandableTrustedIssuersCard(TrustBundleProvider provider) {
    final bundleData = provider.bundleData!;
    final trustedIssuers = (bundleData['trusted_issuers'] as List?) ?? [];

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
    final bundleData = provider.bundleData!;
    final artifacts = bundleData['artifacts'] as Map<String, dynamic>?;
    final schemasMap = artifacts?['schemas'] as Map<String, dynamic>?;
    final schemas = schemasMap?.values.toList() ?? [];

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
    final bundleData = provider.bundleData!;
    final artifacts = bundleData['artifacts'] as Map<String, dynamic>?;
    final credDefsMap = artifacts?['cred_defs'] as Map<String, dynamic>?;
    final credDefs = credDefsMap?.values.toList() ?? [];

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
