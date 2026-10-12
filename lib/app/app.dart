import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../features/profile/settings/providers/theme_provider.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Blue Panda',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider
          .themeMode, // 👈 Dynamically switches between Light & Dark
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routes,
    );
  }
}
