import 'json_utils.dart';

enum EducationRequestStatus {
  pending,
  revisionRequired,
  declined,
  verified,
  unknown;

  static EducationRequestStatus parse(Object? value) => switch (value) {
    'pending' => pending,
    'revision_required' => revisionRequired,
    'declined' => declined,
    'verified' => verified,
    _ => unknown,
  };

  String get label => switch (this) {
    pending => 'Menunggu pemeriksaan',
    revisionRequired => 'Perlu perbaikan',
    declined => 'Ditolak',
    verified => 'Disetujui',
    unknown => 'Status belum tersedia',
  };

  bool get canResubmit => this == revisionRequired || this == declined;
}

class AlumniEducation {
  const AlumniEducation({
    required this.id,
    required this.alumniId,
    required this.nim,
    required this.name,
    required this.studyProgram,
    required this.isPrimary,
    required this.isActive,
    required this.verificationStatus,
    this.alumniNumber,
    this.cohortYear,
    this.graduationYear,
  });

  final int id;
  final int alumniId;
  final String nim;
  final String name;
  final String studyProgram;
  final String? alumniNumber;
  final int? cohortYear;
  final int? graduationYear;
  final bool isPrimary;
  final bool isActive;
  final EducationRequestStatus verificationStatus;

  factory AlumniEducation.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);
    return AlumniEducation(
      id: JsonUtils.integer(json, ['id']) ?? 0,
      alumniId: JsonUtils.integer(json, ['alumni_id']) ?? 0,
      nim: JsonUtils.string(json, ['nim']) ?? '',
      name: JsonUtils.string(json, ['name']) ?? '',
      studyProgram: JsonUtils.string(json, ['study_program']) ?? '',
      alumniNumber: JsonUtils.string(json, ['alumni_number']),
      cohortYear: JsonUtils.integer(json, ['cohort_year']),
      graduationYear: JsonUtils.integer(json, ['graduation_year']),
      isPrimary: JsonUtils.boolean(json, ['is_primary']),
      isActive: JsonUtils.boolean(json, ['is_active']),
      verificationStatus: EducationRequestStatus.parse(
        json['education_verification_status'],
      ),
    );
  }
}

class AlumniEducationRequest {
  const AlumniEducationRequest({
    required this.id,
    required this.nim,
    required this.status,
    required this.ownershipNote,
    this.reviewNote,
    this.submittedAt,
    this.hasDiplomaEvidence = false,
  });

  final int id;
  final String nim;
  final EducationRequestStatus status;
  final String ownershipNote;
  final String? reviewNote;
  final DateTime? submittedAt;
  final bool hasDiplomaEvidence;

  factory AlumniEducationRequest.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);
    return AlumniEducationRequest(
      id: JsonUtils.integer(json, ['id']) ?? 0,
      nim: JsonUtils.string(json, ['nim']) ?? '',
      status: EducationRequestStatus.parse(json['status']),
      ownershipNote: JsonUtils.string(json, ['ownership_note']) ?? '',
      reviewNote: JsonUtils.string(json, ['review_note']),
      submittedAt: JsonUtils.dateTime(json, ['submitted_at']),
      hasDiplomaEvidence: JsonUtils.boolean(json, ['has_diploma_evidence']),
    );
  }
}

class AlumniEducationOverview {
  const AlumniEducationOverview({
    required this.identityId,
    required this.primaryAlumniId,
    required this.educations,
    required this.requests,
  });

  final int identityId;
  final int primaryAlumniId;
  final List<AlumniEducation> educations;
  final List<AlumniEducationRequest> requests;

  factory AlumniEducationOverview.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);
    return AlumniEducationOverview(
      identityId: JsonUtils.integer(json, ['identity_id']) ?? 0,
      primaryAlumniId: JsonUtils.integer(json, ['primary_alumni_id']) ?? 0,
      educations: List.unmodifiable(
        JsonUtils.asMapList(json['educations']).map(AlumniEducation.fromJson),
      ),
      requests: List.unmodifiable(
        JsonUtils.asMapList(
          json['requests'],
        ).map(AlumniEducationRequest.fromJson),
      ),
    );
  }
}
