import 'json_utils.dart';

enum TracerCompletionState {
  notStarted,
  inProgress,
  submitted,
  verified,
  unknown;

  static TracerCompletionState fromJson(Object? value) {
    final normalized = value?.toString().toLowerCase().trim();
    final normalizedCamel = normalized?.replaceAll('_', '');

    return TracerCompletionState.values.firstWhere(
      (state) => state.name.toLowerCase() == normalizedCamel,
      orElse: () => TracerCompletionState.unknown,
    );
  }
}

class TracerStatus {
  const TracerStatus({
    required this.state,
    required this.progress,
    this.currentStep,
    this.submittedAt,
    this.updatedAt,
  });

  final TracerCompletionState state;
  final double progress;
  final String? currentStep;
  final DateTime? submittedAt;
  final DateTime? updatedAt;

  factory TracerStatus.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);
    final submitted = JsonUtils.boolean(json, ['submitted']);

    return TracerStatus(
      state: TracerCompletionState.fromJson(
        json['status'] ??
            json['state'] ??
            (submitted ? 'submitted' : 'not_started'),
      ),
      progress: (JsonUtils.decimal(json, ['progress']) ?? (submitted ? 1 : 0))
          .clamp(0, 1),
      currentStep: JsonUtils.string(json, [
        'current_step',
        'currentStep',
        'current_year',
      ]),
      submittedAt: JsonUtils.dateTime(json, ['submitted_at', 'submittedAt']),
      updatedAt: JsonUtils.dateTime(json, ['updated_at', 'updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': state.name,
      'progress': progress,
      'current_step': currentStep,
      'submitted_at': submittedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
