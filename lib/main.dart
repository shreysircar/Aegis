import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ add this
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';
import 'features/splash/splash_screen.dart';

void main() {
  runApp(
    const ProviderScope( // ✅ wrap app with ProviderScope
      child: AegisApp(),
    ),
  );
}

class AegisApp extends StatelessWidget {
  const AegisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aegis',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}
