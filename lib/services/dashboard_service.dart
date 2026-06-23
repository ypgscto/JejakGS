import '../models/models.dart';
import 'base_simawa_service.dart';

class DashboardService extends BaseSimawaService {
  const DashboardService({required super.apiService});

  Future<ApiResponse<DashboardSummary>> getSummary() {
    return api.get<DashboardSummary>(
      '/home',
      decoder: DashboardSummary.fromJson,
    );
  }
}
