import 'json_utils.dart';

class JobPost {
  const JobPost({
    required this.id,
    required this.position,
    required this.company,
    this.description,
    this.location,
    this.employmentType,
    this.category,
    this.requirements = const [],
    this.deadlineAt,
    this.publishedAt,
    this.applicationUrl,
    this.applicationEmail,
    this.applicationWhatsapp,
    this.isSaved = false,
  });

  final String id;
  final String position;
  final String company;
  final String? description;
  final String? location;
  final String? employmentType;
  final String? category;
  final List<String> requirements;
  final DateTime? deadlineAt;
  final DateTime? publishedAt;
  final String? applicationUrl;
  final String? applicationEmail;
  final String? applicationWhatsapp;
  final bool isSaved;

  factory JobPost.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return JobPost(
      id: JsonUtils.string(json, ['id', 'job_id']) ?? '',
      position: JsonUtils.string(json, ['position', 'title']) ?? '',
      company: JsonUtils.string(json, ['company', 'company_name']) ?? '',
      description: JsonUtils.string(json, ['description']),
      location: JsonUtils.string(json, ['location']),
      employmentType: JsonUtils.string(json, ['employment_type', 'type']),
      category: JsonUtils.string(json, ['category', 'kategori']),
      requirements: JsonUtils.stringList(json, ['requirements']),
      deadlineAt: JsonUtils.dateTime(json, ['deadline_at', 'deadline']),
      publishedAt: JsonUtils.dateTime(json, ['published_at', 'created_at']),
      applicationUrl: JsonUtils.string(json, ['application_url', 'apply_url']),
      applicationEmail: JsonUtils.string(json, [
        'application_email',
        'apply_email',
      ]),
      applicationWhatsapp: JsonUtils.string(json, [
        'application_whatsapp',
        'apply_whatsapp',
        'whatsapp',
      ]),
      isSaved: JsonUtils.boolean(json, ['is_saved', 'saved']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position,
      'company': company,
      'description': description,
      'location': location,
      'employment_type': employmentType,
      'category': category,
      'requirements': requirements,
      'deadline_at': deadlineAt?.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'application_url': applicationUrl,
      'application_email': applicationEmail,
      'application_whatsapp': applicationWhatsapp,
      'is_saved': isSaved,
    };
  }
}
