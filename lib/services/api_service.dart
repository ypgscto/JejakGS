import '../models/api_response.dart';

class ApiMultipartFile {
  const ApiMultipartFile({
    required this.fieldName,
    required this.fileName,
    required this.bytes,
    this.contentType,
  });

  final String fieldName;
  final String fileName;
  final List<int> bytes;
  final String? contentType;
}

abstract class ApiService {
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  });

  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  });

  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  });

  Future<ApiResponse<T>> patch<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  });

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  });

  Future<ApiResponse<T>> postMultipart<T>(
    String path, {
    required String fieldName,
    required String fileName,
    required List<int> bytes,
    String? contentType,
    List<ApiMultipartFile>? additionalFiles,
    Map<String, String>? fields,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  });
}
