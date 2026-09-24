import 'json_utils.dart';

class AnnouncementItem {
  const AnnouncementItem({
    required this.id,
    required this.title,
    this.message,
    this.category,
    this.imageUrl,
    this.isBanner = false,
    this.isBookmarked = false,
    this.publishedAt,
  });

  final String id;
  final String title;
  final String? message;
  final String? category;
  final String? imageUrl;
  final bool isBanner;
  final bool isBookmarked;
  final DateTime? publishedAt;

  factory AnnouncementItem.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return AnnouncementItem(
      id: JsonUtils.string(json, ['id', 'announcement_id']) ?? '',
      title: JsonUtils.string(json, ['title', 'judul']) ?? '',
      message: JsonUtils.string(json, [
        'message',
        'summary',
        'body',
        'content',
      ]),
      category: JsonUtils.string(json, ['category', 'kategori']),
      imageUrl: JsonUtils.string(json, ['image_url', 'imageUrl']),
      isBanner: JsonUtils.boolean(json, ['is_banner', 'banner']),
      isBookmarked: JsonUtils.boolean(json, ['is_bookmarked', 'bookmarked']),
      publishedAt: JsonUtils.dateTime(json, ['published_at', 'created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'category': category,
      'image_url': imageUrl,
      'is_banner': isBanner,
      'is_bookmarked': isBookmarked,
      'published_at': publishedAt?.toIso8601String(),
    };
  }
}
