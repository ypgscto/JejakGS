import '../models/models.dart';
import 'base_simawa_service.dart';

class JobService extends BaseSimawaService {
  const JobService({required super.apiService});

  Future<ApiResponse<List<JobPost>>> getJobs({Map<String, dynamic>? filters}) {
    return api.get<List<JobPost>>(
      '/jobs',
      queryParameters: filters,
      decoder: (json) => asListOfMaps(json).map(JobPost.fromJson).toList(),
    );
  }

  Future<ApiResponse<JobPost>> getJobDetail(String id) {
    return api.get<JobPost>('/jobs/$id', decoder: JobPost.fromJson);
  }

  Future<JsonMapResponse> applyJob(String id, {String? coverMessage}) {
    return api.post<Map<String, dynamic>>(
      '/jobs/$id/apply',
      body: {
        if (coverMessage != null && coverMessage.trim().isNotEmpty)
          'cover_message': coverMessage.trim(),
      },
      decoder: asMapOrEmpty,
    );
  }

  Future<ApiResponse<void>> unsaveJob(String id) {
    return Future.value(ApiResponse.success(statusCode: 200));
  }

  Future<ApiResponse<List<JobPost>>> getSavedJobs() {
    return Future.value(
      ApiResponse.success(statusCode: 200, data: <JobPost>[]),
    );
  }

  Future<ApiResponse<List<JobApplication>>> getApplicationHistory() {
    return Future.value(
      ApiResponse.success(statusCode: 200, data: <JobApplication>[]),
    );
  }
}
