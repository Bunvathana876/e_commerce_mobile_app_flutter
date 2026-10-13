import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;
import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import 'api_exceptions.dart';
import 'api_response.dart';

// Central HTTP client for network requests with auth, parsing, and error handling
class ApiClient {
  final http.Client _httpClient;
  String? _authToken;

  ApiClient({http.Client? client}) : _httpClient = client ?? http.Client();

  // Shared singleton instance for the app
  static final ApiClient instance = ApiClient();

  // Authentication token management
  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  String? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  // Build full request headers
  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  // Build target URI supporting relative paths and query parameters
  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final base = path.startsWith('http://') || path.startsWith('https://')
        ? path
        : '${ApiEndpoints.baseUrl}$path';

    final uri = Uri.parse(base);
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    // Convert all query parameter values to strings
    final stringQueryParams = queryParameters.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...stringQueryParams,
    });
  }

  // Generic GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic data)? parser,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path, queryParameters);
    return _sendRequest<T>(
      () => _httpClient.get(uri, headers: _buildHeaders(headers)),
      parser: parser,
      timeout: timeout,
    );
  }

  // Generic POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic data)? parser,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final encodedBody = body != null ? jsonEncode(body) : null;
    return _sendRequest<T>(
      () => _httpClient.post(
        uri,
        headers: _buildHeaders(headers),
        body: encodedBody,
      ),
      parser: parser,
      timeout: timeout,
    );
  }

  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic data)? parser,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final encodedBody = body != null ? jsonEncode(body) : null;
    return _sendRequest<T>(
      () => _httpClient.put(
        uri,
        headers: _buildHeaders(headers),
        body: encodedBody,
      ),
      parser: parser,
      timeout: timeout,
    );
  }

  // Generic PATCH request
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic data)? parser,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final encodedBody = body != null ? jsonEncode(body) : null;
    return _sendRequest<T>(
      () => _httpClient.patch(
        uri,
        headers: _buildHeaders(headers),
        body: encodedBody,
      ),
      parser: parser,
      timeout: timeout,
    );
  }

  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic data)? parser,
    Duration? timeout,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final encodedBody = body != null ? jsonEncode(body) : null;
    return _sendRequest<T>(
      () => _httpClient.delete(
        uri,
        headers: _buildHeaders(headers),
        body: encodedBody,
      ),
      parser: parser,
      timeout: timeout,
    );
  }

  // Internal request executor with timeout and error translation
  Future<ApiResponse<T>> _sendRequest<T>(
    Future<http.Response> Function() requestFn, {
    T Function(dynamic data)? parser,
    Duration? timeout,
  }) async {
    final effectiveTimeout = timeout ?? ApiEndpoints.receiveTimeout;

    try {
      final response = await requestFn().timeout(effectiveTimeout);

      // Validate HTTP status
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return ApiResponse<T>(
            success: true,
            statusCode: response.statusCode,
          );
        }

        final decoded = jsonDecode(response.body);

        if (parser != null) {
          return ApiResponse<T>.fromJson(
            decoded,
            parser,
            statusCode: response.statusCode,
          );
        }

        return ApiResponse<T>(
          success: true,
          data: decoded as T?,
          statusCode: response.statusCode,
        );
      }

      // Non-2xx status code: throw typed ApiException
      throw ApiException.fromStatusCode(response.statusCode, response.body);
    } on SocketException catch (_) {
      throw const NetworkException();
    } on TimeoutException catch (_) {
      throw const RequestTimeoutException();
    } on http.ClientException catch (e) {
      throw NetworkException(e.message);
    } on FormatException catch (_) {
      throw const ApiException('Invalid data format received from server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected network error: $e');
    }
  }

  // Close the underlying client
  void dispose() {
    _httpClient.close();
  }
}
