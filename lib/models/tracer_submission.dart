import 'json_utils.dart';
import 'tracer_answer.dart';
import 'tracer_status.dart';

class TracerSubmission {
  const TracerSubmission({
    required this.id,
    required this.formId,
    required this.status,
    this.title,
    this.revisionNote,
    this.answers = const [],
    this.submittedAt,
    this.updatedAt,
  });

  final String id;
  final String formId;
  final TracerCompletionState status;
  final String? title;
  final String? revisionNote;
  final List<TracerAnswer> answers;
  final DateTime? submittedAt;
  final DateTime? updatedAt;

  bool get hasRevisionNote =>
      revisionNote != null && revisionNote!.trim().isNotEmpty;

  factory TracerSubmission.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return TracerSubmission(
      id: JsonUtils.string(json, ['id', 'submission_id']) ?? '',
      formId: JsonUtils.string(json, ['form_id', 'formId']) ?? '',
      status: TracerCompletionState.fromJson(json['status']),
      title: JsonUtils.string(json, ['title', 'form_title']),
      revisionNote: JsonUtils.string(json, ['revision_note', 'revisionNote']),
      answers: JsonUtils.asMapList(
        json['answers'],
      ).map(TracerAnswer.fromJson).toList(),
      submittedAt: JsonUtils.dateTime(json, ['submitted_at', 'submittedAt']),
      updatedAt: JsonUtils.dateTime(json, ['updated_at', 'updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'form_id': formId,
      'status': status.name,
      'title': title,
      'revision_note': revisionNote,
      'answers': answers.map((answer) => answer.toJson()).toList(),
      'submitted_at': submittedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
