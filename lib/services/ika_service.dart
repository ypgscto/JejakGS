import '../models/models.dart';
import 'base_simawa_service.dart';

class IkaService extends BaseSimawaService {
  const IkaService({required super.apiService});

  Future<ApiResponse<IkaStatus>> getMembershipStatus() {
    return api.get<IkaStatus>('/ika/status', decoder: IkaStatus.fromJson);
  }

  Future<JsonMapResponse> getInformation() {
    return api.get<Map<String, dynamic>>(
      '/ika/information',
      decoder: asMapOrEmpty,
    );
  }

  Future<ApiResponse<IkaStatus>> registerMembership(
    Map<String, dynamic> payload,
  ) {
    return api.post<IkaStatus>(
      '/ika/register',
      body: payload,
      decoder: IkaStatus.fromJson,
    );
  }

  Future<ApiResponse<IkaMemberCard>> getMemberCard() {
    return api.get<IkaMemberCard>('/ika/card', decoder: IkaMemberCard.fromJson);
  }

  Future<ApiResponse<List<AlumniEvent>>> getMemberEvents() {
    return api.get<List<AlumniEvent>>(
      '/ika-member/events/member-only',
      decoder: (json) => asListOfMaps(json).map(AlumniEvent.fromJson).toList(),
    );
  }

  Future<JsonListResponse> getPayments() {
    return api.get<List<Map<String, dynamic>>>(
      '/ika-member/dashboard',
      decoder: asListOfMaps,
    );
  }

  Future<JsonListResponse> getVotingItems() {
    return api.get<List<Map<String, dynamic>>>(
      '/ika-member/dashboard',
      decoder: asListOfMaps,
    );
  }

  Future<JsonListResponse> getForumTopics({bool boardOnly = false}) {
    return api.get<List<Map<String, dynamic>>>(
      boardOnly ? '/ika-board/dashboard' : '/ika-member/dashboard',
      decoder: asListOfMaps,
    );
  }

  Future<JsonMapResponse> getBoardDashboard() {
    return api.get<Map<String, dynamic>>(
      '/ika/board/dashboard',
      decoder: asMapOrEmpty,
    );
  }

  Future<JsonListResponse> getPendingRegistrations() {
    return api.get<List<Map<String, dynamic>>>(
      '/ika/board/registrations',
      decoder: asListOfMaps,
    );
  }

  Future<JsonMapResponse> broadcastInformation(Map<String, dynamic> payload) {
    return api.post<Map<String, dynamic>>(
      '/ika/board/broadcasts',
      body: payload,
      decoder: asMapOrEmpty,
    );
  }

  Future<JsonMapResponse> getMemberRecap() {
    return api.get<Map<String, dynamic>>(
      '/ika/board/member-recap',
      decoder: asMapOrEmpty,
    );
  }

  Future<JsonMapResponse> getPaymentRecap() {
    return api.get<Map<String, dynamic>>(
      '/ika/board/payment-recap',
      decoder: asMapOrEmpty,
    );
  }
}
