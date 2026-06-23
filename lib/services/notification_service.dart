import '../models/models.dart';
import 'base_simawa_service.dart';

class NotificationService extends BaseSimawaService {
  const NotificationService({required super.apiService});

  Future<ApiResponse<List<NotificationItem>>> getNotifications({
    Map<String, dynamic>? filters,
  }) {
    return api.get<List<NotificationItem>>(
      '/notifications',
      queryParameters: filters,
      decoder: (json) =>
          asListOfMaps(json).map(NotificationItem.fromJson).toList(),
    );
  }

  Future<ApiResponse<NotificationItem>> getNotificationDetail(String id) {
    return api.get<NotificationItem>(
      '/notifications/$id',
      decoder: NotificationItem.fromJson,
    );
  }

  Future<ApiResponse<void>> markAsRead(String id) {
    return api.post<void>('/notifications/$id/read', decoder: (_) {});
  }

  Future<ApiResponse<void>> markAllAsRead() {
    return api.patch<void>('/notifications/read-all', decoder: (_) {});
  }

  Future<JsonMapResponse> registerPushToken({
    required String token,
    required String platform,
  }) {
    return api.post<Map<String, dynamic>>(
      '/notifications/push-token',
      body: {'token': token, 'platform': platform},
      decoder: asMapOrEmpty,
    );
  }
}
