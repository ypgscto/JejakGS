import '../models/api_response.dart';
import 'api_service.dart';

abstract class BaseSimawaService {
  const BaseSimawaService({required ApiService apiService}) : api = apiService;

  final ApiService api;

  T asMapOrEmpty<T extends Map<String, dynamic>>(Object? json) {
    if (json is Map<String, dynamic>) {
      return json as T;
    }

    return <String, dynamic>{} as T;
  }

  List<Map<String, dynamic>> asListOfMaps(Object? json) {
    if (json is List) {
      return json
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return const [];
  }
}

typedef JsonMapResponse = ApiResponse<Map<String, dynamic>>;
typedef JsonListResponse = ApiResponse<List<Map<String, dynamic>>>;
