import 'json_utils.dart';

class AlumniEvent {
  const AlumniEvent({
    required this.id,
    required this.title,
    required this.startAt,
    this.description,
    this.endAt,
    this.location,
    this.isOnline = false,
    this.registrationUrl,
    this.imageUrl,
    this.category,
    this.categoryLabel,
    this.accessLevel,
    this.registrationStatus,
    this.statusLabel,
    this.participantStatus,
    this.startTime,
    this.endTime,
    this.onlineLink,
    this.quota,
    this.registeredCount = 0,
    this.isRegistered = false,
    this.ticketAvailable = false,
    this.participantQrCodeUrl,
    this.attendanceQrCodeUrl,
    this.certificateUrl,
    this.galleryUrls = const [],
  });

  final String id;
  final String title;
  final String? description;
  final DateTime startAt;
  final DateTime? endAt;
  final String? location;
  final bool isOnline;
  final String? registrationUrl;
  final String? imageUrl;
  final String? category;
  final String? categoryLabel;
  final String? accessLevel;
  final String? registrationStatus;
  final String? statusLabel;
  final String? participantStatus;
  final String? startTime;
  final String? endTime;
  final String? onlineLink;
  final int? quota;
  final int registeredCount;
  final bool isRegistered;
  final bool ticketAvailable;
  final String? participantQrCodeUrl;
  final String? attendanceQrCodeUrl;
  final String? certificateUrl;
  final List<String> galleryUrls;

  factory AlumniEvent.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return AlumniEvent(
      id: JsonUtils.string(json, ['id', 'event_id']) ?? '',
      title: JsonUtils.string(json, ['title', 'name']) ?? '',
      description: JsonUtils.string(json, ['description']),
      startAt:
          JsonUtils.dateTime(json, [
            'start_at',
            'startAt',
            'event_date',
            'date',
          ]) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endAt: JsonUtils.dateTime(json, ['end_at', 'endAt', 'end_date']),
      location: JsonUtils.string(json, ['location', 'venue']),
      isOnline: JsonUtils.boolean(json, [
        'is_online',
        'online',
      ], defaultValue: JsonUtils.string(json, ['online_link']) != null),
      registrationUrl: JsonUtils.string(json, [
        'registration_url',
        'registrationUrl',
      ]),
      imageUrl: JsonUtils.string(json, ['image_url', 'imageUrl']),
      category: JsonUtils.string(json, ['category']),
      categoryLabel: JsonUtils.string(json, [
        'category_label',
        'categoryLabel',
      ]),
      accessLevel: JsonUtils.string(json, ['access_level', 'accessLevel']),
      registrationStatus: JsonUtils.string(json, [
        'registration_status',
        'registrationStatus',
      ]),
      statusLabel: JsonUtils.string(json, ['status_label', 'statusLabel']),
      participantStatus: JsonUtils.string(json, [
        'participant_status',
        'participantStatus',
      ]),
      startTime: JsonUtils.string(json, ['start_time', 'startTime']),
      endTime: JsonUtils.string(json, ['end_time', 'endTime']),
      onlineLink: JsonUtils.string(json, ['online_link', 'onlineLink']),
      quota: JsonUtils.integer(json, ['quota']),
      registeredCount:
          JsonUtils.integer(json, ['registered_count', 'registeredCount']) ?? 0,
      isRegistered: JsonUtils.boolean(json, ['is_registered', 'isRegistered']),
      ticketAvailable: JsonUtils.boolean(json, [
        'ticket_available',
        'ticketAvailable',
      ]),
      participantQrCodeUrl: JsonUtils.string(json, [
        'participant_qr_code_url',
        'participantQrCodeUrl',
      ]),
      attendanceQrCodeUrl: JsonUtils.string(json, [
        'attendance_qr_code_url',
        'attendanceQrCodeUrl',
      ]),
      certificateUrl: JsonUtils.string(json, [
        'certificate_url',
        'certificateUrl',
      ]),
      galleryUrls: JsonUtils.stringList(json, ['gallery_urls', 'galleryUrls']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'location': location,
      'is_online': isOnline,
      'registration_url': registrationUrl,
      'image_url': imageUrl,
      'category': category,
      'category_label': categoryLabel,
      'access_level': accessLevel,
      'registration_status': registrationStatus,
      'status_label': statusLabel,
      'participant_status': participantStatus,
      'start_time': startTime,
      'end_time': endTime,
      'online_link': onlineLink,
      'quota': quota,
      'registered_count': registeredCount,
      'is_registered': isRegistered,
      'ticket_available': ticketAvailable,
      'participant_qr_code_url': participantQrCodeUrl,
      'attendance_qr_code_url': attendanceQrCodeUrl,
      'certificate_url': certificateUrl,
      'gallery_urls': galleryUrls,
    };
  }
}
