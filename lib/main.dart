import 'package:askar_alpha/ui/navigation/app_navigation.dart';
import 'package:askar_alpha/ui/theme/app_theme.dart';
import 'package:askar_alpha/ui/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier(ThemeMode.light)),
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
