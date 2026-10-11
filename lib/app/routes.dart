import 'package:flutter/material.dart';
import '../features/auth/screens/auth_welcome_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/navigation/main_navigation_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String mainNav = '/main-nav';

  static Map<String, WidgetBuilder> get routes => {
    welcome: (context) => const AuthWelcomeScreen(),
    login: (context) => const LoginScreen(),
    signUp: (context) => const SignUpScreen(),
    mainNav: (context) => const MainNavigationScreen(),
  };
}
