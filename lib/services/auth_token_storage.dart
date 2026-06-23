import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthTokenStorage {
  Future<String?> readAccessToken();

  Future<void> saveAccessToken(String token);

  Future<void> clearAccessToken();
}

class SecureAuthTokenStorage implements AuthTokenStorage {
  SecureAuthTokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'simawa_gs_access_token';

  final FlutterSecureStorage _secureStorage;

  @override
  Future<String?> readAccessToken() {
    return _secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<void> saveAccessToken(String token) {
    return _secureStorage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<void> clearAccessToken() {
    return _secureStorage.delete(key: _accessTokenKey);
  }
}
