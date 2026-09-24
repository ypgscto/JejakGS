import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jejak_gs/config/app_config.dart';
import 'package:jejak_gs/models/api_response.dart';
import 'package:jejak_gs/providers/state/app_state.dart';
import 'package:jejak_gs/repositories/simawa_repository.dart';
import 'package:jejak_gs/screens/login_screen.dart';
import 'package:jejak_gs/screens/profile_screen.dart';
import 'package:jejak_gs/services/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Delete Account entry is available from Profile', (tester) async {
    final harness = await _Harness.authenticated();

    await tester.pumpWidget(_profileApp(harness.appState));
    await tester.pump();

    expect(find.text('Pengaturan Akun'), findsOneWidget);
    await tester.tap(find.text('Pengaturan Akun'));
    await tester.pump();

    expect(find.text('Hapus Akun JejakGS'), findsWidgets);
  });

  testWidgets('password and confirmation are required', (tester) async {
    final harness = await _Harness.authenticated();

    await tester.pumpWidget(_profileApp(harness.appState));
    await tester.pump();
    await _openDeleteForm(tester);

    ElevatedButton deleteButton() {
      return tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Hapus Akun'),
      );
    }

    expect(deleteButton().onPressed, isNull);

    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'rahasia-akun');
    await tester.pump();
    expect(deleteButton().onPressed, isNull);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(deleteButton().onPressed, isNotNull);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    expect(deleteButton().onPressed, isNull);
    expect(harness.api.deleteCalls, 0);
  });

  testWidgets('successful deletion clears session and returns to login', (
    tester,
  ) async {
    final harness = await _Harness.authenticated();
    harness.api.deleteResult = ApiResponse.success(
      statusCode: 200,
      message: 'Akun JejakGS berhasil dihapus.',
    );

    await tester.pumpWidget(_sessionApp(harness.appState));
    await tester.pump();
    await _openDeleteForm(tester);
    await tester.enterText(find.byType(TextField), 'rahasia-akun');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Hapus Akun'));
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Hapus Akun'));
    await tester.pumpAndSettle();

    expect(harness.storage.token, isNull);
    expect(harness.appState.alumniProfile, isNull);
    expect(harness.appState.dashboardSummary, isNull);
    expect(
      harness.appState.authFlowStatus,
      AuthFlowStatus.unauthenticated,
    );
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Akun JejakGS Anda berhasil dihapus.'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(harness.api.deleteCalls, 1);
    expect(harness.api.lastDeletePath, '/auth/account');
    expect(harness.api.lastDeleteBody, {'password': 'rahasia-akun'});
  });

  testWidgets('HTTP 422 keeps the user logged in', (tester) async {
    final harness = await _Harness.authenticated();
    harness.api.deleteResult = ApiResponse.failure(
      statusCode: 422,
      message: 'Password tidak cocok dengan akun ini.',
    );

    await tester.pumpWidget(_profileApp(harness.appState));
    await tester.pump();
    await _openDeleteForm(tester);
    await tester.enterText(find.byType(TextField), 'salah');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Hapus Akun'));
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Hapus Akun'));
    await tester.pump();

    expect(find.text('Password tidak cocok dengan akun ini.'), findsOneWidget);
    expect(harness.storage.token, 'token-uji');
    expect(harness.appState.alumniProfile, isNotNull);
    expect(
      harness.appState.authFlowStatus,
      isNot(AuthFlowStatus.unauthenticated),
    );
  });

  testWidgets('network failure keeps the user logged in', (tester) async {
    final harness = await _Harness.authenticated();
    harness.api.deleteResult = ApiResponse.failure(
      statusCode: 0,
      message: 'Tidak ada koneksi internet atau server tidak dapat dijangkau.',
    );

    await tester.pumpWidget(_profileApp(harness.appState));
    await tester.pump();
    await _openDeleteForm(tester);
    await tester.enterText(find.byType(TextField), 'rahasia-akun');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Hapus Akun'));
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Hapus Akun'));
    await tester.pump();

    expect(
      find.text('Akun belum dihapus. Periksa koneksi Anda dan coba kembali.'),
      findsOneWidget,
    );
    expect(harness.storage.token, 'token-uji');
    expect(
      harness.appState.authFlowStatus,
      isNot(AuthFlowStatus.unauthenticated),
    );
  });

  test('a second delete request is not sent while the first is running', () async {
    final harness = await _Harness.authenticated();
    final gate = Completer<void>();
    harness.api.deleteGate = gate.future;

    final first = harness.appState.deleteAccount('rahasia-akun');
    final second = harness.appState.deleteAccount('rahasia-akun');
    gate.complete();
    final results = await Future.wait([first, second]);

    expect(harness.api.deleteCalls, 1);
    expect(results, [true, false]);
    expect(harness.storage.token, isNull);
  });
}

Future<void> _openDeleteForm(WidgetTester tester) async {
  await tester.tap(find.text('Pengaturan Akun'));
  await tester.pump();
  await tester.ensureVisible(find.text('Hapus Akun JejakGS'));
  await tester.tap(find.text('Hapus Akun JejakGS'));
  await tester.pump();
  await tester.ensureVisible(find.text('Hapus Akun'));
}

Widget _profileApp(AppState appState) {
  return MaterialApp(
    home: Scaffold(body: ProfileScreen(appState: appState)),
  );
}

Widget _sessionApp(AppState appState) {
  return AnimatedBuilder(
    animation: appState,
    builder: (context, _) {
      final signedIn =
          appState.authFlowStatus != AuthFlowStatus.unauthenticated;
      return MaterialApp(
        home: Scaffold(
          body: signedIn
              ? ProfileScreen(appState: appState)
              : LoginScreen(appState: appState),
        ),
      );
    },
  );
}

class _Harness {
  _Harness(this.appState, this.api, this.storage);

  final AppState appState;
  final _ScriptedApi api;
  final _MemoryTokenStorage storage;

  static Future<_Harness> authenticated() async {
    final api = _ScriptedApi();
    final storage = _MemoryTokenStorage()..token = 'token-uji';
    final appState = AppState(
      config: const AppConfig(
        appName: 'JejakGS',
        environment: AppEnvironment.development,
        simawaGsBaseUrl: 'https://simawa.stikes.gunungsari.id/api/mobile',
        apiTimeout: Duration(seconds: 30),
      ),
      simawaRepository: SimawaRepository(apiService: api),
      authService: AuthService(apiService: api, tokenStorage: storage),
      alumniService: AlumniService(apiService: api),
      dashboardService: DashboardService(apiService: api),
      tracerService: TracerService(apiService: api),
      ikaService: IkaService(apiService: api),
      jobService: JobService(apiService: api),
      eventService: EventService(apiService: api),
      batchmateService: BatchmateService(apiService: api),
      notificationService: NotificationService(apiService: api),
      informationService: InformationService(apiService: api),
    );
    await appState.initializeAuthFlow();
    return _Harness(appState, api, storage);
  }
}

class _MemoryTokenStorage implements AuthTokenStorage {
  String? token;

  @override
  Future<void> clearAccessToken() async {
    token = null;
  }

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<void> saveAccessToken(String value) async {
    token = value;
  }
}

class _ScriptedApi implements ApiService {
  ApiResponse<Map<String, dynamic>> deleteResult = ApiResponse.success(
    statusCode: 200,
    message: 'Akun JejakGS berhasil dihapus.',
  );
  Future<void>? deleteGate;
  int deleteCalls = 0;
  String? lastDeletePath;
  Map<String, dynamic>? lastDeleteBody;

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) async {
    final json = path == '/profile' ? _profileJson : <String, dynamic>{};
    return ApiResponse.success(
      statusCode: 200,
      data: decoder == null ? json as T? : decoder(json),
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
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) async {
    deleteCalls += 1;
    lastDeletePath = path;
    lastDeleteBody = body;
    if (deleteGate != null) {
      await deleteGate;
    }
    final result = deleteResult;
    return ApiResponse<T>.failure(
      statusCode: result.statusCode,
      message: result.message,
      errors: result.errors,
    ).copyWithStatus(result.status);
  }

  @override
  Future<ApiResponse<T>> postMultipart<T>(
    String path, {
    String? fieldName,
    String? fileName,
    List<int>? bytes,
    String? contentType,
    List<ApiMultipartFile>? additionalFiles,
    Map<String, String>? fields,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) {
    throw UnimplementedError();
  }
}

const _profileJson = {
  'nim': '18182008',
  'name': 'Alumni Uji',
  'program_study': 'Keperawatan',
  'batch_year': 2018,
  'graduation_year': 2022,
  'verification_status': 'verified',
  'role': 'alumni',
};
