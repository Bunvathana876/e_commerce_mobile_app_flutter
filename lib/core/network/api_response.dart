// Standard wrapper for API responses
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  const ApiResponse({
    required this.success,
    this.message = '',
    this.data,
    this.statusCode = 200,
  });

  // Successful response factory
  factory ApiResponse.success(
    T data, {
    String message = 'Success',
    int statusCode = 200,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  // Failed response factory
  factory ApiResponse.failure(
    String message, {
    int statusCode = 400,
    T? data,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  // Parse generic response from dynamic JSON
  factory ApiResponse.fromJson(
    dynamic json,
    T Function(dynamic data) parser, {
    int statusCode = 200,
  }) {
    if (json is Map<String, dynamic>) {
      final success = json['success'] as bool? ?? (statusCode >= 200 && statusCode < 300);
      final message = json['message'] as String? ?? '';
      final rawData = json.containsKey('data') ? json['data'] : json;

      return ApiResponse<T>(
        success: success,
        message: message,
        data: rawData != null ? parser(rawData) : null,
        statusCode: statusCode,
      );
    }

    return ApiResponse<T>(
      success: true,
      message: '',
      data: parser(json),
      statusCode: statusCode,
    );
  }
}

