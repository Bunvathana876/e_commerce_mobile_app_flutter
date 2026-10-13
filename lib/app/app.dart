import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/auth_welcome_screen.dart';
import '../features/navigation/main_navigation_screen.dart';
import '../features/profile/settings/providers/theme_provider.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();

    return MaterialApp(
      title: 'Blue Panda',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      // Show main store if logged in, otherwise show welcome screen
      home: authProvider.isAuthenticated
          ? const MainNavigationScreen()
          : const AuthWelcomeScreen(),
      routes: AppRoutes.routes,
    );
  }
}
