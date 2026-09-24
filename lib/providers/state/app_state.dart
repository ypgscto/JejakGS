import 'package:flutter/foundation.dart';

import '../../config/app_config.dart';
import '../../models/models.dart';
import '../../repositories/simawa_repository.dart';
import '../../services/services.dart';

enum AuthFlowStatus {
  splash,
  unauthenticated,
  activation,
  completingProfile,
  waitingVerification,
  authenticated,
}

enum AlumniFeature {
  dashboard,
  tracer,
  ika,
  batchmates,
  alumniCard,
  ikaCard,
  ikaMember,
  ikaOfficer,
}

class AppState extends ChangeNotifier {
  AppState({
    required this.config,
    required this.simawaRepository,
    required this.authService,
    required this.alumniService,
    required this.dashboardService,
    required this.tracerService,
    required this.ikaService,
    required this.jobService,
    required this.eventService,
    required this.batchmateService,
    required this.notificationService,
    required this.informationService,
  });

  final AppConfig config;
  final SimawaRepository simawaRepository;
  final AuthService authService;
  final AlumniService alumniService;
  final DashboardService dashboardService;
  final TracerService tracerService;
  final IkaService ikaService;
  final JobService jobService;
  final EventService eventService;
  final BatchmateService batchmateService;
  final NotificationService notificationService;
  final InformationService informationService;

  AuthFlowStatus _authFlowStatus = AuthFlowStatus.splash;
  AlumniProfile? _alumniProfile;
  DashboardSummary? _dashboardSummary;
  bool _isBusy = false;
  bool _isDashboardLoading = false;
  int _unreadNotificationCount = 0;
  String? _errorMessage;
  String? _infoMessage;
  String? _dashboardErrorMessage;
  bool _isDeletingAccount = false;

  AuthFlowStatus get authFlowStatus => _authFlowStatus;

  AlumniProfile? get alumniProfile => _alumniProfile;

  DashboardSummary? get dashboardSummary => _dashboardSummary;

  bool get isBusy => _isBusy;

  bool get isDashboardLoading => _isDashboardLoading;

  int get unreadNotificationCount => _unreadNotificationCount;

  String? get errorMessage => _errorMessage;

  String? get infoMessage => _infoMessage;

  String? get dashboardErrorMessage => _dashboardErrorMessage;

  String get apiStatusLabel {
    if (config.isSimawaApiConfigured) {
      return 'Base URL SIMAWA-GS siap digunakan';
    }

    return 'Base URL SIMAWA-GS belum dikonfigurasi';
  }

  String get apiStatusDescription {
    if (config.isSimawaApiConfigured) {
      return config.simawaGsBaseUrl;
    }

    return 'Tambahkan --dart-define=SIMAWA_GS_BASE_URL=<base-url> saat menjalankan aplikasi.';
  }

  bool get isAlumniVerified {
    return _alumniProfile?.verificationStatus.state ==
        AlumniVerificationState.verified;
  }

  bool get canAccessBasicAlumniFeatures {
    final profile = _alumniProfile;
    if (!_isVerified(profile)) {
      return false;
    }

    return _hasAnyRole(profile, const {
      AlumniRole.alumni,
      AlumniRole.ikaMember,
      AlumniRole.ikaOfficer,
      AlumniRole.alumniAdmin,
      AlumniRole.superAdmin,
    });
  }

  bool get canAccessIkaMemberFeatures {
    final profile = _alumniProfile;
    if (!_isVerified(profile)) {
      return false;
    }

    if (profile?.ikaStatus.canAccessMemberFeatures == true) {
      return true;
    }

    return _hasAnyRole(profile, const {
      AlumniRole.ikaMember,
      AlumniRole.ikaOfficer,
      AlumniRole.alumniAdmin,
      AlumniRole.superAdmin,
    });
  }

  bool get canAccessIkaOfficerFeatures {
    final profile = _alumniProfile;
    if (!_isVerified(profile)) {
      return false;
    }

    return _hasAnyRole(profile, const {
      AlumniRole.ikaOfficer,
      AlumniRole.alumniAdmin,
      AlumniRole.superAdmin,
    });
  }

  bool canAccessFeature(AlumniFeature feature) {
    switch (feature) {
      case AlumniFeature.dashboard:
      case AlumniFeature.tracer:
      case AlumniFeature.ika:
      case AlumniFeature.batchmates:
      case AlumniFeature.alumniCard:
        return canAccessBasicAlumniFeatures;
      case AlumniFeature.ikaCard:
      case AlumniFeature.ikaMember:
        return canAccessIkaMemberFeatures;
      case AlumniFeature.ikaOfficer:
        return canAccessIkaOfficerFeatures;
    }
  }

  String accessDeniedMessage(AlumniFeature feature) {
    final profile = _alumniProfile;
    final state = profile?.verificationStatus.state;

    if (state != AlumniVerificationState.verified) {
      return switch (state) {
        AlumniVerificationState.declined =>
          profile?.verificationStatus.displayNote ??
              'Pengajuan alumni Anda ditolak. Silakan perbaiki data lalu kirim verifikasi ulang.',
        AlumniVerificationState.revisionRequired =>
          profile?.verificationStatus.displayNote ??
              'Akun Anda memerlukan perbaikan data. Silakan perbaiki data profil lalu kirim ulang.',
        AlumniVerificationState.inactive =>
          'Akun alumni Anda sedang inactive sehingga fitur utama belum dapat diakses.',
        AlumniVerificationState.unverified ||
        AlumniVerificationState.rejected ||
        AlumniVerificationState.unknown ||
        null =>
          'Fitur ini hanya tersedia untuk akun alumni dengan status verified.',
        AlumniVerificationState.verified => '',
        AlumniVerificationState.pending =>
          'Akun alumni Anda masih menunggu verifikasi. Fitur alumni aktif setelah status verified.',
      };
    }

    return switch (feature) {
      AlumniFeature.ikaCard || AlumniFeature.ikaMember =>
        'Fitur ini hanya tersedia untuk alumni verified dengan role ika_member atau lebih tinggi.',
      AlumniFeature.ikaOfficer =>
        'Fitur ini hanya tersedia untuk alumni verified dengan role ika_officer atau lebih tinggi.',
      _ => 'Role akun Anda belum memiliki akses ke fitur ini.',
    };
  }

  Future<void> initializeAuthFlow() async {
    _setBusy(true);
    _setError(null);

    final token = await authService.readToken();
    if (token == null || token.trim().isEmpty) {
      _setFlow(AuthFlowStatus.unauthenticated);
      _setBusy(false);
      return;
    }

    await _loadProfileAfterAuthenticated();
    _setBusy(false);
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    _setBusy(true);
    _setError(null);
    _setInfo(null);

    final response = await authService.login(
      identifier: identifier,
      password: password,
    );

    if (!response.isSuccess) {
      await _handleFailedResponse(response);
      _setBusy(false);
      return;
    }

    await _loadProfileAfterAuthenticated();
    _setBusy(false);
  }

  Future<void> activateAlumni({
    required String identifier,
    required String activationCode,
    String? password,
  }) async {
    _setBusy(true);
    _setError(null);

    final response = await authService.activate(
      identifier: identifier,
      activationCode: activationCode,
      password: password,
    );

    if (!response.isSuccess) {
      await _handleFailedResponse(response);
      _setBusy(false);
      return;
    }

    final token = await authService.readToken();
    if (token == null || token.trim().isEmpty) {
      _setFlow(AuthFlowStatus.unauthenticated);
      _setError(
        'Aktivasi berhasil. Silakan login menggunakan akun SIMAWA-GS/SIAKAD-GS.',
      );
      _setBusy(false);
      return;
    }

    await _loadProfileAfterAuthenticated();
    _setBusy(false);
  }

  Future<bool> registerAlumni({
    required String email,
    required String name,
    required String password,
    required String passwordConfirmation,
    required String nim,
  }) async {
    _setBusy(true);
    _setError(null);

    final response = await authService.registerAlumni(
      email: email,
      name: name,
      password: password,
      passwordConfirmation: passwordConfirmation,
      nim: nim,
    );

    if (!response.isSuccess) {
      await _handleFailedResponse(response);
      _setBusy(false);
      return false;
    }

    final token = await authService.readToken();
    if (token == null || token.trim().isEmpty) {
      _setError(null);
      _setBusy(false);
      return true;
    }

    await _loadProfileAfterAuthenticated();
    _setBusy(false);
    return true;
  }

  Future<bool> resendVerificationEmail(String email) async {
    _setBusy(true);
    _setError(null);

    final response = await authService.resendVerificationEmail(email: email);
    if (!response.isSuccess) {
      await _handleFailedResponse(response);
      _setBusy(false);
      return false;
    }

    _setBusy(false);
    return true;
  }

  Future<void> completeProfile(Map<String, dynamic> payload) async {
    _setBusy(true);
    _setError(null);

    final response = await alumniService.updateProfile(payload);
    if (!response.isSuccess) {
      await _handleFailedResponse(response);
      _setBusy(false);
      return;
    }

    await _loadProfileAfterAuthenticated();
    _setBusy(false);
  }

  Future<bool> submitVerificationProfile({
    required Map<String, String> fields,
    List<int>? diplomaPhotoBytes,
    String? diplomaPhotoFileName,
    List<int>? profilePhotoBytes,
    String? profilePhotoFileName,
  }) async {
    _setBusy(true);
    _setError(null);

    final response = await alumniService.submitVerification(
      fields: fields,
      diplomaPhotoBytes: diplomaPhotoBytes,
      diplomaPhotoFileName: diplomaPhotoFileName,
      profilePhotoBytes: profilePhotoBytes,
      profilePhotoFileName: profilePhotoFileName,
    );
    if (!response.isSuccess) {
      await _handleFailedResponse(response);
      _setBusy(false);
      return false;
    }

    await _loadProfileAfterAuthenticated();
    _setBusy(false);
    return true;
  }

  Future<bool> updateProfilePhoto({
    required List<int> bytes,
    required String fileName,
  }) async {
    _setBusy(true);
    _setError(null);

    final response = await alumniService.updateProfilePhoto(
      bytes: bytes,
      fileName: fileName,
    );
    if (!response.isSuccess) {
      await _handleFailedResponse(response);
      _setBusy(false);
      return false;
    }

    await _loadProfileAfterAuthenticated();
    _setBusy(false);
    return true;
  }

  Future<void> logout() async {
    _setBusy(true);
    await authService.clearToken();
    _clearAuthenticatedState();
    _setFlow(AuthFlowStatus.unauthenticated);
    _setBusy(false);
  }

  Future<bool> deleteAccount(String password) async {
    if (_isDeletingAccount) {
      return false;
    }

    _isDeletingAccount = true;
    _setBusy(true);
    _setError(null);

    try {
      final response = await authService.deleteAccount(password: password);
      if (!response.isSuccess) {
        if (response.statusCode == 401) {
          await authService.clearToken();
          _clearAuthenticatedState();
          _setInfo(null);
          _setError('Sesi Anda telah berakhir. Silakan login kembali.');
          _setFlow(AuthFlowStatus.unauthenticated);
          return false;
        }

        _setError(_deleteAccountErrorMessage(response, password));
        return false;
      }

      await authService.clearToken();
      _clearAuthenticatedState();
      _setError(null);
      _setInfo('Akun JejakGS Anda berhasil dihapus.');
      _setFlow(AuthFlowStatus.unauthenticated);
      return true;
    } finally {
      _isDeletingAccount = false;
      _setBusy(false);
    }
  }

  void showActivation() {
    _setError(null);
    _setFlow(AuthFlowStatus.activation);
  }

  void showLogin() {
    _setError(null);
    _setInfo(null);
    _setFlow(AuthFlowStatus.unauthenticated);
  }

  void showCompleteProfile() {
    _setError(null);
    _setFlow(AuthFlowStatus.completingProfile);
  }

  void showWaitingVerification() {
    _setError(null);
    _setFlow(AuthFlowStatus.waitingVerification);
  }

  Future<void> refreshProfile() async {
    _setBusy(true);
    _setError(null);
    await _loadProfileAfterAuthenticated();
    _setBusy(false);
  }

  Future<void> loadDashboard({bool forceRefresh = false}) async {
    if (_isDashboardLoading) {
      return;
    }

    if (_dashboardSummary != null && !forceRefresh) {
      return;
    }

    _setDashboardLoading(true);
    _setDashboardError(null);

    final response = await dashboardService.getSummary();
    if (!response.isSuccess) {
      await _handleFailedResponse(response);
      if (response.statusCode != 401) {
        _setDashboardError(
          response.message ?? 'Dashboard SIMAWA-GS belum dapat dimuat.',
        );
      }
      _setDashboardLoading(false);
      return;
    }

    _dashboardSummary = response.data;
    _setDashboardLoading(false);
  }

  Future<void> loadUnreadNotifications() async {
    final response = await notificationService.getNotifications(
      filters: {'is_read': false},
    );
    if (response.isSuccess) {
      _unreadNotificationCount = response.data?.length ?? 0;
      notifyListeners();
    }
  }

  void setUnreadNotificationCount(int value) {
    _unreadNotificationCount = value;
    notifyListeners();
  }

  Future<void> _loadProfileAfterAuthenticated() async {
    final response = await alumniService.getProfile();

    if (!response.isSuccess) {
      await _handleFailedResponse(response);
      return;
    }

    _alumniProfile = AlumniProfile.fromJson(response.data);
    _setFlow(_resolveFlowForProfile(_alumniProfile!));
  }

  AuthFlowStatus _resolveFlowForProfile(AlumniProfile profile) {
    if (!profile.isComplete) {
      return AuthFlowStatus.completingProfile;
    }

    if (profile.verificationStatus.state != AlumniVerificationState.verified) {
      return AuthFlowStatus.waitingVerification;
    }

    return AuthFlowStatus.authenticated;
  }

  bool _isVerified(AlumniProfile? profile) {
    return profile?.verificationStatus.state ==
        AlumniVerificationState.verified;
  }

  bool _hasAnyRole(AlumniProfile? profile, Set<AlumniRole> roles) {
    if (profile == null) {
      return false;
    }

    return roles.contains(profile.role);
  }

  Future<void> _handleFailedResponse(ApiResponse<dynamic> response) async {
    if (response.statusCode == 401) {
      await authService.clearToken();
      _clearAuthenticatedState();
      _setFlow(AuthFlowStatus.unauthenticated);
      _setError('Sesi tidak valid atau sudah berakhir. Silakan login kembali.');
      return;
    }

    _setError(response.message ?? 'Permintaan ke SIMAWA-GS gagal.');
  }

  void _setFlow(AuthFlowStatus value) {
    _authFlowStatus = value;
    notifyListeners();
  }

  void _setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  void _setInfo(String? value) {
    _infoMessage = value;
    notifyListeners();
  }

  void _clearAuthenticatedState() {
    _alumniProfile = null;
    _dashboardSummary = null;
    _dashboardErrorMessage = null;
    _unreadNotificationCount = 0;
  }

  String _deleteAccountErrorMessage(
    ApiResponse<dynamic> response,
    String password,
  ) {
    if (response.statusCode == 403) {
      return 'Akun ini tidak dapat dihapus melalui JejakGS.';
    }

    if (response.statusCode == 422) {
      final backendMessage = response.message?.trim();
      if (backendMessage != null &&
          backendMessage.isNotEmpty &&
          !backendMessage.contains(password)) {
        return backendMessage;
      }

      return 'Password yang Anda masukkan tidak sesuai.';
    }

    return 'Akun belum dihapus. Periksa koneksi Anda dan coba kembali.';
  }

  void _setDashboardLoading(bool value) {
    _isDashboardLoading = value;
    notifyListeners();
  }

  void _setDashboardError(String? value) {
    _dashboardErrorMessage = value;
    notifyListeners();
  }
}
