class JsonUtils {
  const JsonUtils._();

  static Map<String, dynamic> asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return const {};
  }

  static List<Map<String, dynamic>> asMapList(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value.map(asMap).where((item) => item.isNotEmpty).toList();
  }

  static String? string(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return null;
  }

  static int? integer(Map<String, dynamic> json, List<String> keys) {
    final value = _firstValue(json, keys);

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  static double? decimal(Map<String, dynamic> json, List<String> keys) {
    final value = _firstValue(json, keys);

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '');
  }

  static bool boolean(
    Map<String, dynamic> json,
    List<String> keys, {
    bool defaultValue = false,
  }) {
    final value = _firstValue(json, keys);

    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized = value?.toString().toLowerCase().trim();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }

    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }

    return defaultValue;
  }

  static DateTime? dateTime(Map<String, dynamic> json, List<String> keys) {
    final value = _firstValue(json, keys);

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value?.toString() ?? '');
  }

  static List<String> stringList(Map<String, dynamic> json, List<String> keys) {
    final value = _firstValue(json, keys);

    if (value is List) {
      return value
          .map((item) => item?.toString())
          .whereType<String>()
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }

    return const [];
  }

  static Object? _firstValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) {
        return json[key];
      }
    }

    return null;
  }
}
