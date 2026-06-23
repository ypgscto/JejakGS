import '../models/models.dart';
import 'base_simawa_service.dart';

class EventService extends BaseSimawaService {
  const EventService({required super.apiService});

  Future<ApiResponse<List<AlumniEvent>>> getEvents({
    Map<String, dynamic>? filters,
  }) {
    return api.get<List<AlumniEvent>>(
      '/events',
      queryParameters: filters,
      decoder: (json) => asListOfMaps(json).map(AlumniEvent.fromJson).toList(),
    );
  }

  Future<ApiResponse<AlumniEvent>> getEventDetail(String id) {
    return api.get<AlumniEvent>('/events/$id', decoder: AlumniEvent.fromJson);
  }

  Future<ApiResponse<AlumniEvent>> registerEvent(String id) {
    return api.post<AlumniEvent>(
      '/events/$id/register',
      decoder: AlumniEvent.fromJson,
    );
  }

  Future<ApiResponse<AlumniEvent>> getTicket(String id) {
    return api.get<AlumniEvent>(
      '/events/$id/ticket',
      decoder: AlumniEvent.fromJson,
    );
  }

  Future<ApiResponse<AlumniEvent>> getCertificate(String id) {
    return api.get<AlumniEvent>(
      '/events/$id/certificate',
      decoder: AlumniEvent.fromJson,
    );
  }

  Future<ApiResponse<List<String>>> getGallery(String id) {
    return api.get<List<String>>(
      '/events/$id/gallery',
      decoder: (json) {
        if (json is List) {
          return json.map((item) => item.toString()).toList();
        }
        return const [];
      },
    );
  }

  Future<JsonMapResponse> submitEvaluation(
    String id,
    Map<String, dynamic> payload,
  ) {
    return api.post<Map<String, dynamic>>(
      '/events/$id/evaluation',
      body: payload,
      decoder: asMapOrEmpty,
    );
  }
}
