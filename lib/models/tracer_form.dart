import 'json_utils.dart';
import 'tracer_answer.dart';
import 'tracer_question.dart';

class TracerForm {
  const TracerForm({
    required this.id,
    required this.title,
    this.description,
    this.questions = const [],
    this.answers = const [],
    this.opensAt,
    this.closesAt,
  });

  final String id;
  final String title;
  final String? description;
  final List<TracerQuestion> questions;
  final List<TracerAnswer> answers;
  final DateTime? opensAt;
  final DateTime? closesAt;

  factory TracerForm.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return TracerForm(
      id: JsonUtils.string(json, ['id', 'form_id']) ?? '',
      title: JsonUtils.string(json, ['title', 'name']) ?? '',
      description: JsonUtils.string(json, ['description']),
      questions: JsonUtils.asMapList(
        json['questions'],
      ).map(TracerQuestion.fromJson).toList(),
      answers: JsonUtils.asMapList(
        json['answers'],
      ).map(TracerAnswer.fromJson).toList(),
      opensAt: JsonUtils.dateTime(json, ['opens_at', 'opensAt']),
      closesAt: JsonUtils.dateTime(json, ['closes_at', 'closesAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((question) => question.toJson()).toList(),
      'answers': answers.map((answer) => answer.toJson()).toList(),
      'opens_at': opensAt?.toIso8601String(),
      'closes_at': closesAt?.toIso8601String(),
    };
  }
}
