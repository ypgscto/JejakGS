import 'package:flutter_test/flutter_test.dart';
import 'package:jejak_gs/app.dart';
import 'package:jejak_gs/config/app_config.dart';
import 'package:jejak_gs/models/api_response.dart';
import 'package:jejak_gs/providers/state/app_state.dart';
import 'package:jejak_gs/repositories/simawa_repository.dart';
import 'package:jejak_gs/services/services.dart';

void main() {
  testWidgets('JejakGS renders login when no token exists', (tester) async {
    final appState = AppState(
      config: const AppConfig(
        appName: 'JejakGS',
        environment: AppEnvironment.development,
        simawaGsBaseUrl: '',
        apiTimeout: Duration(seconds: 30),
      ),
      simawaRepository: SimawaRepository(apiService: _FakeApiService()),
      authService: AuthService(
        apiService: _FakeApiService(),
        tokenStorage: _FakeTokenStorage(),
      ),
      alumniService: AlumniService(apiService: _FakeApiService()),
      dashboardService: DashboardService(apiService: _FakeApiService()),
      tracerService: TracerService(apiService: _FakeApiService()),
      ikaService: IkaService(apiService: _FakeApiService()),
      jobService: JobService(apiService: _FakeApiService()),
      eventService: EventService(apiService: _FakeApiService()),
      batchmateService: BatchmateService(apiService: _FakeApiService()),
      notificationService: NotificationService(apiService: _FakeApiService()),
      informationService: InformationService(apiService: _FakeApiService()),
    );

    await tester.pumpWidget(JejakGsApp(appState: appState));
    await tester.pumpAndSettle();

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Register Alumni'), findsOneWidget);
  });
}

class _FakeTokenStorage implements AuthTokenStorage {
  String? _token;

  @override
  Future<void> clearAccessToken() async {
    _token = null;
  }

  @override
  Future<String?> readAccessToken() async {
    return _token;
  }

  @override
  Future<void> saveAccessToken(String token) async {
    _token = token;
  }
}

class _FakeApiService implements ApiService {
  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<T>> patch<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) {
    throw UnimplementedError();
  }

  @override
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
  }) {
    throw UnimplementedError();
  }
}
