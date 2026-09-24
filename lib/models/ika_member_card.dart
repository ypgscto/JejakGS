import 'json_utils.dart';

class IkaMemberCard {
  const IkaMemberCard({
    required this.memberNumber,
    required this.alumniName,
    required this.nim,
    required this.programStudy,
    required this.batchYear,
    required this.graduationYear,
    this.memberStatus,
    this.memberStatusLabel,
    this.ikaPosition,
    this.joinedAt,
    this.validUntil,
    this.avatarUrl,
    this.qrValue,
    this.qrCodeUrl,
    this.cardImageUrl,
  });

  final String memberNumber;
  final String alumniName;
  final String nim;
  final String programStudy;
  final int batchYear;
  final int graduationYear;
  final String? memberStatus;
  final String? memberStatusLabel;
  final String? ikaPosition;
  final DateTime? joinedAt;
  final DateTime? validUntil;
  final String? avatarUrl;
  final String? qrValue;
  final String? qrCodeUrl;
  final String? cardImageUrl;

  factory IkaMemberCard.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return IkaMemberCard(
      memberNumber:
          JsonUtils.string(json, [
            'member_number',
            'ika_member_number',
            'memberNumber',
          ]) ??
          '',
      alumniName: JsonUtils.string(json, ['alumni_name', 'name']) ?? '',
      nim: JsonUtils.string(json, ['nim', 'student_number']) ?? '',
      programStudy:
          JsonUtils.string(json, ['program_study', 'study_program', 'prodi']) ??
          '',
      batchYear:
          JsonUtils.integer(json, [
            'batch_year',
            'cohort_year',
            'tahun_angkatan',
            'angkatan',
          ]) ??
          0,
      graduationYear:
          JsonUtils.integer(json, ['graduation_year', 'tahun_lulus']) ?? 0,
      memberStatus: JsonUtils.string(json, [
        'member_status',
        'membership_status',
        'ika_membership_status',
        'status',
      ]),
      memberStatusLabel: JsonUtils.string(json, [
        'member_status_label',
        'membership_status_label',
        'ika_status_label',
        'status_label',
      ]),
      ikaPosition: JsonUtils.string(json, [
        'ika_position',
        'position',
        'jabatan',
      ]),
      joinedAt: JsonUtils.dateTime(json, ['joined_at', 'ika_joined_at']),
      validUntil: JsonUtils.dateTime(json, ['valid_until', 'validUntil']),
      avatarUrl: JsonUtils.string(json, ['avatar_url', 'photo_url', 'photo']),
      qrValue: JsonUtils.string(json, ['qr_code_value', 'qr_value', 'qrData']),
      qrCodeUrl: JsonUtils.string(json, ['qr_code_url', 'qrCodeUrl']),
      cardImageUrl: JsonUtils.string(json, ['card_image_url', 'cardImageUrl']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_number': memberNumber,
      'alumni_name': alumniName,
      'nim': nim,
      'program_study': programStudy,
      'batch_year': batchYear,
      'graduation_year': graduationYear,
      'member_status': memberStatus,
      'member_status_label': memberStatusLabel,
      'ika_position': ikaPosition,
      'joined_at': joinedAt?.toIso8601String(),
      'valid_until': validUntil?.toIso8601String(),
      'avatar_url': avatarUrl,
      'qr_code_value': qrValue,
      'qr_code_url': qrCodeUrl,
      'card_image_url': cardImageUrl,
    };
  }
}
