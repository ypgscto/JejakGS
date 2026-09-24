import 'json_utils.dart';

enum AlumniVerificationState {
  unverified,
  pending,
  revisionRequired,
  verified,
  declined,
  inactive,
  rejected,
  unknown;

  static AlumniVerificationState fromJson(Object? value) {
    final normalized = value?.toString().toLowerCase().trim();
    final normalizedCamel = normalized?.replaceAll('_', '');

    if (normalized == 'rejected' ||
        normalized == 'ditolak' ||
        normalized == 'decline') {
      return AlumniVerificationState.declined;
    }

    if (normalized == 'perlu_perbaikan' ||
        normalized == 'revision' ||
        normalized == 'revision_needed') {
      return AlumniVerificationState.revisionRequired;
    }

    if (normalized == 'menunggu_verifikasi' || normalized == 'waiting') {
      return AlumniVerificationState.pending;
    }

    if (normalized == 'terverifikasi' || normalized == 'approved') {
      return AlumniVerificationState.verified;
    }

    return AlumniVerificationState.values.firstWhere(
      (state) => state.name.toLowerCase() == normalizedCamel,
      orElse: () => AlumniVerificationState.unknown,
    );
  }

  bool get canResubmitVerification {
    return this == AlumniVerificationState.revisionRequired ||
        this == AlumniVerificationState.declined ||
        this == AlumniVerificationState.rejected ||
        this == AlumniVerificationState.unverified ||
        this == AlumniVerificationState.pending;
  }

  String get defaultLabel {
    return switch (this) {
      AlumniVerificationState.verified => 'Terverifikasi',
      AlumniVerificationState.pending => 'Menunggu Verifikasi',
      AlumniVerificationState.revisionRequired => 'Perlu Perbaikan',
      AlumniVerificationState.declined ||
      AlumniVerificationState.rejected =>
        'Verifikasi Ditolak',
      AlumniVerificationState.inactive => 'Akun Nonaktif',
      AlumniVerificationState.unverified => 'Belum Terverifikasi',
      AlumniVerificationState.unknown => 'Status belum terverifikasi',
    };
  }
}

class AlumniVerificationStatus {
  const AlumniVerificationStatus({
    required this.state,
    this.label,
    this.notes,
    this.adminNote,
    this.institutionContactName,
    this.institutionContactEmail,
    this.institutionContactPhone,
    this.verifiedAt,
    this.rejectedAt,
  });

  final AlumniVerificationState state;
  final String? label;
  final String? notes;
  final String? adminNote;
  final String? institutionContactName;
  final String? institutionContactEmail;
  final String? institutionContactPhone;
  final DateTime? verifiedAt;
  final DateTime? rejectedAt;

  String get displayLabel =>
      (label != null && label!.trim().isNotEmpty) ? label!.trim() : state.defaultLabel;

  String? get displayNote {
    final admin = adminNote?.trim();
    if (admin != null && admin.isNotEmpty) {
      return admin;
    }

    final note = notes?.trim();
    if (note != null && note.isNotEmpty) {
      return note;
    }

    return null;
  }

  bool get canResubmitVerification => state.canResubmitVerification;

  bool get needsCorrection =>
      state == AlumniVerificationState.revisionRequired ||
      state == AlumniVerificationState.declined ||
      state == AlumniVerificationState.rejected;

  factory AlumniVerificationStatus.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return AlumniVerificationStatus(
      state: AlumniVerificationState.fromJson(
        json['verification_status'] ?? json['status'] ?? json['state'] ?? value,
      ),
      label: JsonUtils.string(json, [
        'verification_label',
        'label',
        'status_label',
      ]),
      notes: JsonUtils.string(json, [
        'verification_note',
        'notes',
        'note',
        'reason',
      ]),
      adminNote: JsonUtils.string(json, [
        'admin_note',
        'admin_notes',
        'verification_note',
      ]),
      institutionContactName: JsonUtils.string(json, [
        'institution_contact_name',
        'contact_name',
      ]),
      institutionContactEmail: JsonUtils.string(json, [
        'institution_contact_email',
        'contact_email',
      ]),
      institutionContactPhone: JsonUtils.string(json, [
        'institution_contact_phone',
        'contact_phone',
      ]),
      verifiedAt: JsonUtils.dateTime(json, ['verified_at', 'verifiedAt']),
      rejectedAt: JsonUtils.dateTime(json, [
        'declined_at',
        'rejected_at',
        'rejectedAt',
      ]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': state.name,
      'label': label,
      'notes': notes,
      'admin_note': adminNote,
      'institution_contact_name': institutionContactName,
      'institution_contact_email': institutionContactEmail,
      'institution_contact_phone': institutionContactPhone,
      'verified_at': verifiedAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
    };
  }
}
