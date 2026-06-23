import 'alumni_event.dart';
import 'announcement_item.dart';
import 'ika_status.dart';
import 'json_utils.dart';
import 'job_post.dart';
import 'tracer_status.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.totalAlumni,
    required this.verifiedAlumni,
    required this.activeIkaMembers,
    required this.openJobs,
    required this.upcomingEvents,
    required this.unreadNotifications,
    this.tracerCompletionRate,
    this.tracerStatus,
    this.ikaStatus,
    this.latestAnnouncements = const [],
    this.latestJobs = const [],
    this.latestEvents = const [],
  });

  final int totalAlumni;
  final int verifiedAlumni;
  final int activeIkaMembers;
  final int openJobs;
  final int upcomingEvents;
  final int unreadNotifications;
  final double? tracerCompletionRate;
  final TracerStatus? tracerStatus;
  final IkaStatus? ikaStatus;
  final List<AnnouncementItem> latestAnnouncements;
  final List<JobPost> latestJobs;
  final List<AlumniEvent> latestEvents;

  factory DashboardSummary.fromJson(Object? value) {
    final json = JsonUtils.asMap(value);

    return DashboardSummary(
      totalAlumni: JsonUtils.integer(json, ['total_alumni']) ?? 0,
      verifiedAlumni: JsonUtils.integer(json, ['verified_alumni']) ?? 0,
      activeIkaMembers: JsonUtils.integer(json, ['active_ika_members']) ?? 0,
      openJobs: JsonUtils.integer(json, ['open_jobs']) ?? 0,
      upcomingEvents: JsonUtils.integer(json, ['upcoming_events']) ?? 0,
      unreadNotifications:
          JsonUtils.integer(json, ['unread_notifications']) ?? 0,
      tracerCompletionRate: JsonUtils.decimal(json, ['tracer_completion_rate']),
      tracerStatus: _optionalTracerStatus(
        json['tracer_status'] ?? json['tracer'],
      ),
      ikaStatus: _optionalIkaStatus(json['ika_status'] ?? json['ika']),
      latestAnnouncements: JsonUtils.asMapList(
        json['latest_announcements'] ?? json['announcements'],
      ).map(AnnouncementItem.fromJson).toList(),
      latestJobs: JsonUtils.asMapList(
        json['latest_jobs'] ?? json['jobs'],
      ).map(JobPost.fromJson).toList(),
      latestEvents: JsonUtils.asMapList(
        json['latest_events'] ?? json['events'],
      ).map(AlumniEvent.fromJson).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_alumni': totalAlumni,
      'verified_alumni': verifiedAlumni,
      'active_ika_members': activeIkaMembers,
      'open_jobs': openJobs,
      'upcoming_events': upcomingEvents,
      'unread_notifications': unreadNotifications,
      'tracer_completion_rate': tracerCompletionRate,
      'tracer_status': tracerStatus?.toJson(),
      'ika_status': ikaStatus?.toJson(),
      'latest_announcements': latestAnnouncements
          .map((item) => item.toJson())
          .toList(),
      'latest_jobs': latestJobs.map((item) => item.toJson()).toList(),
      'latest_events': latestEvents.map((item) => item.toJson()).toList(),
    };
  }

  bool get hasDashboardContent {
    return latestAnnouncements.isNotEmpty ||
        latestJobs.isNotEmpty ||
        latestEvents.isNotEmpty ||
        tracerStatus != null ||
        ikaStatus != null;
  }

  static TracerStatus? _optionalTracerStatus(Object? value) {
    final json = JsonUtils.asMap(value);
    return json.isEmpty ? null : TracerStatus.fromJson(json);
  }

  static IkaStatus? _optionalIkaStatus(Object? value) {
    final json = JsonUtils.asMap(value);
    return json.isEmpty ? null : IkaStatus.fromJson(json);
  }
}
