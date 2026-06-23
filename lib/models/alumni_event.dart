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
    this.accessLevel,
    this.registrationStatus,
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
  final String? accessLevel;
  final String? registrationStatus;
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
          JsonUtils.dateTime(json, ['start_at', 'startAt', 'date']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endAt: JsonUtils.dateTime(json, ['end_at', 'endAt']),
      location: JsonUtils.string(json, ['location', 'venue']),
      isOnline: JsonUtils.boolean(json, ['is_online', 'online']),
      registrationUrl: JsonUtils.string(json, [
        'registration_url',
        'registrationUrl',
      ]),
      imageUrl: JsonUtils.string(json, ['image_url', 'imageUrl']),
      category: JsonUtils.string(json, ['category']),
      accessLevel: JsonUtils.string(json, ['access_level', 'accessLevel']),
      registrationStatus: JsonUtils.string(json, [
        'registration_status',
        'registrationStatus',
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
      'access_level': accessLevel,
      'registration_status': registrationStatus,
      'participant_qr_code_url': participantQrCodeUrl,
      'attendance_qr_code_url': attendanceQrCodeUrl,
      'certificate_url': certificateUrl,
      'gallery_urls': galleryUrls,
    };
  }
}
