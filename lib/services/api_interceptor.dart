import 'dart:io';

import 'auth_token_storage.dart';

abstract class ApiInterceptor {
  Future<void> onRequest(
    HttpClientRequest request, {
    required bool requiresAuth,
  });
}

class AuthorizationInterceptor implements ApiInterceptor {
  const AuthorizationInterceptor({required this.tokenStorage});

  final AuthTokenStorage tokenStorage;

  @override
  Future<void> onRequest(
    HttpClientRequest request, {
    required bool requiresAuth,
  }) async {
    if (!requiresAuth) {
      return;
    }

    final token = await tokenStorage.readAccessToken();
    if (token == null || token.trim().isEmpty) {
      return;
    }

    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
  }
}
