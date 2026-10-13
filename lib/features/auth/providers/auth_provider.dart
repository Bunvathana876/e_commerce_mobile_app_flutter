import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  // Storage keys
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';

  AuthProvider({AuthService? authService, SharedPreferences? initialPrefs})
    : _authService = authService ?? AuthService() {
    if (initialPrefs != null) {
      _loadFromPrefs(initialPrefs);
    } else {
      _loadSavedSession();
    }
  }

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _currentUser != null;

  // Restore session from SharedPreferences
  void _loadFromPrefs(SharedPreferences prefs) {
    try {
      final savedToken = prefs.getString(_keyToken);
      final savedUserJson = prefs.getString(_keyUser);

      if (savedToken != null &&
          savedToken.isNotEmpty &&
          savedUserJson != null &&
          savedUserJson.isNotEmpty) {
        final Map<String, dynamic> userMap =
            jsonDecode(savedUserJson) as Map<String, dynamic>;
        _token = savedToken;
        _currentUser = UserModel.fromJson(userMap);
        ApiClient.instance.setAuthToken(savedToken);
      }
    } catch (e) {
      debugPrint('Failed to restore saved session: $e');
    } finally {
      _isInitialized = true;
    }
  }

  // Load saved session from storage
  Future<void> _loadSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _loadFromPrefs(prefs);
    } catch (e) {
      debugPrint('Failed to initialize SharedPreferences: $e');
      _isInitialized = true;
    }
    notifyListeners();
  }

  // Sign in and save session
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );
      _token = response['token'] as String;
      _currentUser = UserModel.fromJson(
        response['user'] as Map<String, dynamic>,
      );
      ApiClient.instance.setAuthToken(_token!);

      // Persist login session to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, _token!);
      await prefs.setString(_keyUser, jsonEncode(_currentUser!.toJson()));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Register new account and save session
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
      _token = response['token'] as String;
      _currentUser = UserModel.fromJson(
        response['user'] as Map<String, dynamic>,
      );
      ApiClient.instance.setAuthToken(_token!);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, _token!);
      await prefs.setString(_keyUser, jsonEncode(_currentUser!.toJson()));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Update and save user session directly
  Future<void> saveUserSession({
    required String token,
    required UserModel user,
  }) async {
    _token = token;
    _currentUser = user;
    ApiClient.instance.setAuthToken(token);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyUser, jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Failed to save user session: $e');
    }

    notifyListeners();
  }

  // Log out and clear stored session
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _errorMessage = null;
    ApiClient.instance.clearAuthToken();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyUser);
    } catch (e) {
      debugPrint('Failed to clear saved session: $e');
    }

    notifyListeners();
  }
}
