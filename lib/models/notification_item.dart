import 'json_utils.dart';

enum NotificationType {
  general,
  verification,
  tracer,
  tracerRevision,
  alumniVerified,
  ika,
  ikaApproved,
  ikaRejected,
  job,
  newJob,
  event,
  newEvent,
  campusAnnouncement,
  ikaBroadcast,
  donationReminder,
  batchmateUpdate,
  privacy,
  unknown;

  static NotificationType fromJson(Object? value) {
    final normalized = value?.toString().toLowerCase().replaceAll('_', '');

    return NotificationType.values.firstWhere(
      (type) => type.name.toLowerCase() == normalized,
      orElse: () => NotificationType.unknown,
    );
  }
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.actionUrl,
    this.createdAt,
    this.readAt,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final String? actionUrl;
  final DateTime? createdAt;
  final DateTime? readAt;

  factory NotificationItem.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return NotificationItem(
      id: JsonUtils.string(json, ['id', 'notification_id']) ?? '',
      title: JsonUtils.string(json, ['title']) ?? '',
      message: JsonUtils.string(json, ['message', 'body']) ?? '',
      type: NotificationType.fromJson(json['type']),
      isRead: JsonUtils.boolean(json, ['is_read', 'read']),
      actionUrl: JsonUtils.string(json, ['action_url', 'actionUrl']),
      createdAt: JsonUtils.dateTime(json, ['created_at', 'createdAt']),
      readAt: JsonUtils.dateTime(json, ['read_at', 'readAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'is_read': isRead,
      'action_url': actionUrl,
      'created_at': createdAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }
}
