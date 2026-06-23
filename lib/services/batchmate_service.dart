import '../models/models.dart';
import 'base_simawa_service.dart';

class BatchmateService extends BaseSimawaService {
  const BatchmateService({required super.apiService});

  Future<ApiResponse<List<BatchmateProfile>>> getBatchmates({
    Map<String, dynamic>? filters,
  }) {
    return api.get<List<BatchmateProfile>>(
      '/alumni/batchmates',
      queryParameters: filters,
      decoder: (json) =>
          asListOfMaps(json).map(BatchmateProfile.fromJson).toList(),
    );
  }

  Future<ApiResponse<BatchmateProfile>> getBatchmateDetail(String id) {
    return api.get<BatchmateProfile>(
      '/alumni/batchmates/$id',
      decoder: BatchmateProfile.fromJson,
    );
  }
}
