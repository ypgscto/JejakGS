import 'json_utils.dart';

class IkaEventTicket {
  const IkaEventTicket({
    required this.registrationId,
    required this.eventId,
    required this.eventTitle,
    required this.name,
    required this.nim,
    this.eventDate,
    this.location,
    this.programStudy,
    this.registrationStatus,
    this.registeredAt,
    this.checkinAt,
    this.qrCodeValue,
    this.certificateUrl,
  });

  final String registrationId;
  final String eventId;
  final String eventTitle;
  final DateTime? eventDate;
  final String? location;
  final String name;
  final String nim;
  final String? programStudy;
  final String? registrationStatus;
  final DateTime? registeredAt;
  final DateTime? checkinAt;
  final String? qrCodeValue;
  final String? certificateUrl;

  factory IkaEventTicket.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return IkaEventTicket(
      registrationId:
          JsonUtils.string(json, ['registration_id', 'registrationId']) ?? '',
      eventId: JsonUtils.string(json, ['event_id', 'eventId']) ?? '',
      eventTitle: JsonUtils.string(json, ['event_title', 'eventTitle']) ?? '',
      eventDate: JsonUtils.dateTime(json, ['event_date', 'eventDate']),
      location: JsonUtils.string(json, ['location']),
      name: JsonUtils.string(json, ['name']) ?? '',
      nim: JsonUtils.string(json, ['nim']) ?? '',
      programStudy: JsonUtils.string(json, ['prodi', 'program_study']),
      registrationStatus: JsonUtils.string(json, [
        'registration_status',
        'registrationStatus',
      ]),
      registeredAt: JsonUtils.dateTime(json, ['registered_at', 'registeredAt']),
      checkinAt: JsonUtils.dateTime(json, ['checkin_at', 'checkinAt']),
      qrCodeValue: JsonUtils.string(json, ['qr_code_value', 'qrCodeValue']),
      certificateUrl: JsonUtils.string(json, [
        'certificate_url',
        'certificateUrl',
      ]),
    );
  }
}
