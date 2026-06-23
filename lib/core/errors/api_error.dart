enum ApiErrorType {
  validation,
  unauthorized,
  forbidden,
  notFound,
  server,
  timeout,
  noInternet,
  unknown,
}

class ApiError {
  const ApiError({
    required this.type,
    required this.statusCode,
    required this.message,
    this.errors,
  });

  final ApiErrorType type;
  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;
}
