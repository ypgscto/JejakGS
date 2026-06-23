import '../models/api_response.dart';
import '../services/api_service.dart';

class SimawaRepository {
  const SimawaRepository({required this.apiService});

  final ApiService apiService;

  Future<ApiResponse<T>> getResource<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) {
    return apiService.get<T>(
      path,
      headers: headers,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
      decoder: decoder,
    );
  }

  Future<ApiResponse<T>> postResource<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) {
    return apiService.post<T>(
      path,
      headers: headers,
      body: body,
      requiresAuth: requiresAuth,
      decoder: decoder,
    );
  }
}
