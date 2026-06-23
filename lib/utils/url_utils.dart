class UrlUtils {
  const UrlUtils._();

  static String normalizeBaseUrl(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return '';
    }

    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}
