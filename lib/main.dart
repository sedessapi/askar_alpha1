import 'package:askar_alpha/services/trust_bundle_provider.dart';
import 'package:askar_alpha/services/enhanced_verification_service.dart';
import 'package:askar_alpha/ui/navigation/app_navigation.dart';
import 'package:askar_alpha/ui/theme/app_theme.dart';
import 'package:askar_alpha/ui/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trust_bundle_core/trust_bundle_core.dart';
import 'package:trust_bundle_core/src/crypto/manifest_verifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = DbService();
  await dbService.init();

  final bundleClient = BundleClient();
  final manifestVerifier = ManifestVerifier(trustedKeys: {
    // TODO: Replace with actual trusted DID and public key
    'did:key:z6MkiTBz1ymuepAQ4HEHYSF1H8quG5GLVVQR3djdX3mDooWp':
        'your_base64_encoded_public_key_here'
  });

  final ingestionService = IngestionService(
    bundleClient: bundleClient,
    dbService: dbService,
    manifestVerifier: manifestVerifier,
  );

  // Initialize VerifierService for trust bundle verification
  final verifierService = VerifierService(dbService);

  // Initialize EnhancedVerificationService (without ACA-Py for now)
  final enhancedVerificationService = EnhancedVerificationService(
    verifierService: verifierService,
    acaPyClient: null, // TODO: Initialize ACA-Py client if needed
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier(ThemeMode.light)),
        ChangeNotifierProvider(
          create: (_) => TrustBundleProvider(
            ingestionService: ingestionService,
            dbService: dbService,
            bundleClient: bundleClient,
          ),
        ),
        Provider<EnhancedVerificationService>(
          create: (_) => enhancedVerificationService,
        ),
      ],
      child: const AskarAlphaApp(),
    ),
  );
}

class AskarAlphaApp extends StatelessWidget {
  const AskarAlphaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Askar Alpha',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeNotifier.themeMode,
          home: const AppNavigation(),
        );
      },
    );
  }
}
