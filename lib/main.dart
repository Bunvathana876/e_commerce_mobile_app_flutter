import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/categories/providers/category_provider.dart';
import 'features/products/providers/product_provider.dart';
import 'features/profile/settings/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved preferences for auth session and theme
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('SharedPreferences initialization notice: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        // Authentication & user session management (restores login state)
        ChangeNotifierProvider(
          create: (_) => AuthProvider(initialPrefs: prefs),
        ),
        // Product catalog, search filtering, and favorites
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        // Cart state, item counts, and totals
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // Category navigation and department filtering
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        // Light & dark mode theme state (restores user preference)
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(initialPrefs: prefs),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
