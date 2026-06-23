import '../models/api_response.dart';
import 'auth_token_storage.dart';
import 'base_simawa_service.dart';

class AuthService extends BaseSimawaService {
  const AuthService({required super.apiService, required this.tokenStorage});

  final AuthTokenStorage tokenStorage;

  Future<JsonMapResponse> login({
    required String identifier,
    required String password,
  }) async {
    final response = await api.post<Map<String, dynamic>>(
      '/auth/login',
      requiresAuth: false,
      body: {
        'login': identifier,
        'identifier': identifier,
        'password': password,
        'device_name': 'JejakGS Web/Mobile',
      },
      decoder: asMapOrEmpty,
    );

    final token = _extractToken(response.data);
    if (response.isSuccess && token != null) {
      await tokenStorage.saveAccessToken(token);
    }

    return response;
  }

  Future<JsonMapResponse> me() {
    return api.get<Map<String, dynamic>>('/me', decoder: asMapOrEmpty);
  }

  Future<JsonMapResponse> registerAlumni({
    required String email,
    required String name,
    required String password,
    required String passwordConfirmation,
    required String nim,
  }) async {
    final response = await api.post<Map<String, dynamic>>(
      '/auth/register-alumni',
      requiresAuth: false,
      body: {
        'email': email,
        'name': name,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'nim': nim,
        'device_name': 'JejakGS Web/Mobile',
      },
      decoder: asMapOrEmpty,
    );

    final token = _extractToken(response.data);
    if (response.isSuccess && token != null) {
      await tokenStorage.saveAccessToken(token);
    }

    return response;
  }

  Future<JsonMapResponse> resendVerificationEmail({required String email}) {
    return api.post<Map<String, dynamic>>(
      '/auth/resend-verification',
      requiresAuth: false,
      body: {'email': email},
      decoder: asMapOrEmpty,
    );
  }

  Future<JsonMapResponse> activate({
    required String identifier,
    required String activationCode,
    String? password,
  }) async {
    final body = <String, dynamic>{
      'identifier': identifier,
      'activation_code': activationCode,
      if (password != null && password.trim().isNotEmpty) 'password': password,
    };

    final response = await api.post<Map<String, dynamic>>(
      '/auth/activate',
      requiresAuth: false,
      body: body,
      decoder: asMapOrEmpty,
    );

    final token = _extractToken(response.data);
    if (response.isSuccess && token != null) {
      await tokenStorage.saveAccessToken(token);
    }

    return response;
  }

  Future<ApiResponse<void>> logout() async {
    final response = await api.post<void>('/auth/logout', decoder: (_) {});
    await tokenStorage.clearAccessToken();
    return response;
  }

  Future<void> saveToken(String token) {
    return tokenStorage.saveAccessToken(token);
  }

  Future<String?> readToken() {
    return tokenStorage.readAccessToken();
  }

  Future<void> clearToken() {
    return tokenStorage.clearAccessToken();
  }

  String? _extractToken(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }

    final token = data['access_token'] ?? data['token'];
    return token?.toString();
  }
}
