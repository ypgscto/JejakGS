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

    if (normalized == 'rejected') {
      return AlumniVerificationState.declined;
    }

    return AlumniVerificationState.values.firstWhere(
      (state) => state.name.toLowerCase() == normalizedCamel,
      orElse: () => AlumniVerificationState.unknown,
    );
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
