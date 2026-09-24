import '../models/models.dart';
import 'api_service.dart';
import 'base_simawa_service.dart';

class AlumniService extends BaseSimawaService {
  const AlumniService({required super.apiService});

  Future<JsonMapResponse> getProfile() {
    return api.get<Map<String, dynamic>>('/profile', decoder: asMapOrEmpty);
  }

  Future<JsonMapResponse> updateProfile(Map<String, dynamic> payload) {
    return api.patch<Map<String, dynamic>>(
      '/profile',
      body: payload,
      decoder: asMapOrEmpty,
    );
  }

  Future<JsonMapResponse> updateProfilePhoto({
    required List<int> bytes,
    required String fileName,
  }) {
    return api.postMultipart<Map<String, dynamic>>(
      '/profile/photo',
      fieldName: 'profile_photo',
      fileName: fileName,
      bytes: bytes,
      decoder: asMapOrEmpty,
    );
  }

  Future<JsonMapResponse> submitVerification({
    required Map<String, String> fields,
    List<int>? diplomaPhotoBytes,
    String? diplomaPhotoFileName,
    List<int>? profilePhotoBytes,
    String? profilePhotoFileName,
  }) {
    final additionalFiles = <ApiMultipartFile>[];
    if (profilePhotoBytes != null &&
        profilePhotoFileName != null &&
        profilePhotoBytes.isNotEmpty) {
      additionalFiles.add(
        ApiMultipartFile(
          fieldName: 'profile_photo',
          fileName: profilePhotoFileName,
          bytes: profilePhotoBytes,
        ),
      );
    }

    final hasDiploma =
        diplomaPhotoBytes != null &&
        diplomaPhotoFileName != null &&
        diplomaPhotoBytes.isNotEmpty;

    return api.postMultipart<Map<String, dynamic>>(
      '/verification/submit',
      fieldName: hasDiploma ? 'diploma_photo' : null,
      fileName: hasDiploma ? diplomaPhotoFileName : null,
      bytes: hasDiploma ? diplomaPhotoBytes : null,
      additionalFiles: additionalFiles,
      fields: fields,
      decoder: asMapOrEmpty,
    );
  }

  Future<ApiResponse<AlumniCard>> getAlumniCard() {
    return api.get<AlumniCard>('/alumni-card', decoder: AlumniCard.fromJson);
  }

  Future<JsonListResponse> searchAlumni(Map<String, dynamic> queryParameters) {
    return api.get<List<Map<String, dynamic>>>(
      '/alumni',
      queryParameters: queryParameters,
      decoder: asListOfMaps,
    );
  }
}
