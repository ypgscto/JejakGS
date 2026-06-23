import 'dart:convert';

import '../models/api_response.dart';
import 'api_error_handler.dart';

class ApiResponseHandler {
  const ApiResponseHandler._();

  static ApiResponse<T> handle<T>({
    required int statusCode,
    required String rawBody,
    T Function(Object? json)? decoder,
  }) {
    final decodedBody = _decodeBody(rawBody);
    final message = _extractMessage(decodedBody);
    final errors = _extractErrors(decodedBody);
    final responseStatus = _extractStatus(decodedBody);
    final responseData = _extractData(decodedBody);

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse.success(
        statusCode: statusCode,
        data: decoder == null ? responseData as T? : decoder(responseData),
        message: message,
        rawBody: rawBody,
      ).copyWithStatus(responseStatus ?? 'success');
    }

    final apiError = ApiErrorHandler.fromStatusCode(
      statusCode: statusCode,
      message: message,
      errors: errors,
    );

    return ApiResponse<T>.failure(
      statusCode: statusCode,
      message: apiError.message,
      errors: apiError.errors,
      rawBody: rawBody,
    ).copyWithStatus(responseStatus ?? 'error');
  }

  static ApiResponse<T> handleException<T>(Object error) {
    final apiError = ApiErrorHandler.fromException(error);

    return ApiResponse.failure(
      statusCode: apiError.statusCode,
      message: apiError.message,
      errors: apiError.errors,
    );
  }

  static Object? _decodeBody(String rawBody) {
    if (rawBody.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(rawBody);
    } on FormatException {
      return rawBody;
    }
  }

  static String? _extractMessage(Object? decodedBody) {
    if (decodedBody is Map<String, dynamic>) {
      final message = decodedBody['message'] ?? decodedBody['error'];
      return message?.toString();
    }

    return null;
  }

  static String? _extractStatus(Object? decodedBody) {
    if (decodedBody is Map<String, dynamic>) {
      return decodedBody['status']?.toString();
    }

    return null;
  }

  static Object? _extractData(Object? decodedBody) {
    if (decodedBody is Map<String, dynamic> &&
        decodedBody.containsKey('data')) {
      return decodedBody['data'];
    }

    return decodedBody;
  }

  static Map<String, dynamic>? _extractErrors(Object? decodedBody) {
    if (decodedBody is Map<String, dynamic> && decodedBody['errors'] is Map) {
      return Map<String, dynamic>.from(decodedBody['errors'] as Map);
    }

    return null;
  }
}
