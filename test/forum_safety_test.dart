import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jejak_gs/config/app_config.dart';
import 'package:jejak_gs/forum/forum_safety.dart';
import 'package:jejak_gs/models/api_response.dart';
import 'package:jejak_gs/providers/state/app_state.dart';
import 'package:jejak_gs/repositories/simawa_repository.dart';
import 'package:jejak_gs/screens/ika_payment_screen.dart';
import 'package:jejak_gs/screens/profile_screen.dart';
import 'package:jejak_gs/widgets/design_system/primary_button.dart';
import 'package:jejak_gs/services/services.dart';

void main() {
  test('report reasons map to backend values', () {
    expect(forumReportReasons.map((item) => item.$1).toList(), [
      'inappropriate_content',
      'harassment',
      'spam',
      'misinformation',
      'other',
    ]);
    expect(forumReportReasons.map((item) => item.$2).toList(), [
      'Konten tidak pantas',
      'Pelecehan',
      'Spam',
      'Informasi menyesatkan',
      'Lainnya',
    ]);
  });

  test('HTTP 429 uses the rate limit message', () {
    expect(
      forumActionMessage(ApiResponse.failure(statusCode: 429, message: 'Too Many Attempts.')),
      'Anda melakukan terlalu banyak tindakan. Silakan coba beberapa saat lagi.',
    );
  });

  testWidgets('Report Post appears for another alumni and not for own post', (tester) async {
    final api = _ForumApi()
      ..posts = [
        _post(id: '1', title: 'Post orang lain', owner: false, authorId: '9'),
        _post(id: '2', title: 'Post saya', owner: true, authorId: '1'),
      ];
    await tester.pumpWidget(_forumApp(_appState(api)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Umum'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Tindakan'), findsOneWidget);
    await tester.tap(find.byTooltip('Tindakan'));
    await tester.pumpAndSettle();
    expect(find.text('Laporkan Post'), findsOneWidget);
    expect(find.text('Blokir Alumni'), findsOneWidget);
  });

  testWidgets('Report Comment appears for another alumni comment', (tester) async {
    final post = _post(
        id: '1',
        title: 'Utas',
        owner: true,
        authorId: '1',
        comments: [
          {
            'id': '8',
            'content': 'Komentar orang lain',
            'is_owner': false,
            'author': {'id': '9', 'name': 'Budi'},
          },
        ],
      );
    final api = _ForumApi()
      ..posts = [post]
      ..detail = post;
    await tester.pumpWidget(_forumApp(_appState(api)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Umum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Utas'));
    await tester.pumpAndSettle();

    expect(find.text('Komentar orang lain'), findsOneWidget);
    await tester.tap(find.byTooltip('Tindakan'));
    await tester.pumpAndSettle();
    expect(find.text('Laporkan Komentar'), findsOneWidget);
  });

  testWidgets('successful report shows confirmation and sends the mapped reason', (tester) async {
    final api = _ForumApi()..posts = [_post(id: '1', title: 'Post orang lain', owner: false, authorId: '9')];
    await tester.pumpWidget(_forumApp(_appState(api)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Umum'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tindakan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laporkan Post'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kirim Laporan'));
    await tester.pumpAndSettle();

    expect(find.text('Terima kasih. Laporan Anda telah dikirim untuk ditinjau.'), findsOneWidget);
    expect(api.lastPostPath, '/api/alumni/ika/forum/posts/1/report');
    expect(api.lastPostBody?['reason'], 'spam');
  });

  testWidgets('duplicate report shows the pending message', (tester) async {
    final api = _ForumApi()
      ..posts = [_post(id: '1', title: 'Post orang lain', owner: false, authorId: '9')]
      ..postResult = ApiResponse.failure(
        statusCode: 422,
        message: 'Laporan untuk konten ini masih menunggu tinjauan.',
      );
    await tester.pumpWidget(_forumApp(_appState(api)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Umum'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tindakan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laporkan Post'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kirim Laporan'));
    await tester.pumpAndSettle();

    expect(find.text('Konten ini sudah pernah Anda laporkan dan sedang ditinjau.'), findsOneWidget);
  });

  testWidgets('block asks for confirmation and refresh hides the author', (tester) async {
    final api = _ForumApi()..posts = [_post(id: '1', title: 'Post orang lain', owner: false, authorId: '9')];
    await tester.pumpWidget(_forumApp(_appState(api)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Umum'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tindakan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blokir Alumni'));
    await tester.pumpAndSettle();

    expect(find.text('Blokir alumni ini?'), findsOneWidget);
    api.posts = const [];
    await tester.tap(find.widgetWithText(TextButton, 'Blokir'));
    await tester.pumpAndSettle();

    expect(find.text('Alumni berhasil diblokir.'), findsOneWidget);
    expect(find.text('Post orang lain'), findsNothing);
    expect(api.lastPostPath, '/api/alumni/ika/forum/users/9/block');
  });

  testWidgets('block is not offered on the current user post', (tester) async {
    final api = _ForumApi()..posts = [_post(id: '2', title: 'Post saya', owner: true, authorId: '1')];
    await tester.pumpWidget(_forumApp(_appState(api)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Umum'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Tindakan'), findsNothing);
    expect(find.text('Blokir Alumni'), findsNothing);
  });

  testWidgets('blocked users screen opens from account settings and unblock succeeds', (tester) async {
    final api = _ForumApi()
      ..blocked = [
        {'alumni_id': '9', 'name': 'Budi', 'prodi': 'Keperawatan', 'tahun_angkatan': '2020'},
      ];
    await tester.pumpWidget(_profileApp(_appState(api)));
    await tester.pump();
    await tester.tap(find.text('Pengaturan Akun'));
    await tester.pump();
    await tester.tap(find.text('Alumni Diblokir'));
    await tester.pumpAndSettle();

    expect(find.text('Budi'), findsOneWidget);
    expect(find.text('Keperawatan'), findsOneWidget);
    await tester.tap(find.text('Buka Blokir'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Buka Blokir'));
    await tester.pumpAndSettle();

    expect(find.text('Blokir berhasil dibuka.'), findsOneWidget);
    expect(find.text('Budi'), findsNothing);
    expect(api.lastDeletePath, '/api/alumni/ika/forum/users/9/block');
  });

  testWidgets('support contact is shown from the forum', (tester) async {
    final api = _ForumApi();
    await tester.pumpWidget(_forumApp(_appState(api)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bantuan & Pelaporan'));
    await tester.pumpAndSettle();

    expect(find.text('support@stikesgunungsari.ac.id'), findsOneWidget);
    expect(find.text('https://stikesgunungsari.ac.id'), findsOneWidget);
    expect(find.text('0811-4610-095'), findsOneWidget);
    expect(api.lastGetPath, '/api/alumni/ika/forum/support');
  });

  testWidgets('content filter validation is shown when creating a post', (tester) async {
    final api = _ForumApi()
      ..postResult = ApiResponse.failure(
        statusCode: 422,
        message: 'Konten mengandung kata atau ungkapan yang tidak diperbolehkan.',
      );
    await tester.pumpWidget(_forumApp(_appState(api)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Umum'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buat Postingan'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Judul postingan'), 'Judul');
    await tester.enterText(find.widgetWithText(TextField, 'Isi postingan'), 'kata kasar');
    await tester.tap(find.text('Kirim Postingan'));
    await tester.pumpAndSettle();

    expect(
      find.text('Konten mengandung kata atau ungkapan yang tidak diperbolehkan.'),
      findsOneWidget,
    );
  });

  testWidgets('network failure does not log the user out', (tester) async {
    final storage = _MemoryTokenStorage()..token = 'token-uji';
    final api = _ForumApi()
      ..posts = [_post(id: '1', title: 'Post orang lain', owner: false, authorId: '9')]
      ..postResult = ApiResponse.failure(statusCode: 0, message: 'gagal jaringan');
    final appState = _appState(api, storage: storage);
    await tester.pumpWidget(_forumApp(appState));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Umum'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tindakan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laporkan Post'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kirim Laporan'));
    await tester.pumpAndSettle();

    expect(
      find.text('Tindakan belum berhasil. Periksa koneksi Anda dan coba kembali.'),
      findsOneWidget,
    );
    expect(storage.token, 'token-uji');
  });

  testWidgets('report submit is not sent twice', (tester) async {
    final gate = Completer<void>();
    final api = _ForumApi()
      ..posts = [_post(id: '1', title: 'Post orang lain', owner: false, authorId: '9')]
      ..postGate = gate.future;
    await tester.pumpWidget(_forumApp(_appState(api)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Umum'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tindakan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laporkan Post'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kirim Laporan'));
    await tester.pump();
    final button = tester
        .widgetList<PrimaryButton>(find.byType(PrimaryButton))
        .singleWhere((item) => item.isLoading);
    expect(button.isLoading, isTrue);
    gate.complete();
    await tester.pumpAndSettle();

    expect(api.postCalls, 1);
  });
}

Widget _forumApp(AppState appState) {
  return MaterialApp(
    home: Scaffold(
      body: IkaForumScreen(appState: appState, onBack: () {}),
    ),
  );
}

Widget _profileApp(AppState appState) {
  return MaterialApp(home: Scaffold(body: ProfileScreen(appState: appState)));
}

AppState _appState(_ForumApi api, {_MemoryTokenStorage? storage}) {
  final tokenStorage = storage ?? (_MemoryTokenStorage()..token = 'token-uji');
  return AppState(
    config: const AppConfig(
      appName: 'JejakGS',
      environment: AppEnvironment.development,
      simawaGsBaseUrl: 'https://simawa.stikes.gunungsari.id/api/mobile',
      apiTimeout: Duration(seconds: 30),
    ),
    simawaRepository: SimawaRepository(apiService: api),
    authService: AuthService(apiService: api, tokenStorage: tokenStorage),
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
}

Map<String, dynamic> _post({
  required String id,
  required String title,
  required bool owner,
  required String authorId,
  List<Map<String, dynamic>> comments = const [],
}) {
  return {
    'id': id,
    'title': title,
    'status': 'published',
    'is_owner': owner,
    'content': 'Isi $title',
    'author': {'id': authorId, 'name': owner ? 'Saya' : 'Budi'},
    'comments': comments,
  };
}

class _MemoryTokenStorage implements AuthTokenStorage {
  String? token;

  @override
  Future<void> clearAccessToken() async => token = null;

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<void> saveAccessToken(String value) async => token = value;
}

class _ForumApi implements ApiService {
  List<Map<String, dynamic>> posts = const [];
  Map<String, dynamic>? detail;
  List<Map<String, dynamic>> blocked = const [];
  ApiResponse<Map<String, dynamic>> postResult = ApiResponse.success(
    statusCode: 201,
    data: {'id': '1', 'status': 'pending'},
  );
  ApiResponse<Map<String, dynamic>> deleteResult = ApiResponse.success(statusCode: 200);
  Future<void>? postGate;
  int postCalls = 0;
  String? lastPostPath;
  String? lastDeletePath;
  String? lastGetPath;
  Map<String, dynamic>? lastPostBody;

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) async {
    lastGetPath = path;
    final Object json = switch (path) {
      '/api/alumni/ika/forum/categories' => [
        {'id': '1', 'name': 'Umum'},
      ],
      '/api/alumni/ika/forum/posts' => posts,
      '/api/alumni/ika/forum/blocked-users' => blocked,
      '/api/alumni/ika/forum/support' => {
        'email': 'support@stikesgunungsari.ac.id',
        'website': 'https://stikesgunungsari.ac.id',
        'whatsapp': '0811-4610-095',
      },
      _ => detail ?? posts.firstWhere((post) => path.endsWith('/${post['id']}')),
    };
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
  }) async {
    postCalls += 1;
    lastPostPath = path;
    lastPostBody = body;
    final gate = postGate;
    if (gate != null) await gate;
    if (!postResult.isSuccess) {
      return ApiResponse<T>.failure(
        statusCode: postResult.statusCode,
        message: postResult.message,
      );
    }
    return ApiResponse<T>.success(
      statusCode: postResult.statusCode,
      data: postResult.data as T?,
      message: postResult.message,
    );
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
    lastDeletePath = path;
    return deleteResult as ApiResponse<T>;
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) =>
      throw UnimplementedError();

  @override
  Future<ApiResponse<T>> patch<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) =>
      throw UnimplementedError();

  @override
  Future<ApiResponse<T>> postMultipart<T>(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    String? fieldName,
    String? fileName,
    List<int>? bytes,
    String? contentType,
    List<ApiMultipartFile>? additionalFiles,
    bool requiresAuth = true,
    T Function(Object? json)? decoder,
  }) =>
      throw UnimplementedError();
}
