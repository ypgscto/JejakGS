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

  Future<ApiResponse<void>> saveJob(String id) {
    return api.post<void>('/jobs/$id/save', decoder: (_) {});
  }

  Future<ApiResponse<void>> unsaveJob(String id) {
    return api.delete<void>('/jobs/$id/save', decoder: (_) {});
  }

  Future<ApiResponse<List<JobPost>>> getSavedJobs() {
    return api.get<List<JobPost>>(
      '/jobs/saved',
      decoder: (json) => asListOfMaps(json).map(JobPost.fromJson).toList(),
    );
  }

  Future<ApiResponse<List<JobApplication>>> getApplicationHistory() {
    return api.get<List<JobApplication>>(
      '/jobs/applications',
      decoder: (json) =>
          asListOfMaps(json).map(JobApplication.fromJson).toList(),
    );
  }
}
