import 'alumni_verification_status.dart';
import 'ika_status.dart';
import 'json_utils.dart';

enum AlumniSourceType {
  siakad,
  manualRegister,
  unknown;

  static AlumniSourceType fromJson(Object? value) {
    final normalized = value?.toString().toLowerCase().replaceAll('_', '');

    return AlumniSourceType.values.firstWhere(
      (type) => type.name.toLowerCase() == normalized,
      orElse: () => AlumniSourceType.unknown,
    );
  }
}

enum AlumniRole {
  alumni,
  ikaMember,
  ikaOfficer,
  alumniAdmin,
  superAdmin,
  unknown;

  static AlumniRole fromJson(Object? value) {
    final normalized = value?.toString().toLowerCase().trim();
    final normalizedCamel = normalized?.replaceAll('_', '');

    if (normalized == null || normalized.isEmpty) {
      return AlumniRole.alumni;
    }

    if (normalized == 'ika_member' || normalized == 'member') {
      return AlumniRole.ikaMember;
    }

    if (normalized == 'ika_officer' ||
        normalized == 'ika_board' ||
        normalized == 'board') {
      return AlumniRole.ikaOfficer;
    }

    if (normalized == 'alumni_admin' || normalized == 'admin') {
      return AlumniRole.alumniAdmin;
    }

    if (normalized == 'super_admin' || normalized == 'superadmin') {
      return AlumniRole.superAdmin;
    }

    return AlumniRole.values.firstWhere(
      (role) => role.name.toLowerCase() == normalizedCamel,
      orElse: () => AlumniRole.unknown,
    );
  }

  String toJson() {
    return switch (this) {
      AlumniRole.ikaMember => 'ika_member',
      AlumniRole.ikaOfficer => 'ika_officer',
      AlumniRole.alumniAdmin => 'alumni_admin',
      AlumniRole.superAdmin => 'super_admin',
      AlumniRole.alumni => 'alumni',
      AlumniRole.unknown => 'unknown',
    };
  }
}

class AlumniProfile {
  const AlumniProfile({
    required this.nim,
    required this.name,
    required this.programStudy,
    required this.batchYear,
    required this.graduationYear,
    required this.verificationStatus,
    required this.ikaStatus,
    required this.sourceType,
    this.alumniNumber,
    this.role = AlumniRole.alumni,
    this.email,
    this.phoneNumber,
    this.city,
    this.employmentStatus,
    this.jobTitle,
    this.position,
    this.institution,
    this.socialMedia = const {},
    this.avatarUrl,
    this.diplomaPhotoUrl,
    this.showInBatchmates = false,
  });

  final String nim;
  final String name;
  final String programStudy;
  final int batchYear;
  final int graduationYear;
  final AlumniVerificationStatus verificationStatus;
  final IkaStatus ikaStatus;
  final AlumniSourceType sourceType;
  final String? alumniNumber;
  final AlumniRole role;
  final String? email;
  final String? phoneNumber;
  final String? city;
  final String? employmentStatus;
  final String? jobTitle;
  final String? position;
  final String? institution;
  final Map<String, String> socialMedia;
  final String? avatarUrl;
  final String? diplomaPhotoUrl;
  final bool showInBatchmates;

  bool get isAcademicDataLocked {
    if (sourceType == AlumniSourceType.siakad) {
      return true;
    }

    return sourceType == AlumniSourceType.manualRegister &&
        verificationStatus.state == AlumniVerificationState.verified;
  }

  bool get canEditAcademicData {
    return sourceType == AlumniSourceType.manualRegister &&
        verificationStatus.state == AlumniVerificationState.revisionRequired;
  }

  bool get canUploadDiplomaPhoto {
    return sourceType == AlumniSourceType.manualRegister &&
        verificationStatus.state == AlumniVerificationState.revisionRequired;
  }

  bool get isComplete {
    return nim.trim().isNotEmpty &&
        name.trim().isNotEmpty &&
        programStudy.trim().isNotEmpty &&
        batchYear > 0 &&
        graduationYear > 0 &&
        _hasValue(email) &&
        _hasValue(phoneNumber) &&
        _hasValue(city) &&
        (_hasValue(employmentStatus) || _hasValue(jobTitle)) &&
        _hasValue(institution);
  }

  factory AlumniProfile.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);
    final academic = JsonUtils.asMap(json['academic']);
    final contact = JsonUtils.asMap(json['contact']);
    final career = JsonUtils.asMap(json['career']);
    final privacy = JsonUtils.asMap(json['privacy']);
    final verification = JsonUtils.asMap(json['verification']);
    final socialMedia = JsonUtils.asMap(
      json['social_media'] ?? json['socialMedia'],
    );

    return AlumniProfile(
      nim:
          JsonUtils.string(json, ['nim', 'student_number']) ??
          JsonUtils.string(academic, ['nim', 'student_number']) ??
          '',
      alumniNumber:
          JsonUtils.string(json, ['alumni_number', 'card_number']) ??
          JsonUtils.string(academic, ['alumni_number', 'card_number']),
      name:
          JsonUtils.string(json, ['name', 'nama']) ??
          JsonUtils.string(academic, ['name', 'nama']) ??
          '',
      programStudy:
          JsonUtils.string(json, ['program_study', 'study_program', 'prodi']) ??
          JsonUtils.string(academic, [
            'program_study',
            'study_program',
            'prodi',
          ]) ??
          '',
      batchYear:
          JsonUtils.integer(json, ['batch_year', 'cohort_year', 'angkatan']) ??
          JsonUtils.integer(academic, [
            'batch_year',
            'cohort_year',
            'angkatan',
          ]) ??
          0,
      graduationYear:
          JsonUtils.integer(json, ['graduation_year', 'tahun_lulus']) ??
          JsonUtils.integer(academic, ['graduation_year', 'tahun_lulus']) ??
          0,
      verificationStatus: AlumniVerificationStatus.fromJson(
        verification.isNotEmpty
            ? verification
            : json['verification_status'] ?? json['verificationStatus'],
      ),
      ikaStatus: IkaStatus.fromJson(json['ika_status'] ?? json['ikaStatus']),
      sourceType: AlumniSourceType.fromJson(
        json['source_type'] ?? verification['source_type'],
      ),
      role: AlumniRole.fromJson(
        json['role'] ??
            json['app_role'] ??
            json['alumni_role'] ??
            JsonUtils.asMap(json['ika_status'] ?? json['ikaStatus'])['role'],
      ),
      email:
          JsonUtils.string(json, ['email']) ??
          JsonUtils.string(contact, ['email']),
      phoneNumber:
          JsonUtils.string(json, ['phone_number', 'nomor_hp', 'phone']) ??
          JsonUtils.string(contact, ['phone_number', 'nomor_hp', 'phone']),
      city:
          JsonUtils.string(json, ['city', 'domisili_kota', 'work_location']) ??
          JsonUtils.string(career, [
            'city',
            'domisili_kota',
            'work_location',
          ]) ??
          JsonUtils.string(contact, ['city', 'domisili_kota', 'address']),
      employmentStatus:
          JsonUtils.string(json, ['employment_status', 'status_pekerjaan']) ??
          JsonUtils.string(career, ['employment_status', 'status_pekerjaan']),
      jobTitle:
          JsonUtils.string(json, ['job_title', 'pekerjaan']) ??
          JsonUtils.string(career, ['job_title', 'pekerjaan']),
      position:
          JsonUtils.string(json, ['position', 'jabatan']) ??
          JsonUtils.string(career, ['position', 'jabatan']),
      institution:
          JsonUtils.string(json, ['institution', 'instansi', 'company_name']) ??
          JsonUtils.string(career, [
            'institution',
            'instansi',
            'company_name',
            'business_name',
            'further_study_institution',
          ]),
      socialMedia: socialMedia.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
      avatarUrl: JsonUtils.string(json, ['avatar_url', 'photo_url']),
      diplomaPhotoUrl: JsonUtils.string(json, [
        'diploma_photo_url',
        'ijazah_photo_url',
      ]),
      showInBatchmates:
          JsonUtils.boolean(json, ['show_in_batchmates', 'showInBatchmates']) ||
          JsonUtils.boolean(privacy, [
            'show_in_batchmates',
            'showInBatchmates',
          ]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nim': nim,
      'name': name,
      'program_study': programStudy,
      'batch_year': batchYear,
      'graduation_year': graduationYear,
      'verification_status': verificationStatus.toJson(),
      'ika_status': ikaStatus.toJson(),
      'source_type': sourceType.name,
      'alumni_number': alumniNumber,
      'role': role.toJson(),
      'email': email,
      'phone_number': phoneNumber,
      'city': city,
      'employment_status': employmentStatus,
      'job_title': jobTitle,
      'position': position,
      'institution': institution,
      'social_media': socialMedia,
      'avatar_url': avatarUrl,
      'diploma_photo_url': diplomaPhotoUrl,
      'show_in_batchmates': showInBatchmates,
    };
  }

  static bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
