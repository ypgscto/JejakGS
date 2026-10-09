import 'package:flutter/foundation.dart';

import '../../models/models.dart';
import '../../services/alumni_service.dart';

class AlumniEducationState extends ChangeNotifier {
  AlumniEducationState({
    required this.service,
    required this.canAccess,
    required this.onExpiredSession,
  });

  final AlumniService service;
  final bool Function() canAccess;
  final Future<void> Function() onExpiredSession;

  AlumniEducationOverview? overview;
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;
  String? submissionError;
  Map<String, String> fieldErrors = {};
  bool _disposed = false;

  bool get canSubmit => canAccess() && overview != null && !isSubmitting;

  Future<void> load() async {
    if (isLoading || _disposed) return;
    if (!canAccess()) {
      overview = null;
      errorMessage =
          'Riwayat pendidikan tersedia setelah akun alumni terverifikasi.';
      _notify();
      return;
    }
    isLoading = true;
    errorMessage = null;
    _notify();
    try {
      final response = await service.getEducationHistory();
      if (_disposed) return;
      if (response.statusCode == 401) {
        overview = null;
        await onExpiredSession();
      } else if (!canAccess()) {
        overview = null;
      } else if (response.isSuccess &&
          response.data != null &&
          response.data!.identityId > 0 &&
          response.data!.primaryAlumniId > 0) {
        overview = response.data;
      } else {
        // A stale overview must not permit a submission after a failed refresh.
        overview = null;
        errorMessage = _message(response);
      }
    } on Object {
      if (!_disposed) {
        overview = null;
        errorMessage =
            'Riwayat pendidikan belum dapat dimuat. Silakan coba lagi.';
      }
    } finally {
      isLoading = false;
      _notify();
    }
  }

  Future<bool> submit({
    required String nim,
    required String ownershipNote,
    required List<int> diplomaBytes,
    required String diplomaFileName,
  }) async {
    if (!canSubmit || _disposed) return false;
    submissionError = null;
    fieldErrors = validate(nim, ownershipNote, diplomaBytes, diplomaFileName);
    if (fieldErrors.isNotEmpty) {
      _notify();
      return false;
    }
    isSubmitting = true;
    _notify();
    try {
      final response = await service.requestEducation(
        nim: nim,
        ownershipNote: ownershipNote,
        diplomaBytes: diplomaBytes,
        diplomaFileName: diplomaFileName,
      );
      if (_disposed) return false;
      if (response.statusCode == 401) {
        overview = null;
        await onExpiredSession();
        return false;
      }
      if (!canAccess()) return false;
      if (!response.isSuccess) {
        submissionError = response.statusCode == 0
            ? 'Pengajuan belum dapat dikonfirmasi. Kembali ke riwayat dan perbarui status sebelum mencoba lagi.'
            : _message(response);
        if (response.statusCode == 400 || response.statusCode == 422) {
          final errors = response.errors ?? {};
          if (errors.containsKey('nim')) {
            fieldErrors['nim'] =
                _businessMessage(errors['nim']) ??
                'NIM belum dapat diajukan. Hubungi Bagian Alumni untuk pemeriksaan.';
          }
          if (errors.containsKey('ownership_note')) {
            fieldErrors['ownership_note'] =
                'Isi penjelasan kepemilikan sebanyak 20–2000 karakter.';
          }
          if (errors.containsKey('diploma_photo')) {
            fieldErrors['diploma_photo'] =
                'Pilih foto ijazah JPG/JPEG/PNG, maksimal 5 MB.';
          }
        }
        return false;
      }
      // Submission only adds an application; account/profile/IKA stay unchanged.
      await load();
      return true;
    } on Object {
      if (!_disposed) {
        submissionError =
            'Pengajuan belum dapat dikonfirmasi. Periksa riwayat sebelum mencoba kembali.';
      }
      return false;
    } finally {
      isSubmitting = false;
      _notify();
    }
  }

  Map<String, String> validate(
    String nim,
    String note,
    List<int> bytes,
    String fileName,
  ) {
    final errors = <String, String>{};
    final normalized = nim.trim();
    if (normalized.isEmpty || normalized.length > 50) {
      errors['nim'] = 'Masukkan NIM pendidikan tambahan, maksimal 50 karakter.';
    } else if (overview?.educations.any((item) => item.nim == normalized) ==
        true) {
      errors['nim'] = 'NIM ini sudah terhubung dengan akun Anda.';
    } else if (overview?.requests.any(
          (item) =>
              item.nim == normalized &&
              (item.status == EducationRequestStatus.pending ||
                  item.status == EducationRequestStatus.verified),
        ) ==
        true) {
      errors['nim'] = 'NIM ini sudah diajukan atau sudah disetujui.';
    }
    if (note.trim().length < 20 || note.trim().length > 2000) {
      errors['ownership_note'] =
          'Isi penjelasan kepemilikan sebanyak 20–2000 karakter.';
    }
    if (!isValidDiploma(bytes, fileName)) {
      errors['diploma_photo'] =
          'Pilih foto ijazah JPG/JPEG/PNG, maksimal 5 MB.';
    }
    return errors;
  }

  static bool isValidDiploma(List<int> bytes, String fileName) {
    if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) return false;
    final extension = fileName.split('.').last.toLowerCase();
    if (extension == 'jpg' || extension == 'jpeg') {
      return bytes.length >= 3 &&
          bytes[0] == 0xff &&
          bytes[1] == 0xd8 &&
          bytes[2] == 0xff;
    }
    if (extension == 'png') {
      const signature = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
      return bytes.length >= signature.length &&
          listEquals(bytes.take(signature.length).toList(), signature);
    }
    return false;
  }

  String _message(
    ApiResponse<dynamic> response,
  ) => switch (response.statusCode) {
    0 => 'Tidak dapat terhubung. Periksa koneksi internet dan coba lagi.',
    401 => 'Sesi Anda telah berakhir. Silakan login kembali.',
    403 =>
      'Akses riwayat pendidikan belum diizinkan. Periksa status akun atau hubungi Bagian Alumni.',
    404 => 'Layanan riwayat pendidikan belum tersedia. Hubungi Bagian Alumni.',
    400 || 422 =>
      _businessMessage(response.errors?['nim']) ??
          'Periksa NIM, penjelasan kepemilikan, dan foto ijazah Anda.',
    429 => 'Terlalu banyak pengajuan. Tunggu sebentar sebelum mencoba kembali.',
    _ =>
      'Layanan riwayat pendidikan sedang mengalami kendala. Silakan coba lagi.',
  };

  String? _businessMessage(Object? value) {
    final message = value is List && value.isNotEmpty ? value.first : value;
    if (message is! String ||
        message.length > 300 ||
        !RegExp(
          r'^(NIM|Riwayat ini|Data alumni|Akun alumni)\b',
        ).hasMatch(message) ||
        RegExp(
          r'sql|exception|trace|https?://|[<>\r\n]',
          caseSensitive: false,
        ).hasMatch(message)) {
      return null;
    }
    return message;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    overview = null;
    super.dispose();
  }
}
