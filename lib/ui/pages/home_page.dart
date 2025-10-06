import 'package:askar_alpha/ui/pages/trust_bundle_settings_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.security),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrustBundleSettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: const Center(child: Text('Home Page')),
    );
  }
}
