import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';

// Authentication service connecting to REST backend
class AuthApiService {
  final ApiClient _client;

  AuthApiService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  // Sign in with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      body: {
        'email': email,
        'password': password,
      },
      parser: (data) => data as Map<String, dynamic>,
    );

    final data = response.data ?? {};
    final token = data['token'] ?? data['access_token'];
    if (token != null) {
      _client.setAuthToken(token.toString());
    }

    return data;
  }

  // Register new user account
  Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      body: {
        'full_name': fullName,
        'email': email,
        'password': password,
      },
      parser: (data) => data as Map<String, dynamic>,
    );

    final data = response.data ?? {};
    final token = data['token'] ?? data['access_token'];
    if (token != null) {
      _client.setAuthToken(token.toString());
    }

    return data;
  }

  // Fetch authenticated user profile
  Future<UserModel> getProfile() async {
    final response = await _client.get<UserModel>(
      ApiEndpoints.me,
      parser: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );

    if (response.data == null) {
      throw Exception('Failed to load user profile');
    }

    return response.data!;
  }

  // Invalidate current session on backend
  Future<void> logout() async {
    try {
      await _client.post<dynamic>(ApiEndpoints.logout);
    } finally {
      _client.clearAuthToken();
    }
  }
}
