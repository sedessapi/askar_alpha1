import 'package:askar_alpha/ui/theme/theme_notifier.dart';
import 'package:askar_alpha/ui/pages/download_page.dart';
import 'package:askar_alpha/ui/pages/credentials_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          Consumer<ThemeNotifier>(
            builder: (context, themeNotifier, child) {
              return ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: themeNotifier.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeNotifier
                        .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
              );
            },
          ),
          const Divider(),
          _buildDeveloperToolsSection(context),
        ],
      ),
    );
  }

  Widget _buildDeveloperToolsSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
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

            // Download Page Link
            ListTile(
              leading: const Icon(Icons.download, color: Colors.orange),
              title: const Text('Download'),
              subtitle: const Text('Export wallet data from ACA-Py'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DownloadPage(),
                  ),
                );
              },
            ),

            const Divider(),

            // Credentials Page Link
            ListTile(
              leading: const Icon(Icons.badge, color: Colors.orange),
              title: const Text('Credentials'),
              subtitle: const Text('Import wallet data to Askar'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CredentialsPage(),
                  ),
                );
              },
            ),

            const Divider(),
            const SizedBox(height: 8),

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
}
