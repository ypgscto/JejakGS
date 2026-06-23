import '../models/models.dart';
import 'base_simawa_service.dart';

class TracerService extends BaseSimawaService {
  const TracerService({required super.apiService});

  Future<ApiResponse<TracerStatus>> getProgress() {
    return api.get<TracerStatus>(
      '/tracer/status',
      decoder: TracerStatus.fromJson,
    );
  }

  Future<ApiResponse<TracerForm>> getActiveForm() {
    return api.get<TracerForm>(
      '/tracer/form-options',
      decoder: TracerForm.fromJson,
    );
  }

  Future<ApiResponse<TracerForm>> saveDraft(Map<String, dynamic> payload) {
    return api.post<TracerForm>(
      '/tracer',
      body: payload,
      decoder: TracerForm.fromJson,
    );
  }

  Future<ApiResponse<TracerSubmission>> submitFinal(
    Map<String, dynamic> payload,
  ) {
    return api.post<TracerSubmission>(
      '/tracer',
      body: payload,
      decoder: TracerSubmission.fromJson,
    );
  }

  Future<ApiResponse<List<TracerSubmission>>> getHistory() {
    return api.get<List<TracerSubmission>>(
      '/tracer/history',
      decoder: (json) =>
          asListOfMaps(json).map(TracerSubmission.fromJson).toList(),
    );
  }

  Future<ApiResponse<TracerSubmission>> getReview(String submissionId) {
    return api.get<TracerSubmission>(
      '/tracer/submissions/$submissionId',
      decoder: TracerSubmission.fromJson,
    );
  }
}
