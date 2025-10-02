import 'package:flutter/material.dart';
import 'package:askar_import/ui/pages/wallet_export_download_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Askar Export Downloader',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E7D32),
      ),
      home: const WalletExportDownloadPage(),
    );
  }
}
