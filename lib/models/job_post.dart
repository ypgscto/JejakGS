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
    this.categoryLabel,
    this.jobField,
    this.jobFieldLabel,
    this.salaryRange,
    this.requirements = const [],
    this.deadlineAt,
    this.publishedAt,
    this.applicationUrl,
    this.applicationEmail,
    this.applicationWhatsapp,
    this.isSaved = false,
    this.isApplied = false,
    this.applicationStatus,
  });

  final String id;
  final String position;
  final String company;
  final String? description;
  final String? location;
  final String? employmentType;
  final String? category;
  final String? categoryLabel;
  final String? jobField;
  final String? jobFieldLabel;
  final String? salaryRange;
  final List<String> requirements;
  final DateTime? deadlineAt;
  final DateTime? publishedAt;
  final String? applicationUrl;
  final String? applicationEmail;
  final String? applicationWhatsapp;
  final bool isSaved;
  final bool isApplied;
  final String? applicationStatus;

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
      categoryLabel: JsonUtils.string(json, ['category_label']),
      jobField: JsonUtils.string(json, ['job_field']),
      jobFieldLabel: JsonUtils.string(json, ['job_field_label']),
      salaryRange: JsonUtils.string(json, ['salary_range']),
      requirements: _requirements(json),
      deadlineAt: JsonUtils.dateTime(json, ['deadline_at', 'deadline']),
      publishedAt: JsonUtils.dateTime(json, [
        'published_at',
        'posted_at',
        'created_at',
      ]),
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
      isApplied: JsonUtils.boolean(json, ['is_applied', 'applied']),
      applicationStatus: JsonUtils.string(json, ['application_status']),
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
      'category_label': categoryLabel,
      'job_field': jobField,
      'job_field_label': jobFieldLabel,
      'salary_range': salaryRange,
      'requirements': requirements,
      'deadline_at': deadlineAt?.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'application_url': applicationUrl,
      'application_email': applicationEmail,
      'application_whatsapp': applicationWhatsapp,
      'is_saved': isSaved,
      'is_applied': isApplied,
      'application_status': applicationStatus,
    };
  }

  static List<String> _requirements(Map<String, dynamic> json) {
    final list = JsonUtils.stringList(json, ['requirements']);
    if (list.isNotEmpty) {
      return list;
    }

    final text = JsonUtils.string(json, ['requirements']);
    if (text == null) {
      return const [];
    }

    return text
        .split(RegExp(r'\r?\n'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
