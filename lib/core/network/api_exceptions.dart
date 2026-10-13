import 'dart:convert';

// Base exception for all API and network errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;

  // Extract a readable message from an error response payload
  static String extractErrorMessage(String responseBody, {String fallback = 'An unexpected error occurred'}) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        // FastAPI uses "detail", other APIs often use "message" or "error"
        if (decoded['detail'] != null) {
          if (decoded['detail'] is String) {
            return decoded['detail'] as String;
          }
          if (decoded['detail'] is List && (decoded['detail'] as List).isNotEmpty) {
            final first = (decoded['detail'] as List).first;
            if (first is Map && first['msg'] != null) {
              return first['msg'].toString();
            }
          }
          return decoded['detail'].toString();
        }
        if (decoded['message'] != null) {
          return decoded['message'].toString();
        }
        if (decoded['error'] != null) {
          return decoded['error'].toString();
        }
      }
    } catch (_) {
      // Body is not JSON
    }
    return fallback;
  }

  // Create specific exception based on HTTP status code
  factory ApiException.fromStatusCode(int statusCode, String responseBody) {
    final message = extractErrorMessage(
      responseBody,
      fallback: 'Request failed with status code $statusCode',
    );

    dynamic decodedData;
    try {
      decodedData = jsonDecode(responseBody);
    } catch (_) {
      decodedData = responseBody;
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(message, data: decodedData);
      case 401:
        return UnauthorizedException(message, data: decodedData);
      case 403:
        return ForbiddenException(message, data: decodedData);
      case 404:
        return NotFoundException(message, data: decodedData);
      case 409:
        return ConflictException(message, data: decodedData);
      case >= 500:
        return ServerException(
          'Server encountered an error. Please try again later.',
          statusCode: statusCode,
          data: decodedData,
        );
      default:
        return ApiException(message, statusCode: statusCode, data: decodedData);
    }
  }
}

// Thrown when device has no internet or cannot connect to host
class NetworkException extends ApiException {
  const NetworkException([
    super.message =
        'Unable to connect to the server. Please check your internet connection.',
  ]);
}

// Thrown when an HTTP request exceeds timeout duration
class RequestTimeoutException extends ApiException {
  const RequestTimeoutException([
    super.message = 'Connection timed out. Please try again.',
  ]);
}

// Thrown on 400 Bad Request
class BadRequestException extends ApiException {
  const BadRequestException(super.message, {super.data})
      : super(statusCode: 400);
}

// Thrown on 401 Unauthorized
class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message, {super.data})
      : super(statusCode: 401);
}

// Thrown on 403 Forbidden
class ForbiddenException extends ApiException {
  const ForbiddenException(super.message, {super.data})
      : super(statusCode: 403);
}

// Thrown on 404 Not Found
class NotFoundException extends ApiException {
  const NotFoundException(super.message, {super.data})
      : super(statusCode: 404);
}

// Thrown on 409 Conflict
class ConflictException extends ApiException {
  const ConflictException(super.message, {super.data})
      : super(statusCode: 409);
}

// Thrown on 5xx Server Error
class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode = 500, super.data});
}
