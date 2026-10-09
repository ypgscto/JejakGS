import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jejak_gs/config/app_config.dart';
import 'package:jejak_gs/models/models.dart';
import 'package:jejak_gs/providers/state/alumni_education_state.dart';
import 'package:jejak_gs/providers/state/app_state.dart';
import 'package:jejak_gs/repositories/simawa_repository.dart';
import 'package:jejak_gs/screens/alumni_education_screen.dart';
import 'package:jejak_gs/screens/profile_screen.dart';
import 'package:jejak_gs/services/services.dart';
import 'package:jejak_gs/themes/app_theme.dart';

const _png = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0];
const _note =
    'Saya melanjutkan pendidikan melalui jalur RPL di institusi yang sama.';

void main() {
  test('unverified accounts cannot load or submit education', () async {
    final api = _EducationApi();
    final state = _state(api, canAccess: () => false);
    await state.load();
    expect(await _submit(state), isFalse);
    expect(api.educationGetCalls, 0);
    expect(api.multipartCalls, 0);
    expect(state.overview, isNull);
    state.dispose();
  });

  test(
    'only approved links are displayed as education; unknown status stays locked',
    () {
      final overview = AlumniEducationOverview.fromJson(_overviewJson);
      expect(overview.educations.single.nim, 'ED001');
      expect(overview.requests.single.status.canResubmit, isTrue);
      expect(EducationRequestStatus.parse('unexpected').canResubmit, isFalse);
      expect(AlumniEducationOverview.fromJson({}).educations, isEmpty);
      expect(AlumniEducation.fromJson({'nim': 'X'}).isActive, isFalse);
    },
  );

  test(
    'required data, existing NIM and oversized or disguised evidence are rejected',
    () async {
      final api = _EducationApi();
      final state = _state(api);
      await state.load();
      expect(
        state.validate('ED001', '', [], '').keys,
        containsAll(['nim', 'ownership_note', 'diploma_photo']),
      );
      expect(state.validate('ED002', _note, _png, 'diploma.PNG'), isEmpty);
      expect(
        AlumniEducationState.isValidDiploma([1, 2, 3], 'diploma.jpg'),
        isFalse,
      );
      expect(
        AlumniEducationState.isValidDiploma(_png, 'document.pdf'),
        isFalse,
      );
      expect(
        AlumniEducationState.isValidDiploma(
          List.filled(5 * 1024 * 1024 + 1, 0),
          'large.png',
        ),
        isFalse,
      );
      expect(
        await state.submit(
          nim: 'ED001',
          ownershipNote: _note,
          diplomaBytes: _png,
          diplomaFileName: 'diploma.png',
        ),
        isFalse,
      );
      expect(api.multipartCalls, 0);
      state.dispose();
    },
  );

  test('pending request cannot be submitted again', () async {
    final api = _EducationApi();
    api.overviewJson = {
      ..._overviewJson,
      'requests': [
        {'id': 3, 'nim': 'ED002', 'status': 'pending', 'ownership_note': _note},
      ],
    };
    final state = _state(api);
    await state.load();
    expect(await _submit(state), isFalse);
    expect(api.multipartCalls, 0);
    state.dispose();
  });

  test(
    'resubmission uploads only requested NIM and private evidence and prevents double taps',
    () async {
      final api = _EducationApi();
      final state = _state(api);
      await state.load();
      api.submitGate = Completer<void>();
      final first = _submit(state);
      final second = await _submit(state);
      expect(second, isFalse);
      expect(api.multipartCalls, 1);
      api.submitGate!.complete();
      expect(await first, isTrue);
      expect(api.lastMultipartPath, '/profile/education-requests');
      expect(api.lastFields, {'nim': 'ED002', 'ownership_note': _note});
      expect(api.lastFileField, 'diploma_photo');
      expect(api.lastFileName, 'diploma.png');
      expect(
        state.overview!.requests.single.status,
        EducationRequestStatus.pending,
      );
      expect(state.overview!.primaryAlumniId, 10);
      expect(state.isSubmitting, isFalse);
      state.dispose();
    },
  );

  test('401 removes the token and clears the authenticated profile', () async {
    final harness = await _Harness.create();
    harness.api.listFailure = ApiResponse.failure(
      statusCode: 401,
      message: 'Unauthenticated',
    );
    final state = _state(
      harness.api,
      onExpired: harness.appState.handleExpiredSession,
    );
    await state.load();
    expect(harness.storage.token, isNull);
    expect(harness.appState.alumniProfile, isNull);
    expect(harness.appState.authFlowStatus, AuthFlowStatus.unauthenticated);
    expect(state.overview, isNull);
    state.dispose();
    harness.appState.dispose();
  });

  test(
    'API failures do not display SQL, file paths or exception details',
    () async {
      final api = _EducationApi();
      final state = _state(api);
      await state.load();
      api.submitFailure = ApiResponse.failure(
        statusCode: 422,
        errors: {
          'nim': ['NIM SQLSTATE error C:\\secret\\db.php'],
          'diploma_photo': ['diploma_photo backend exception'],
        },
      );
      expect(await _submit(state), isFalse);
      expect(state.submissionError, isNot(contains('SQLSTATE')));
      expect(state.fieldErrors['nim'], isNot(contains('secret')));
      expect(state.fieldErrors['diploma_photo'], contains('JPG/JPEG/PNG'));
      api.listFailure = ApiResponse.failure(
        statusCode: 500,
        message: 'SQLSTATE secret connection string',
      );
      await state.load();
      expect(state.overview, isNull);
      expect(state.errorMessage, isNot(contains('SQLSTATE')));
      expect(state.canSubmit, isFalse);
      state.dispose();
    },
  );

  test('disposing during a request does not update a detached view', () async {
    final api = _EducationApi()..listGate = Completer<void>();
    final state = _state(api);
    final loading = state.load();
    state.dispose();
    api.listGate!.complete();
    await loading;
    expect(state.overview, isNull);
  });

  testWidgets('Profile has an education entry for a verified account', (
    tester,
  ) async {
    final harness = await _Harness.create();
    await tester.pumpWidget(_app(ProfileScreen(appState: harness.appState)));
    await tester.scrollUntilVisible(
      find.text('Riwayat Pendidikan'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Riwayat Pendidikan'));
    await tester.pumpAndSettle();
    expect(find.byType(AlumniEducationScreen), findsOneWidget);
    expect(harness.api.educationGetCalls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    '320px screen shows academic history and an editable revision without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final harness = await _Harness.create();
      await tester.pumpWidget(
        _app(AlumniEducationScreen(appState: harness.appState, onBack: () {})),
      );
      await tester.pumpAndSettle();
      expect(find.text('NIM ED001'), findsOneWidget);
      expect(find.text('Pendidikan utama'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Perbaiki & Kirim Ulang'), 150);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Perbaiki & Kirim Ulang'));
      await tester.pumpAndSettle();
      expect(find.text('Perbaiki Pengajuan'), findsOneWidget);
      expect(
        find.text('Lengkapi bukti ijazah yang lebih jelas.'),
        findsOneWidget,
      );
      final nimField = tester.widget<TextField>(find.byType(TextField).first);
      expect(nimField.controller!.text, 'ED002');
      expect(nimField.enabled, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('absent API shows a retry state without sample alumni', (
    tester,
  ) async {
    final harness = await _Harness.create();
    harness.api.listFailure = ApiResponse.failure(statusCode: 404);
    await tester.pumpWidget(
      _app(AlumniEducationScreen(appState: harness.appState, onBack: () {})),
    );
    await tester.pumpAndSettle();
    expect(find.text('Riwayat belum dapat dimuat'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
    expect(find.text('NIM ED001'), findsNothing);
    expect(find.text('Tambahkan Riwayat Pendidikan'), findsNothing);
  });
}

AlumniEducationState _state(
  _EducationApi api, {
  bool Function()? canAccess,
  Future<void> Function()? onExpired,
}) => AlumniEducationState(
  service: AlumniService(apiService: api),
  canAccess: canAccess ?? () => true,
  onExpiredSession: onExpired ?? () async {},
);

Future<bool> _submit(AlumniEducationState state) => state.submit(
  nim: 'ED002',
  ownershipNote: _note,
  diplomaBytes: _png,
  diplomaFileName: 'diploma.png',
);

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: Scaffold(body: child),
);

class _Harness {
  _Harness(this.appState, this.api, this.storage);
  final AppState appState;
  final _EducationApi api;
  final _Storage storage;

  static Future<_Harness> create() async {
    final api = _EducationApi();
    final storage = _Storage();
    final state = AppState(
      config: const AppConfig(
        appName: 'JejakGS',
        environment: AppEnvironment.development,
        simawaGsBaseUrl: 'https://example.test/api/mobile',
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
    await state.initializeAuthFlow();
    return _Harness(state, api, storage);
  }
}

class _Storage implements AuthTokenStorage {
  String? token = 'test-token';
  @override
  Future<void> clearAccessToken() async => token = null;
  @override
  Future<String?> readAccessToken() async => token;
  @override
  Future<void> saveAccessToken(String value) async => token = value;
}

class _EducationApi implements ApiService {
  Map<String, dynamic> overviewJson = _overviewJson;
  ApiResponse<Map<String, dynamic>>? listFailure;
  ApiResponse<Map<String, dynamic>>? submitFailure;
  Completer<void>? submitGate;
  Completer<void>? listGate;
  int educationGetCalls = 0;
  int multipartCalls = 0;
  String? lastMultipartPath;
  String? lastFileField;
  String? lastFileName;
  Map<String, String>? lastFields;

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) async {
    Object json = {};
    if (path == '/profile') {
      json = {
        'nim': 'ED001',
        'name': 'Alumni Pengujian',
        'program_study': 'Program Pendidikan',
        'batch_year': 2018,
        'graduation_year': 2021,
        'verification_status': 'verified',
        'role': 'alumni',
      };
    } else if (path == '/profile/educations') {
      educationGetCalls++;
      if (listGate != null) await listGate!.future;
      if (listFailure != null) return _failure<T>(listFailure!);
      json = overviewJson;
    }
    return ApiResponse.success(statusCode: 200, data: decoder?.call(json));
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
  }) async {
    multipartCalls++;
    lastMultipartPath = path;
    lastFileField = fieldName;
    lastFileName = fileName;
    lastFields = fields;
    if (submitGate != null) await submitGate!.future;
    if (submitFailure != null) return _failure<T>(submitFailure!);
    final application = {
      'id': 3,
      'nim': 'ED002',
      'status': 'pending',
      'ownership_note': _note,
      'has_diploma_evidence': true,
    };
    overviewJson = {
      ...overviewJson,
      'requests': [application],
    };
    return ApiResponse.success(
      statusCode: 201,
      data: decoder?.call(application),
    );
  }

  ApiResponse<T> _failure<T>(ApiResponse<dynamic> result) =>
      ApiResponse.failure(
        statusCode: result.statusCode,
        message: result.message,
        errors: result.errors,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

const _overviewJson = {
  'identity_id': 1,
  'primary_alumni_id': 10,
  'educations': [
    {
      'id': 1,
      'alumni_id': 10,
      'nim': 'ED001',
      'name': 'Alumni Pengujian',
      'study_program':
          'Diploma Tiga Keperawatan dengan nama program yang panjang',
      'cohort_year': '2018',
      'graduation_year': '2021',
      'is_primary': true,
      'is_active': true,
      'education_verification_status': 'verified',
    },
  ],
  'requests': [
    {
      'id': 3,
      'nim': 'ED002',
      'status': 'revision_required',
      'ownership_note': _note,
      'review_note': 'Lengkapi bukti ijazah yang lebih jelas.',
    },
  ],
};
