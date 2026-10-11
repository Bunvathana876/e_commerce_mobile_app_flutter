import 'dart:async';

class AuthService {
  // Temporary mock implementation to let you test the UI immediately.
  // We will connect this to your FastAPI backend once the API is up.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // Simulate mock credential check
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
}
