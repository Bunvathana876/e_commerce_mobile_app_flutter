import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blue Panda E-Commerce',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.welcome, // Opens the welcome screen first
      routes: AppRoutes.routes,
    );
  }
}
