import 'json_utils.dart';

class TracerAnswer {
  const TracerAnswer({
    required this.questionId,
    this.value,
    this.questionLabel,
    this.displayValue,
    this.values = const [],
    this.answeredAt,
  });

  final String questionId;
  final Object? value;
  final String? questionLabel;
  final Object? displayValue;
  final List<String> values;
  final DateTime? answeredAt;

  factory TracerAnswer.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return TracerAnswer(
      questionId: JsonUtils.string(json, ['question_id', 'questionId']) ?? '',
      value: json['value'] ?? json['answer'],
      questionLabel: JsonUtils.string(json, [
        'question_label',
        'questionLabel',
        'label',
      ]),
      displayValue: json['display_value'] ?? json['displayValue'],
      values: JsonUtils.stringList(json, ['values', 'answers']),
      answeredAt: JsonUtils.dateTime(json, ['answered_at', 'answeredAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'value': value,
      'question_label': questionLabel,
      'display_value': displayValue,
      'values': values,
      'answered_at': answeredAt?.toIso8601String(),
    };
  }
}
