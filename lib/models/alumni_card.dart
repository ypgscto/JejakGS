import 'alumni_verification_status.dart';
import 'ika_status.dart';
import 'json_utils.dart';

class AlumniCard {
  const AlumniCard({
    required this.id,
    required this.nim,
    required this.name,
    required this.programStudy,
    required this.batchYear,
    required this.graduationYear,
    required this.verificationStatus,
    required this.ikaStatus,
    this.alumniNumber,
    this.avatarUrl,
    this.qrCodeUrl,
  });

  final String id;
  final String nim;
  final String? alumniNumber;
  final String name;
  final String programStudy;
  final int batchYear;
  final int graduationYear;
  final AlumniVerificationStatus verificationStatus;
  final IkaStatus ikaStatus;
  final String? avatarUrl;
  final String? qrCodeUrl;

  factory AlumniCard.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return AlumniCard(
      id: JsonUtils.string(json, ['id', 'alumni_id']) ?? '',
      nim: JsonUtils.string(json, ['nim', 'student_number']) ?? '',
      alumniNumber: JsonUtils.string(json, ['alumni_number', 'card_number']),
      name: JsonUtils.string(json, ['name', 'nama']) ?? '',
      programStudy:
          JsonUtils.string(json, ['program_study', 'study_program', 'prodi']) ??
          '',
      batchYear:
          JsonUtils.integer(json, ['batch_year', 'cohort_year', 'angkatan']) ??
          0,
      graduationYear:
          JsonUtils.integer(json, ['graduation_year', 'tahun_lulus']) ?? 0,
      verificationStatus: AlumniVerificationStatus.fromJson(
        json['verification_status'] ?? json['verificationStatus'],
      ),
      ikaStatus: IkaStatus.fromJson(json['ika_status'] ?? json['ikaStatus']),
      avatarUrl: JsonUtils.string(json, ['avatar_url', 'photo_url', 'photo']),
      qrCodeUrl: JsonUtils.string(json, ['qr_code_url', 'qrCodeUrl']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nim': nim,
      'alumni_number': alumniNumber,
      'name': name,
      'program_study': programStudy,
      'batch_year': batchYear,
      'graduation_year': graduationYear,
      'verification_status': verificationStatus.toJson(),
      'ika_status': ikaStatus.toJson(),
      'avatar_url': avatarUrl,
      'qr_code_url': qrCodeUrl,
    };
  }
}
