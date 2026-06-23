import 'json_utils.dart';

enum TracerQuestionType {
  text,
  number,
  dropdown,
  radio,
  checkbox,
  singleChoice,
  multipleChoice,
  date,
  textarea,
  file,
  unknown;

  static TracerQuestionType fromJson(Object? value) {
    final normalized = value?.toString().toLowerCase().replaceAll('_', '');

    if (normalized == 'select') {
      return TracerQuestionType.dropdown;
    }

    if (normalized == 'singlechoice') {
      return TracerQuestionType.radio;
    }

    if (normalized == 'multiplechoice') {
      return TracerQuestionType.checkbox;
    }

    return TracerQuestionType.values.firstWhere(
      (type) => type.name.toLowerCase() == normalized,
      orElse: () => TracerQuestionType.unknown,
    );
  }
}

class TracerQuestion {
  const TracerQuestion({
    required this.id,
    required this.label,
    required this.type,
    this.description,
    this.isRequired = false,
    this.options = const [],
    this.optionLabels = const {},
    this.order,
    this.validationRules = const {},
  });

  final String id;
  final String label;
  final TracerQuestionType type;
  final String? description;
  final bool isRequired;
  final List<String> options;
  final Map<String, String> optionLabels;
  final int? order;
  final Map<String, dynamic> validationRules;

  factory TracerQuestion.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);
    final parsedOptions = _parseOptions(json['options']);

    return TracerQuestion(
      id: JsonUtils.string(json, ['id', 'question_id']) ?? '',
      label: JsonUtils.string(json, ['label', 'question', 'title']) ?? '',
      type: TracerQuestionType.fromJson(json['type']),
      description: JsonUtils.string(json, ['description', 'help_text']),
      isRequired: JsonUtils.boolean(json, ['is_required', 'required']),
      options: parsedOptions.keys.toList(),
      optionLabels: parsedOptions,
      order: JsonUtils.integer(json, ['order', 'sort_order']),
      validationRules: JsonUtils.asMap(
        json['validation_rules'] ?? json['validationRules'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'type': type.name,
      'description': description,
      'is_required': isRequired,
      'options': options,
      'option_labels': optionLabels,
      'order': order,
      'validation_rules': validationRules,
    };
  }

  static Map<String, String> _parseOptions(Object? value) {
    if (value is Map) {
      return Map<String, String>.fromEntries(
        value.entries.map(
          (entry) => MapEntry(entry.key.toString(), entry.value.toString()),
        ),
      );
    }

    if (value is List) {
      final entries = <MapEntry<String, String>>[];
      for (final item in value) {
        final option = JsonUtils.asMap(item);
        if (option.isEmpty) {
          final text = item?.toString() ?? '';
          if (text.trim().isNotEmpty) {
            entries.add(MapEntry(text, text));
          }
          continue;
        }

        final optionValue =
            JsonUtils.string(option, ['value', 'id', 'key']) ?? '';
        final optionLabel =
            JsonUtils.string(option, ['label', 'name', 'title']) ?? optionValue;
        if (optionValue.trim().isNotEmpty) {
          entries.add(MapEntry(optionValue, optionLabel));
        }
      }
      return Map<String, String>.fromEntries(entries);
    }

    return const {};
  }
}
