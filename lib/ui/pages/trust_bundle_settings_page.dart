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
              ],
              _buildStatusCard(provider),
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
            _buildPreviewRow('Version', preview['bundleVersion']?.toString() ?? 'Unknown'),
            _buildPreviewRow('Schemas', preview['schemaCount']?.toString() ?? '0'),
            _buildPreviewRow('Credential Definitions', preview['credDefCount']?.toString() ?? '0'),
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
}
