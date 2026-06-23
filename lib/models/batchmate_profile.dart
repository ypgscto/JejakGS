import 'alumni_profile.dart';
import 'alumni_verification_status.dart';
import 'json_utils.dart';

class BatchmateProfile {
  const BatchmateProfile({
    required this.id,
    required this.name,
    required this.programStudy,
    required this.batchYear,
    required this.sourceType,
    required this.verificationStatus,
    this.graduationYear,
    this.city,
    this.jobTitle,
    this.institution,
    this.avatarUrl,
    this.publicSocialMedia = const {},
    this.showAvatar = true,
    this.showCity = true,
    this.showJobTitle = true,
    this.showInstitution = true,
    this.showSocialMedia = false,
    this.showInBatchmates = false,
    this.ikaStatusLabel,
  });

  final String id;
  final String name;
  final String programStudy;
  final int batchYear;
  final AlumniSourceType sourceType;
  final AlumniVerificationStatus verificationStatus;
  final int? graduationYear;
  final String? city;
  final String? jobTitle;
  final String? institution;
  final String? avatarUrl;
  final Map<String, String> publicSocialMedia;
  final bool showAvatar;
  final bool showCity;
  final bool showJobTitle;
  final bool showInstitution;
  final bool showSocialMedia;
  final bool showInBatchmates;
  final String? ikaStatusLabel;

  factory BatchmateProfile.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);
    final publicSocialMedia = JsonUtils.asMap(
      json['public_social_media'] ?? json['social_media'],
    );

    return BatchmateProfile(
      id: JsonUtils.string(json, ['id', 'alumni_id']) ?? '',
      name: JsonUtils.string(json, ['name', 'nama']) ?? '',
      programStudy: JsonUtils.string(json, ['program_study', 'prodi']) ?? '',
      batchYear:
          JsonUtils.integer(json, [
            'batch_year',
            'tahun_angkatan',
            'angkatan',
          ]) ??
          0,
      sourceType: AlumniSourceType.fromJson(json['source_type']),
      verificationStatus: AlumniVerificationStatus.fromJson(
        json['verification_status'] ?? json['verificationStatus'],
      ),
      graduationYear: JsonUtils.integer(json, [
        'graduation_year',
        'tahun_lulus',
      ]),
      city: JsonUtils.string(json, ['city', 'domisili_kota', 'domicile_city']),
      jobTitle: JsonUtils.string(json, [
        'job_title',
        'pekerjaan',
        'job_status',
      ]),
      institution: JsonUtils.string(json, [
        'institution',
        'instansi',
        'company',
      ]),
      avatarUrl: JsonUtils.string(json, ['avatar_url', 'photo_url', 'photo']),
      showAvatar: JsonUtils.boolean(json, ['show_avatar'], defaultValue: true),
      showCity: JsonUtils.boolean(json, ['show_city'], defaultValue: true),
      showJobTitle: JsonUtils.boolean(json, [
        'show_job_title',
      ], defaultValue: true),
      showInstitution: JsonUtils.boolean(json, [
        'show_institution',
      ], defaultValue: true),
      showSocialMedia: JsonUtils.boolean(json, [
        'show_social_media',
      ], defaultValue: false),
      showInBatchmates: JsonUtils.boolean(json, [
        'show_in_batchmates',
        'showInBatchmates',
      ]),
      ikaStatusLabel: JsonUtils.string(json, [
        'ika_status_label',
        'ika_status',
      ]),
      publicSocialMedia: publicSocialMedia.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'program_study': programStudy,
      'batch_year': batchYear,
      'source_type': sourceType.name,
      'verification_status': verificationStatus.toJson(),
      'graduation_year': graduationYear,
      'city': city,
      'job_title': jobTitle,
      'institution': institution,
      'avatar_url': avatarUrl,
      'show_avatar': showAvatar,
      'show_city': showCity,
      'show_job_title': showJobTitle,
      'show_institution': showInstitution,
      'show_social_media': showSocialMedia,
      'show_in_batchmates': showInBatchmates,
      'ika_status_label': ikaStatusLabel,
      'public_social_media': publicSocialMedia,
    };
  }
}
