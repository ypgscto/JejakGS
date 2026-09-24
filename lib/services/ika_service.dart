import '../models/models.dart';
import 'base_simawa_service.dart';

class IkaService extends BaseSimawaService {
  const IkaService({required super.apiService});

  Future<ApiResponse<IkaStatus>> getMembershipStatus() {
    return api.get<IkaStatus>(
      '/api/alumni/ika/status',
      decoder: IkaStatus.fromJson,
    );
  }

  Future<ApiResponse<IkaStatus>> getIkaStatus() => getMembershipStatus();

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
    return api.get<IkaMemberCard>(
      '/api/alumni/ika/card',
      decoder: IkaMemberCard.fromJson,
    );
  }

  Future<ApiResponse<IkaMemberCard>> getIkaCard() => getMemberCard();

  Future<ApiResponse<List<AlumniEvent>>> getMemberEvents() {
    return api.get<List<AlumniEvent>>(
      '/api/alumni/ika/events',
      decoder: (json) => asListOfMaps(json).map(AlumniEvent.fromJson).toList(),
    );
  }

  Future<ApiResponse<List<AlumniEvent>>> getIkaEvents() => getMemberEvents();

  Future<ApiResponse<AlumniEvent>> getMemberEventDetail(String id) {
    return api.get<AlumniEvent>(
      '/api/alumni/ika/events/$id',
      decoder: AlumniEvent.fromJson,
    );
  }

  Future<ApiResponse<IkaEventTicket>> registerMemberEvent(String id) {
    return api.post<IkaEventTicket>(
      '/api/alumni/ika/events/$id/register',
      decoder: IkaEventTicket.fromJson,
    );
  }

  Future<ApiResponse<IkaEventTicket>> getMemberEventTicket(String id) {
    return api.get<IkaEventTicket>(
      '/api/alumni/ika/events/$id/ticket',
      decoder: IkaEventTicket.fromJson,
    );
  }

  Future<ApiResponse<IkaPaymentOverview>> getPayments() {
    return api.get<IkaPaymentOverview>(
      '/api/alumni/ika/payments',
      decoder: IkaPaymentOverview.fromJson,
    );
  }

  Future<ApiResponse<IkaPaymentOverview>> getIkaPayments() => getPayments();

  Future<ApiResponse<IkaPaymentItem>> getPaymentDetail(String id) {
    return api.get<IkaPaymentItem>(
      '/api/alumni/ika/payments/$id',
      decoder: IkaPaymentItem.fromJson,
    );
  }

  Future<ApiResponse<IkaPaymentRecord>> uploadPaymentProof({
    required String id,
    required List<int> bytes,
    required String fileName,
    required Map<String, String> fields,
  }) {
    return api.postMultipart<IkaPaymentRecord>(
      '/api/alumni/ika/payments/$id/upload-proof',
      fieldName: 'proof_file',
      fileName: fileName,
      bytes: bytes,
      fields: fields,
      decoder: IkaPaymentRecord.fromJson,
    );
  }

  Future<ApiResponse<List<IkaPaymentRecord>>> getPaymentHistory() {
    return api.get<List<IkaPaymentRecord>>(
      '/api/alumni/ika/payment-history',
      decoder: (json) =>
          asListOfMaps(json).map(IkaPaymentRecord.fromJson).toList(),
    );
  }

  Future<ApiResponse<List<IkaVoting>>> getVotingItems() {
    return api.get<List<IkaVoting>>(
      '/api/alumni/ika/votings',
      decoder: (json) => asListOfMaps(json).map(IkaVoting.fromJson).toList(),
    );
  }

  Future<ApiResponse<List<IkaVoting>>> getIkaVotings() => getVotingItems();

  Future<ApiResponse<IkaVoting>> getVotingDetail(String id) {
    return api.get<IkaVoting>(
      '/api/alumni/ika/votings/$id',
      decoder: IkaVoting.fromJson,
    );
  }

  Future<ApiResponse<IkaVoteReceipt>> submitVote({
    required String id,
    required String optionId,
  }) {
    return api.post<IkaVoteReceipt>(
      '/api/alumni/ika/votings/$id/vote',
      body: {'option_id': optionId},
      decoder: IkaVoteReceipt.fromJson,
    );
  }

  Future<ApiResponse<IkaVotingResult>> getVotingResults(String id) {
    return api.get<IkaVotingResult>(
      '/api/alumni/ika/votings/$id/results',
      decoder: IkaVotingResult.fromJson,
    );
  }

  Future<ApiResponse<List<IkaForumCategory>>> getForumCategories() {
    return api.get<List<IkaForumCategory>>(
      '/api/alumni/ika/forum/categories',
      decoder: (json) =>
          asListOfMaps(json).map(IkaForumCategory.fromJson).toList(),
    );
  }

  Future<ApiResponse<List<IkaForumCategory>>> getIkaForumCategories() =>
      getForumCategories();

  Future<ApiResponse<List<IkaForumPost>>> getForumPosts({String? categoryId}) {
    return api.get<List<IkaForumPost>>(
      '/api/alumni/ika/forum/posts',
      queryParameters: {
        if (categoryId != null && categoryId.trim().isNotEmpty)
          'category_id': categoryId,
      },
      decoder: (json) => asListOfMaps(json).map(IkaForumPost.fromJson).toList(),
    );
  }

  Future<ApiResponse<List<IkaForumPost>>> getIkaForumPosts({
    String? categoryId,
  }) => getForumPosts(categoryId: categoryId);

  Future<ApiResponse<IkaForumPost>> createForumPost({
    required String categoryId,
    required String title,
    required String content,
  }) {
    return api.post<IkaForumPost>(
      '/api/alumni/ika/forum/posts',
      body: {'category_id': categoryId, 'title': title, 'content': content},
      decoder: IkaForumPost.fromJson,
    );
  }

  Future<ApiResponse<IkaForumPost>> getForumPostDetail(String id) {
    return api.get<IkaForumPost>(
      '/api/alumni/ika/forum/posts/$id',
      decoder: IkaForumPost.fromJson,
    );
  }

  Future<ApiResponse<IkaForumComment>> addForumComment({
    required String postId,
    required String content,
  }) {
    return api.post<IkaForumComment>(
      '/api/alumni/ika/forum/posts/$postId/comments',
      body: {'content': content},
      decoder: IkaForumComment.fromJson,
    );
  }

  Future<ApiResponse<IkaForumLikeState>> toggleForumPostLike(String id) {
    return api.post<IkaForumLikeState>(
      '/api/alumni/ika/forum/posts/$id/like',
      decoder: IkaForumLikeState.fromJson,
    );
  }

  Future<JsonMapResponse> deleteForumPost(String id) {
    return api.delete<Map<String, dynamic>>(
      '/api/alumni/ika/forum/posts/$id',
      decoder: asMapOrEmpty,
    );
  }

  Future<JsonMapResponse> reportForumPost({
    required String postId,
    required String reason,
    String? description,
  }) {
    return api.post<Map<String, dynamic>>(
      '/api/alumni/ika/forum/posts/$postId/report',
      body: {
        'reason': reason,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      },
      decoder: asMapOrEmpty,
    );
  }

  Future<JsonMapResponse> reportForumComment({
    required String commentId,
    required String reason,
    String? description,
  }) {
    return api.post<Map<String, dynamic>>(
      '/api/alumni/ika/forum/comments/$commentId/report',
      body: {
        'reason': reason,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      },
      decoder: asMapOrEmpty,
    );
  }

  Future<JsonMapResponse> blockForumUser(String alumniId) {
    return api.post<Map<String, dynamic>>(
      '/api/alumni/ika/forum/users/$alumniId/block',
      decoder: asMapOrEmpty,
    );
  }

  Future<JsonMapResponse> unblockForumUser(String alumniId) {
    return api.delete<Map<String, dynamic>>(
      '/api/alumni/ika/forum/users/$alumniId/block',
      decoder: asMapOrEmpty,
    );
  }

  Future<ApiResponse<List<ForumBlockedUser>>> getBlockedForumUsers() {
    return api.get<List<ForumBlockedUser>>(
      '/api/alumni/ika/forum/blocked-users',
      decoder: (json) =>
          asListOfMaps(json).map(ForumBlockedUser.fromJson).toList(),
    );
  }

  Future<ApiResponse<ForumSupportInfo>> getForumSupport() {
    return api.get<ForumSupportInfo>(
      '/api/alumni/ika/forum/support',
      decoder: ForumSupportInfo.fromJson,
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
