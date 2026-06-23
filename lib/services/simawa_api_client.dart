import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/api_response.dart';
import 'api_interceptor.dart';
import 'api_response_handler.dart';
import 'api_service.dart';
import 'auth_token_storage.dart';

enum ApiMethod { get, post, put, patch, delete }

class SimawaApiClient implements ApiService {
  SimawaApiClient({
    required this.config,
    required this.interceptors,
    this.tokenStorage,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final AppConfig config;
  final List<ApiInterceptor> interceptors;
  final AuthTokenStorage? tokenStorage;
  final http.Client _httpClient;

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) {
    return _send<T>(
      ApiMethod.get,
      path,
      headers: headers,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
      decoder: decoder,
    );
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) {
    return _send<T>(
      ApiMethod.post,
      path,
      headers: headers,
      body: body,
      requiresAuth: requiresAuth,
      decoder: decoder,
    );
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) {
    return _send<T>(
      ApiMethod.put,
      path,
      headers: headers,
      body: body,
      requiresAuth: requiresAuth,
      decoder: decoder,
    );
  }

  @override
  Future<ApiResponse<T>> patch<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) {
    return _send<T>(
      ApiMethod.patch,
      path,
      headers: headers,
      body: body,
      requiresAuth: requiresAuth,
      decoder: decoder,
    );
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) {
    return _send<T>(
      ApiMethod.delete,
      path,
      headers: headers,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
      decoder: decoder,
    );
  }

  @override
  Future<ApiResponse<T>> postMultipart<T>(
    String path, {
    required String fieldName,
    required String fileName,
    required List<int> bytes,
    String? contentType,
    Map<String, String>? fields,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) async {
    try {
      final uri = config.simawaUri(path);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_headersWithoutContentType());

      if (requiresAuth) {
        final token = await _readAccessToken();
        if (token != null && token.trim().isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      request.fields.addAll(fields ?? const {});
      request.files.add(
        http.MultipartFile.fromBytes(fieldName, bytes, filename: fileName),
      );

      final streamed = await request.send().timeout(config.apiTimeout);
      final response = await http.Response.fromStream(streamed);
      return ApiResponseHandler.handle<T>(
        statusCode: response.statusCode,
        rawBody: response.body,
        decoder: decoder,
      );
    } on Object catch (error) {
      return ApiResponseHandler.handleException<T>(error);
    }
  }

  Future<ApiResponse<T>> _send<T>(
    ApiMethod method,
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    required bool requiresAuth,
    T Function(Object? json)? decoder,
  }) async {
    try {
      final uri = config.simawaUri(path, queryParameters);
      final requestHeaders = _headers(headers);

      if (requiresAuth) {
        final token = await _readAccessToken();
        if (token != null && token.trim().isNotEmpty) {
          requestHeaders['Authorization'] = 'Bearer $token';
        }
      }

      final response = await _request(
        method,
        uri,
        headers: requestHeaders,
        body: body == null ? null : jsonEncode(body),
      ).timeout(config.apiTimeout);

      return ApiResponseHandler.handle<T>(
        statusCode: response.statusCode,
        rawBody: response.body,
        decoder: decoder,
      );
    } on Object catch (error) {
      return ApiResponseHandler.handleException<T>(error);
    }
  }

  Future<http.Response> _request(
    ApiMethod method,
    Uri uri, {
    required Map<String, String> headers,
    String? body,
  }) {
    switch (method) {
      case ApiMethod.get:
        return _httpClient.get(uri, headers: headers);
      case ApiMethod.post:
        return _httpClient.post(uri, headers: headers, body: body);
      case ApiMethod.put:
        return _httpClient.put(uri, headers: headers, body: body);
      case ApiMethod.patch:
        return _httpClient.patch(uri, headers: headers, body: body);
      case ApiMethod.delete:
        return _httpClient.delete(uri, headers: headers);
    }
  }

  Map<String, String> _headers(Map<String, String>? headers) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...?headers,
    };
  }

  Map<String, String> _headersWithoutContentType() {
    return {'Accept': 'application/json'};
  }

  Future<String?> _readAccessToken() async {
    if (tokenStorage != null) {
      return tokenStorage!.readAccessToken();
    }

    for (final interceptor in interceptors) {
      if (interceptor is AuthorizationInterceptor) {
        return interceptor.tokenStorage.readAccessToken();
      }
    }

    return null;
  }
}
