import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_shadows.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({
    required this.appState,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<NotificationItem> _items = const [];
  NotificationItem? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_selected != null) {
      return _NotificationDetail(
        appState: widget.appState,
        item: _selected!,
        onBack: () => setState(() => _selected = null),
        onReadChanged: _load,
      );
    }

    if (_isLoading) {
      return const LoadingState(message: 'Memuat notifikasi...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: 'Notifikasi belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    final unread = _items.where((item) => !item.isRead).length;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                'Notifikasi',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            _UnreadBadge(count: unread),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppHeader(
          title: 'Notifikasi',
          subtitle: 'Pemberitahuan resmi dari SIMAWA-GS.',
          leadingIcon: Icons.notifications_rounded,
          bottom: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              SecondaryButton(
                label: 'Tandai Semua Dibaca',
                icon: Icons.done_all_rounded,
                onPressed: _markAllRead,
              ),
              SecondaryButton(
                label: 'Registrasi Push Token',
                icon: Icons.notifications_active_rounded,
                onPressed: _showPushTokenInfo,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (_items.isEmpty)
          const EmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'Belum ada notifikasi',
            description: 'Notifikasi akan tampil dari SIMAWA-GS saat tersedia.',
          )
        else
          for (final item in _items) ...[
            _NotificationTile(
              item: item,
              onTap: () => setState(() => _selected = item),
              onMarkRead: () => _markRead(item),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final response = await widget.appState.notificationService
        .getNotifications();
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _items = response.data ?? const [];
        widget.appState.setUnreadNotificationCount(
          _items.where((item) => !item.isRead).length,
        );
      } else {
        _errorMessage = response.message ?? 'Notifikasi belum tersedia.';
      }
    });
  }

  Future<void> _markRead(NotificationItem item) async {
    await widget.appState.notificationService.markAsRead(item.id);
    await _load();
  }

  Future<void> _markAllRead() async {
    await widget.appState.notificationService.markAllAsRead();
    await _load();
  }

  void _showPushTokenInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Push token akan didaftarkan ke SIMAWA-GS setelah token dari Firebase/APNs tersedia.',
        ),
      ),
    );
  }
}

class _NotificationDetail extends StatelessWidget {
  const _NotificationDetail({
    required this.appState,
    required this.item,
    required this.onBack,
    required this.onReadChanged,
  });

  final AppState appState;
  final NotificationItem item;
  final VoidCallback onBack;
  final VoidCallback onReadChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                'Detail Notifikasi',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        StatusCard(
          title: item.title,
          description:
              '${item.message}\n\nJenis: ${_labelFor(item.type)}${item.createdAt == null ? '' : '\nDiterima: ${item.createdAt!.toLocal().toString().split('.').first}'}',
          icon: _iconFor(item.type),
          accentColor: item.isRead ? AppColors.textSecondary : AppColors.maroon,
        ),
        if (!item.isRead) ...[
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Tandai Sudah Dibaca',
            icon: Icons.check_rounded,
            fullWidth: true,
            onPressed: () async {
              await appState.notificationService.markAsRead(item.id);
              onReadChanged();
              onBack();
            },
          ),
        ],
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.onTap,
    required this.onMarkRead,
  });

  final NotificationItem item;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: item.isRead ? AppColors.mediumGrey : AppColors.gold,
          ),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Icon(_iconFor(item.type), color: AppColors.maroon),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (!item.isRead)
              IconButton(
                onPressed: onMarkRead,
                icon: const Icon(Icons.check_circle_outline_rounded),
              ),
          ],
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '$count belum dibaca',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.darkMaroon,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

IconData _iconFor(NotificationType type) {
  return switch (type) {
    NotificationType.tracer ||
    NotificationType.tracerRevision => Icons.assignment_rounded,
    NotificationType.verification ||
    NotificationType.alumniVerified => Icons.verified_user_rounded,
    NotificationType.ika ||
    NotificationType.ikaApproved ||
    NotificationType.ikaRejected ||
    NotificationType.ikaBroadcast ||
    NotificationType.donationReminder => Icons.groups_rounded,
    NotificationType.job || NotificationType.newJob => Icons.work_rounded,
    NotificationType.event || NotificationType.newEvent => Icons.event_rounded,
    NotificationType.campusAnnouncement => Icons.campaign_rounded,
    NotificationType.batchmateUpdate => Icons.diversity_3_rounded,
    NotificationType.privacy => Icons.privacy_tip_rounded,
    NotificationType.general ||
    NotificationType.unknown => Icons.notifications_rounded,
  };
}

String _labelFor(NotificationType type) {
  return switch (type) {
    NotificationType.tracer => 'Tracer belum diisi',
    NotificationType.tracerRevision => 'Tracer perlu revisi',
    NotificationType.alumniVerified => 'Verifikasi alumni berhasil',
    NotificationType.ikaApproved => 'Pendaftaran IKA disetujui',
    NotificationType.ikaRejected => 'Pendaftaran IKA ditolak',
    NotificationType.newJob => 'Loker baru',
    NotificationType.newEvent => 'Event baru',
    NotificationType.campusAnnouncement => 'Pengumuman kampus',
    NotificationType.ikaBroadcast => 'Broadcast IKA',
    NotificationType.donationReminder => 'Reminder iuran/donasi',
    NotificationType.batchmateUpdate => 'Update Jejak Angkatan',
    _ => type.name,
  };
}
