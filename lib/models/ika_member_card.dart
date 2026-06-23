import 'json_utils.dart';

class IkaMemberCard {
  const IkaMemberCard({
    required this.memberNumber,
    required this.alumniName,
    required this.nim,
    required this.programStudy,
    required this.batchYear,
    this.memberStatus,
    this.ikaPosition,
    this.validUntil,
    this.avatarUrl,
    this.qrCodeUrl,
    this.cardImageUrl,
  });

  final String memberNumber;
  final String alumniName;
  final String nim;
  final String programStudy;
  final int batchYear;
  final String? memberStatus;
  final String? ikaPosition;
  final DateTime? validUntil;
  final String? avatarUrl;
  final String? qrCodeUrl;
  final String? cardImageUrl;

  factory IkaMemberCard.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return IkaMemberCard(
      memberNumber:
          JsonUtils.string(json, ['member_number', 'memberNumber']) ?? '',
      alumniName: JsonUtils.string(json, ['alumni_name', 'name']) ?? '',
      nim: JsonUtils.string(json, ['nim', 'student_number']) ?? '',
      programStudy: JsonUtils.string(json, ['program_study', 'prodi']) ?? '',
      batchYear: JsonUtils.integer(json, ['batch_year', 'angkatan']) ?? 0,
      memberStatus: JsonUtils.string(json, ['member_status', 'status']),
      ikaPosition: JsonUtils.string(json, [
        'ika_position',
        'position',
        'jabatan',
      ]),
      validUntil: JsonUtils.dateTime(json, ['valid_until', 'validUntil']),
      avatarUrl: JsonUtils.string(json, ['avatar_url', 'photo_url', 'photo']),
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
      'member_status': memberStatus,
      'ika_position': ikaPosition,
      'valid_until': validUntil?.toIso8601String(),
      'avatar_url': avatarUrl,
      'qr_code_url': qrCodeUrl,
      'card_image_url': cardImageUrl,
    };
  }
}
