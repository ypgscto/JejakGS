import 'json_utils.dart';

class PrivacySetting {
  const PrivacySetting({
    required this.showCity,
    required this.showJobTitle,
    required this.showInstitution,
    required this.showGraduationYear,
    required this.showAvatar,
    required this.showSocialMedia,
    this.updatedAt,
  });

  final bool showCity;
  final bool showJobTitle;
  final bool showInstitution;
  final bool showGraduationYear;
  final bool showAvatar;
  final bool showSocialMedia;
  final DateTime? updatedAt;

  factory PrivacySetting.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return PrivacySetting(
      showCity: JsonUtils.boolean(json, ['show_city'], defaultValue: true),
      showJobTitle: JsonUtils.boolean(json, [
        'show_job_title',
      ], defaultValue: true),
      showInstitution: JsonUtils.boolean(json, [
        'show_institution',
      ], defaultValue: true),
      showGraduationYear: JsonUtils.boolean(json, [
        'show_graduation_year',
      ], defaultValue: true),
      showAvatar: JsonUtils.boolean(json, ['show_avatar'], defaultValue: true),
      showSocialMedia: JsonUtils.boolean(json, [
        'show_social_media',
      ], defaultValue: false),
      updatedAt: JsonUtils.dateTime(json, ['updated_at', 'updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show_city': showCity,
      'show_job_title': showJobTitle,
      'show_institution': showInstitution,
      'show_graduation_year': showGraduationYear,
      'show_avatar': showAvatar,
      'show_social_media': showSocialMedia,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
