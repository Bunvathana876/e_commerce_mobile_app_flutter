import 'dart:async';
import 'auth_api_service.dart';

// Authentication service supporting both REST backend and mock mode
class AuthService {
  final AuthApiService _apiService;
  final bool useRemoteBackend;

  AuthService({
    AuthApiService? apiService,
    this.useRemoteBackend = false,
  }) : _apiService = apiService ?? AuthApiService();

  // Sign in check via remote API or mock credentials
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (useRemoteBackend) {
      return _apiService.login(email: email, password: password);
    }

    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 1200));

    // Mock credential validation
    if (email == 'student@example.com' && password == 'password123') {
      return {
        'token': 'mock_jwt_access_token_xyz',
        'user': {
          'id': 1,
          'email': 'student@example.com',
          'full_name': 'Bun Vathana',
          'role': 'customer',
          'avatar_url': null,
        },
      };
    } else {
      throw Exception(
        'Invalid email or password. Use student@example.com / password123',
      );
    }
  }

  // Register new account via remote API or mock flow
  Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (useRemoteBackend) {
      return _apiService.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );
    }

    await Future.delayed(const Duration(milliseconds: 1200));
    return {
      'token': 'mock_jwt_access_token_registered',
      'user': {
        'id': 2,
        'email': email,
        'full_name': fullName,
        'role': 'customer',
        'avatar_url': null,
      },
    };
  }
}
