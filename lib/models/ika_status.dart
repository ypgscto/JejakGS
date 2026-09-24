import 'json_utils.dart';

enum IkaMembershipState {
  notRegistered,
  inactive,
  pending,
  revisionRequired,
  declined,
  active,
  expired,
  board,
  unknown;

  static IkaMembershipState fromJson(Object? value) {
    final normalized = value?.toString().toLowerCase().trim();
    final normalizedCamel = normalized?.replaceAll('_', '');

    if (normalized == 'menunggu_verifikasi') {
      return IkaMembershipState.pending;
    }

    if (normalized == 'perlu_perbaikan') {
      return IkaMembershipState.revisionRequired;
    }

    if (normalized == 'ditolak') {
      return IkaMembershipState.declined;
    }

    if (normalized == 'anggota_aktif') {
      return IkaMembershipState.active;
    }

    if (normalized == 'anggota_nonaktif') {
      return IkaMembershipState.inactive;
    }

    if (normalized == 'pengurus_ika') {
      return IkaMembershipState.board;
    }

    return IkaMembershipState.values.firstWhere(
      (state) => state.name.toLowerCase() == normalizedCamel,
      orElse: () => IkaMembershipState.unknown,
    );
  }
}

enum IkaRole {
  alumni,
  member,
  board,
  admin,
  unknown;

  static IkaRole fromJson(Object? value) {
    final normalized = value?.toString().toLowerCase().trim();

    if (normalized == 'ika_member') {
      return IkaRole.member;
    }

    if (normalized == 'ika_officer' || normalized == 'ika_board') {
      return IkaRole.board;
    }

    if (normalized == 'alumni_admin' || normalized == 'super_admin') {
      return IkaRole.admin;
    }

    return IkaRole.values.firstWhere(
      (role) => role.name == normalized,
      orElse: () => IkaRole.unknown,
    );
  }
}

class IkaStatus {
  const IkaStatus({
    required this.state,
    required this.role,
    this.memberNumber,
    this.label,
    this.description,
    this.revisionNote,
    this.rejectionReason,
    this.registeredAt,
    this.expiredAt,
  });

  final IkaMembershipState state;
  final IkaRole role;
  final String? memberNumber;
  final String? label;
  final String? description;
  final String? revisionNote;
  final String? rejectionReason;
  final DateTime? registeredAt;
  final DateTime? expiredAt;

  bool get isActive =>
      state == IkaMembershipState.active || state == IkaMembershipState.board;

  bool get canAccessMemberFeatures => isActive;

  bool get canAccessBoardFeatures => state == IkaMembershipState.board;

  factory IkaStatus.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);
    final isBoard = JsonUtils.boolean(json, ['is_ika_board', 'is_board']);
    final isMember = JsonUtils.boolean(json, ['is_member', 'ika_is_member']);

    return IkaStatus(
      state: IkaMembershipState.fromJson(
        json['status'] ??
            json['state'] ??
            json['ika_membership_status'] ??
            json['membership_status'] ??
            (isBoard ? 'board' : (isMember ? 'active' : value)),
      ),
      role: IkaRole.fromJson(
        json['role'] ?? (isBoard ? 'board' : (isMember ? 'member' : 'alumni')),
      ),
      memberNumber: JsonUtils.string(json, [
        'member_number',
        'ika_member_number',
        'memberNumber',
        'member_card_number',
        'ika_member_card_number',
      ]),
      label: JsonUtils.string(json, [
        'label',
        'status_label',
        'membership_status',
      ]),
      description: JsonUtils.string(json, ['description']),
      revisionNote: JsonUtils.string(json, ['revision_note', 'revisionNote']),
      rejectionReason: JsonUtils.string(json, ['rejection_reason', 'reason']),
      registeredAt: JsonUtils.dateTime(json, [
        'registered_at',
        'registeredAt',
        'ika_registered_at',
        'ika_joined_at',
      ]),
      expiredAt: JsonUtils.dateTime(json, ['expired_at', 'expiredAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': state.name,
      'role': role.name,
      'member_number': memberNumber,
      'label': label,
      'description': description,
      'revision_note': revisionNote,
      'rejection_reason': rejectionReason,
      'registered_at': registeredAt?.toIso8601String(),
      'expired_at': expiredAt?.toIso8601String(),
    };
  }
}
