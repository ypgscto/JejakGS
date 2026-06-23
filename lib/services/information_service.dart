import '../models/models.dart';
import 'base_simawa_service.dart';

class InformationService extends BaseSimawaService {
  const InformationService({required super.apiService});

  Future<ApiResponse<List<AnnouncementItem>>> getAnnouncements({
    Map<String, dynamic>? filters,
  }) {
    return api.get<List<AnnouncementItem>>(
      '/information',
      queryParameters: filters,
      decoder: (json) =>
          asListOfMaps(json).map(AnnouncementItem.fromJson).toList(),
    );
  }

  Future<ApiResponse<AnnouncementItem>> getAnnouncementDetail(String id) {
    return api.get<AnnouncementItem>(
      '/information/$id',
      decoder: AnnouncementItem.fromJson,
    );
  }

  Future<ApiResponse<void>> bookmarkAnnouncement(String id) {
    return api.post<void>(
      '/information/announcements/$id/bookmark',
      decoder: (_) {},
    );
  }

  Future<ApiResponse<void>> removeBookmark(String id) {
    return api.delete<void>(
      '/information/announcements/$id/bookmark',
      decoder: (_) {},
    );
  }
}
