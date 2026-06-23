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
    required List<int> diplomaPhotoBytes,
    required String diplomaPhotoFileName,
    required List<int> profilePhotoBytes,
    required String profilePhotoFileName,
  }) {
    return api.postMultipart<Map<String, dynamic>>(
      '/verification/submit',
      fieldName: 'diploma_photo',
      fileName: diplomaPhotoFileName,
      bytes: diplomaPhotoBytes,
      additionalFiles: [
        ApiMultipartFile(
          fieldName: 'profile_photo',
          fileName: profilePhotoFileName,
          bytes: profilePhotoBytes,
        ),
      ],
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
