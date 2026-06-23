import '../utils/url_utils.dart';

enum AppEnvironment { development, staging, production }

class AppConfig {
  const AppConfig({
    required this.appName,
    required this.environment,
    required this.simawaGsBaseUrl,
    required this.apiTimeout,
  });

  final String appName;
  final AppEnvironment environment;
  final String simawaGsBaseUrl;
  final Duration apiTimeout;

  static AppConfig fromEnvironment() {
    const environmentName = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );
    const simawaGsBaseUrl = String.fromEnvironment('SIMAWA_GS_BASE_URL');
    const apiTimeoutSeconds = int.fromEnvironment(
      'SIMAWA_GS_TIMEOUT_SECONDS',
      defaultValue: 30,
    );

    return AppConfig(
      appName: 'JejakGS',
      environment: _parseEnvironment(environmentName),
      simawaGsBaseUrl: UrlUtils.normalizeBaseUrl(simawaGsBaseUrl),
      apiTimeout: Duration(seconds: apiTimeoutSeconds),
    );
  }

  bool get isSimawaApiConfigured => simawaGsBaseUrl.isNotEmpty;

  Uri simawaUri(String path, [Map<String, dynamic>? queryParameters]) {
    if (!isSimawaApiConfigured) {
      throw StateError(
        'SIMAWA_GS_BASE_URL belum dikonfigurasi. '
        'Jalankan app dengan --dart-define=SIMAWA_GS_BASE_URL=<base-url>.',
      );
    }

    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final base = Uri.parse('$simawaGsBaseUrl/');

    return base.replace(
      pathSegments: [
        ...base.pathSegments.where((segment) => segment.isNotEmpty),
        ...normalizedPath
            .split('/')
            .where((segment) => segment.trim().isNotEmpty),
      ],
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value?.toString()),
      ),
    );
  }

  static AppEnvironment _parseEnvironment(String value) {
    return AppEnvironment.values.firstWhere(
      (environment) => environment.name == value,
      orElse: () => AppEnvironment.development,
    );
  }
}
