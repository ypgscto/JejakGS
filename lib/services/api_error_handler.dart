import 'dart:async';
import 'dart:io';

import '../core/errors/api_error.dart';

class ApiErrorHandler {
  const ApiErrorHandler._();

  static ApiError fromStatusCode({
    required int statusCode,
    String? message,
    Map<String, dynamic>? errors,
  }) {
    return ApiError(
      type: _typeFromStatusCode(statusCode),
      statusCode: statusCode,
      message: message ?? _messageFromStatusCode(statusCode),
      errors: errors,
    );
  }

  static ApiError fromException(Object error) {
    if (error is TimeoutException) {
      return const ApiError(
        type: ApiErrorType.timeout,
        statusCode: 0,
        message: 'Koneksi ke SIMAWA-GS timeout. Silakan coba lagi.',
      );
    }

    if (error is SocketException) {
      return const ApiError(
        type: ApiErrorType.noInternet,
        statusCode: 0,
        message:
            'Tidak ada koneksi internet atau server tidak dapat dijangkau.',
      );
    }

    if (error is HandshakeException) {
      return const ApiError(
        type: ApiErrorType.noInternet,
        statusCode: 0,
        message: 'Koneksi aman ke server SIMAWA-GS gagal.',
      );
    }

    return ApiError(
      type: ApiErrorType.unknown,
      statusCode: 0,
      message: 'Terjadi kesalahan saat menghubungi SIMAWA-GS: $error',
    );
  }

  static ApiErrorType _typeFromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
      case 422:
        return ApiErrorType.validation;
      case 401:
        return ApiErrorType.unauthorized;
      case 403:
        return ApiErrorType.forbidden;
      case 404:
        return ApiErrorType.notFound;
      case >= 500:
        return ApiErrorType.server;
      default:
        return ApiErrorType.unknown;
    }
  }

  static String _messageFromStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Data yang dikirim tidak valid.';
      case 401:
        return 'Sesi login tidak valid atau sudah berakhir.';
      case 403:
        return 'Anda tidak memiliki akses ke resource ini.';
      case 404:
        return 'Data yang diminta tidak ditemukan.';
      case 422:
        return 'Validasi data gagal.';
      case >= 500:
        return 'Server SIMAWA-GS sedang bermasalah. Silakan coba lagi nanti.';
      default:
        return 'Permintaan ke SIMAWA-GS gagal.';
    }
  }
}
