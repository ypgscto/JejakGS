import 'base_simawa_service.dart';

class PrivacyService extends BaseSimawaService {
  const PrivacyService({required super.apiService});

  Future<JsonMapResponse> getSettings() {
    return api.get<Map<String, dynamic>>('/privacy', decoder: asMapOrEmpty);
  }

  Future<JsonMapResponse> updateSettings(Map<String, dynamic> payload) {
    return api.patch<Map<String, dynamic>>(
      '/privacy',
      body: payload,
      decoder: asMapOrEmpty,
    );
  }
}
