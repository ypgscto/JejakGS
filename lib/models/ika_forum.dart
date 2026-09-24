import 'json_utils.dart';

class IkaForumCategory {
  const IkaForumCategory({
    required this.id,
    required this.name,
    this.description,
    this.visibility,
    this.visibilityLabel,
  });

  final String id;
  final String name;
  final String? description;
  final String? visibility;
  final String? visibilityLabel;

  factory IkaForumCategory.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return IkaForumCategory(
      id: JsonUtils.string(json, ['id']) ?? '',
      name: JsonUtils.string(json, ['name']) ?? '',
      description: JsonUtils.string(json, ['description']),
      visibility: JsonUtils.string(json, ['visibility']),
      visibilityLabel: JsonUtils.string(json, [
        'visibility_label',
        'visibilityLabel',
      ]),
    );
  }
}

class IkaForumAuthor {
  const IkaForumAuthor({
    required this.id,
    required this.name,
    this.programStudy,
    this.batchYear,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String? programStudy;
  final int? batchYear;
  final String? photoUrl;

  factory IkaForumAuthor.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return IkaForumAuthor(
      id: JsonUtils.string(json, ['id']) ?? '',
      name: JsonUtils.string(json, ['name']) ?? '',
      programStudy: JsonUtils.string(json, ['prodi', 'program_study']),
      batchYear: JsonUtils.integer(json, ['tahun_angkatan', 'batch_year']),
      photoUrl: JsonUtils.string(json, ['photo', 'photo_url', 'avatar_url']),
    );
  }
}

class IkaForumPost {
  const IkaForumPost({
    required this.id,
    required this.title,
    required this.status,
    required this.author,
    this.category,
    this.contentExcerpt,
    this.content,
    this.isPinned = false,
    this.commentsCount = 0,
    this.likesCount = 0,
    this.isLiked = false,
    this.isOwner = false,
    this.createdAt,
    this.comments = const [],
  });

  final String id;
  final IkaForumCategory? category;
  final String title;
  final String? contentExcerpt;
  final String? content;
  final String status;
  final bool isPinned;
  final IkaForumAuthor author;
  final int commentsCount;
  final int likesCount;
  final bool isLiked;
  final bool isOwner;
  final DateTime? createdAt;
  final List<IkaForumComment> comments;

  factory IkaForumPost.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);
    final categoryJson = JsonUtils.asMap(json['category']);

    return IkaForumPost(
      id: JsonUtils.string(json, ['id']) ?? '',
      category: categoryJson.isEmpty
          ? null
          : IkaForumCategory.fromJson(categoryJson),
      title: JsonUtils.string(json, ['title']) ?? '',
      contentExcerpt: JsonUtils.string(json, ['content_excerpt']),
      content: JsonUtils.string(json, ['content']),
      status: JsonUtils.string(json, ['status']) ?? '',
      isPinned: JsonUtils.boolean(json, ['is_pinned', 'isPinned']),
      author: IkaForumAuthor.fromJson(json['author']),
      commentsCount:
          JsonUtils.integer(json, ['comments_count', 'commentsCount']) ?? 0,
      likesCount: JsonUtils.integer(json, ['likes_count', 'likesCount']) ?? 0,
      isLiked: JsonUtils.boolean(json, ['is_liked', 'isLiked']),
      isOwner: JsonUtils.boolean(json, ['is_owner', 'isOwner']),
      createdAt: JsonUtils.dateTime(json, ['created_at', 'createdAt']),
      comments: JsonUtils.asMapList(
        json['comments'],
      ).map(IkaForumComment.fromJson).toList(),
    );
  }
}

class IkaForumComment {
  const IkaForumComment({
    required this.id,
    required this.content,
    required this.author,
    this.isOwner = false,
    this.createdAt,
  });

  final String id;
  final String content;
  final IkaForumAuthor author;
  final bool isOwner;
  final DateTime? createdAt;

  factory IkaForumComment.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return IkaForumComment(
      id: JsonUtils.string(json, ['id']) ?? '',
      content: JsonUtils.string(json, ['content']) ?? '',
      author: IkaForumAuthor.fromJson(json['author']),
      isOwner: JsonUtils.boolean(json, ['is_owner', 'isOwner']),
      createdAt: JsonUtils.dateTime(json, ['created_at', 'createdAt']),
    );
  }
}

class ForumBlockedUser {
  const ForumBlockedUser({
    required this.alumniId,
    required this.name,
    this.programStudy,
    this.batchYear,
    this.photoUrl,
  });

  final String alumniId;
  final String name;
  final String? programStudy;
  final String? batchYear;
  final String? photoUrl;

  factory ForumBlockedUser.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return ForumBlockedUser(
      alumniId: JsonUtils.string(json, ['alumni_id', 'id']) ?? '',
      name: JsonUtils.string(json, ['name']) ?? 'Alumni',
      programStudy: JsonUtils.string(json, ['prodi', 'program_study']),
      batchYear: JsonUtils.string(json, ['tahun_angkatan', 'batch_year']),
      photoUrl: JsonUtils.string(json, ['photo', 'photo_url', 'avatar_url']),
    );
  }
}

class ForumSupportInfo {
  const ForumSupportInfo({
    required this.email,
    required this.website,
    required this.whatsapp,
  });

  static const fallback = ForumSupportInfo(
    email: 'support@stikesgunungsari.ac.id',
    website: 'https://stikesgunungsari.ac.id',
    whatsapp: '0811-4610-095',
  );

  final String email;
  final String website;
  final String whatsapp;

  factory ForumSupportInfo.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);
    final email = JsonUtils.string(json, ['email']);
    final website = JsonUtils.string(json, ['website']);
    final whatsapp = JsonUtils.string(json, ['whatsapp']);

    if (email == null || website == null || whatsapp == null) {
      return fallback;
    }

    return ForumSupportInfo(
      email: email,
      website: website,
      whatsapp: whatsapp,
    );
  }
}

class IkaForumLikeState {
  const IkaForumLikeState({required this.liked, required this.likesCount});

  final bool liked;
  final int likesCount;

  factory IkaForumLikeState.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return IkaForumLikeState(
      liked: JsonUtils.boolean(json, ['liked']),
      likesCount: JsonUtils.integer(json, ['likes_count', 'likesCount']) ?? 0,
    );
  }
}
