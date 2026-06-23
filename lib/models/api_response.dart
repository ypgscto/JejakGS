class ApiResponse<T> {
  const ApiResponse._({
    required this.status,
    required this.statusCode,
    this.data,
    this.message,
    this.errors,
    this.rawBody,
  });

  final String status;
  final int statusCode;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;
  final String? rawBody;

  bool get isSuccess => status == 'success';

  factory ApiResponse.success({
    required int statusCode,
    T? data,
    String? message,
    String? rawBody,
  }) {
    return ApiResponse._(
      status: 'success',
      statusCode: statusCode,
      data: data,
      message: message,
      rawBody: rawBody,
    );
  }

  factory ApiResponse.failure({
    required int statusCode,
    String? message,
    Map<String, dynamic>? errors,
    String? rawBody,
  }) {
    return ApiResponse._(
      status: 'error',
      statusCode: statusCode,
      message: message,
      errors: errors,
      rawBody: rawBody,
    );
  }

  ApiResponse<T> copyWithStatus(String value) {
    return ApiResponse._(
      status: value,
      statusCode: statusCode,
      data: data,
      message: message,
      errors: errors,
      rawBody: rawBody,
    );
  }
}
