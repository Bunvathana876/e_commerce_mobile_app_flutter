import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/categories/providers/category_provider.dart';
import 'features/products/providers/product_provider.dart';
import 'features/profile/settings/providers/theme_provider.dart'; // 👈 Import ThemeProvider

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // 👈 Added here
      ],
      child: const MyApp(),
    ),
  );
}
