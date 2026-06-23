import 'json_utils.dart';
import 'job_post.dart';

enum JobApplicationStatus {
  draft,
  submitted,
  reviewed,
  accepted,
  rejected,
  unknown;

  static JobApplicationStatus fromJson(Object? value) {
    final normalized = value?.toString().toLowerCase().trim();

    return JobApplicationStatus.values.firstWhere(
      (status) => status.name == normalized,
      orElse: () => JobApplicationStatus.unknown,
    );
  }
}

class JobApplication {
  const JobApplication({
    required this.id,
    required this.jobId,
    required this.status,
    this.job,
    this.coverLetter,
    this.cvUrl,
    this.submittedAt,
    this.updatedAt,
  });

  final String id;
  final String jobId;
  final JobApplicationStatus status;
  final JobPost? job;
  final String? coverLetter;
  final String? cvUrl;
  final DateTime? submittedAt;
  final DateTime? updatedAt;

  factory JobApplication.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);
    final jobJson = JsonUtils.asMap(json['job']);

    return JobApplication(
      id: JsonUtils.string(json, ['id', 'application_id']) ?? '',
      jobId: JsonUtils.string(json, ['job_id', 'jobId']) ?? '',
      status: JobApplicationStatus.fromJson(json['status']),
      job: jobJson.isEmpty ? null : JobPost.fromJson(jobJson),
      coverLetter: JsonUtils.string(json, ['cover_letter', 'coverLetter']),
      cvUrl: JsonUtils.string(json, ['cv_url', 'cvUrl']),
      submittedAt: JsonUtils.dateTime(json, ['submitted_at', 'submittedAt']),
      updatedAt: JsonUtils.dateTime(json, ['updated_at', 'updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'status': status.name,
      'job': job?.toJson(),
      'cover_letter': coverLetter,
      'cv_url': cvUrl,
      'submitted_at': submittedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
