import 'package:flutter/material.dart';

import '../config/app_routes.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_shadows.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.appState,
    required this.onShortcutSelected,
    super.key,
  });

  final AppState appState;
  final ValueChanged<String> onShortcutSelected;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadDashboardIfVerified);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final profile = widget.appState.alumniProfile;
        final summary = widget.appState.dashboardSummary;
        final isVerified = _isVerified(profile);

        return RefreshIndicator(
          color: AppColors.maroon,
          onRefresh: isVerified
              ? () => widget.appState.loadDashboard(forceRefresh: true)
              : widget.appState.refreshProfile,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              CompactHomeHeader(profile: profile, summary: summary),
              const SizedBox(height: AppSpacing.md),
              if (!isVerified && profile != null) ...[
                _CompactVerificationPanel(
                  status: profile.verificationStatus,
                  onFixProfile: widget.appState.showCompleteProfile,
                ),
              ] else
                _CompactDashboard(
                  appState: widget.appState,
                  summary: summary,
                  onShortcutSelected: widget.onShortcutSelected,
                ),
            ],
          ),
        );
      },
    );
  }

  bool _isVerified(AlumniProfile? profile) {
    return profile?.verificationStatus.state ==
        AlumniVerificationState.verified;
  }

  Future<void> _loadDashboardIfVerified() async {
    if (_isVerified(widget.appState.alumniProfile)) {
      await widget.appState.loadUnreadNotifications();
      await widget.appState.loadDashboard();
    }
  }
}

class CompactHomeHeader extends StatelessWidget {
  const CompactHomeHeader({
    required this.profile,
    required this.summary,
    super.key,
  });

  final AlumniProfile? profile;
  final DashboardSummary? summary;

  @override
  Widget build(BuildContext context) {
    final name = profile?.name.trim().isNotEmpty == true
        ? profile!.name.trim()
        : 'Alumni';
    final programText = profile == null
        ? 'Layanan alumni SIMAWA-GS'
        : 'Alumni ${profile!.programStudy}';

    return Container(
      constraints: const BoxConstraints(minHeight: 224, maxHeight: 250),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.maroon, AppColors.darkMaroon],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.soft,
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/images/stikes_gunung_sari.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: profile == null ? 0 : 108,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo,',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                  height: 1.0,
                                ),
                          ),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            programText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.white.withValues(
                                    alpha: 0.86,
                                  ),
                                  height: 1.2,
                                ),
                          ),
                          if (profile != null) ...[
                            const SizedBox(height: 2),
                            _HeaderInfoText('Angkatan ${profile!.batchYear}'),
                            const SizedBox(height: 2),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: 2,
                              children: [
                                _HeaderInfoText(
                                  'No.Alumni ${_alumniNumber(profile!)} (${profile!.nim})',
                                ),
                                _HeaderInfoText(
                                  'Lulus ${profile!.graduationYear}',
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(right: profile == null ? 0 : 116),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _StatusPill(
                      icon: Icons.verified_rounded,
                      label: _verificationLabel(profile?.verificationStatus),
                    ),
                    _StatusPill(
                      icon: Icons.groups_rounded,
                      label: _ikaLabel(
                        summary?.ikaStatus ?? profile?.ikaStatus,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (profile != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: _HeaderAvatar(profile: profile!, size: 104),
            ),
        ],
      ),
    );
  }

  static String _verificationLabel(AlumniVerificationStatus? status) {
    return status?.label ?? _titleCase(status?.state.name ?? 'pending');
  }

  static String _alumniNumber(AlumniProfile profile) {
    final value = profile.alumniNumber?.trim();
    return value == null || value.isEmpty ? '-' : value;
  }

  static String _ikaLabel(IkaStatus? status) {
    if (status == null) {
      return 'IKA Inactive';
    }

    if (status.state == IkaMembershipState.board) {
      return 'IKA Pengurus';
    }

    return 'IKA ${status.label ?? _titleCase(status.state.name)}';
  }

  static String _titleCase(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1).replaceAll('_', ' ');
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.gold),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderInfoText extends StatelessWidget {
  const _HeaderInfoText(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AppColors.white.withValues(alpha: 0.84),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({required this.profile, required this.size});

  final AlumniProfile profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _NetworkAvatar(
      name: profile.name,
      photoUrl: profile.avatarUrl,
      size: size,
      textStyle: Theme.of(context).textTheme.titleLarge,
    );
  }
}

class _NetworkAvatar extends StatelessWidget {
  const _NetworkAvatar({
    required this.name,
    required this.photoUrl,
    required this.size,
    this.textStyle,
  });

  final String name;
  final String? photoUrl;
  final double size;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    final url = photoUrl?.trim();

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: AppColors.softGold,
        child: url == null || url.isEmpty
            ? _InitialsLabel(initials: initials, textStyle: textStyle)
            : Image.network(
                url,
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                errorBuilder: (context, error, stackTrace) {
                  return _InitialsLabel(
                    initials: initials,
                    textStyle: textStyle,
                  );
                },
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }

                  return _InitialsLabel(
                    initials: initials,
                    textStyle: textStyle,
                  );
                },
              ),
      ),
    );
  }

  String _initials(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    return words.isEmpty
        ? '-'
        : words.take(2).map((word) => word[0].toUpperCase()).join();
  }
}

class _InitialsLabel extends StatelessWidget {
  const _InitialsLabel({required this.initials, this.textStyle});

  final String initials;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: textStyle?.copyWith(
          color: AppColors.maroon,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class CompactAlumniProfileCard extends StatelessWidget {
  const CompactAlumniProfileCard({required this.profile, super.key});

  final AlumniProfile profile;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.softGold,
            backgroundImage: profile.avatarUrl == null
                ? null
                : NetworkImage(profile.avatarUrl!),
            child: profile.avatarUrl == null
                ? Text(
                    _initials(profile.name),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.maroon,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.nim,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${profile.programStudy} • Angkatan ${profile.batchYear} • Lulus ${profile.graduationYear}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _TinyBadge(
            label:
                profile.verificationStatus.label ??
                profile.verificationStatus.state.name,
            color: _verificationColor(profile.verificationStatus.state),
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    return words.isEmpty
        ? '-'
        : words.take(2).map((word) => word[0].toUpperCase()).join();
  }

  static Color _verificationColor(AlumniVerificationState state) {
    return switch (state) {
      AlumniVerificationState.verified => AppColors.success,
      AlumniVerificationState.pending => AppColors.warning,
      AlumniVerificationState.revisionRequired => AppColors.gold,
      AlumniVerificationState.declined ||
      AlumniVerificationState.rejected => AppColors.danger,
      AlumniVerificationState.inactive => AppColors.textSecondary,
      _ => AppColors.info,
    };
  }
}

class _CompactDashboard extends StatelessWidget {
  const _CompactDashboard({
    required this.appState,
    required this.summary,
    required this.onShortcutSelected,
  });

  final AppState appState;
  final DashboardSummary? summary;
  final ValueChanged<String> onShortcutSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (appState.isDashboardLoading && summary == null)
          const _CompactMessage(
            icon: Icons.sync_rounded,
            title: 'Memuat Beranda',
            subtitle: 'Mengambil data terbaru...',
          )
        else if (appState.dashboardErrorMessage != null && summary == null)
          _CompactMessage(
            icon: Icons.wifi_off_rounded,
            title: 'Beranda belum dapat dimuat',
            subtitle: appState.dashboardErrorMessage!,
            actionLabel: 'Muat ulang',
            onAction: () => appState.loadDashboard(forceRefresh: true),
          )
        else ...[
          _SectionLabel(title: 'Status Layanan'),
          const SizedBox(height: AppSpacing.sm),
          QuickStatusSection(summary: summary),
          const SizedBox(height: AppSpacing.md),
          _SectionLabel(title: 'Menu Utama'),
          const SizedBox(height: AppSpacing.sm),
          CompactMenuGrid(
            unreadCount: appState.unreadNotificationCount,
            onSelected: onShortcutSelected,
          ),
          const SizedBox(height: AppSpacing.md),
          ImportantInfoSection(
            summary: summary,
            onShortcutSelected: onShortcutSelected,
          ),
        ],
      ],
    );
  }
}

class QuickStatusSection extends StatelessWidget {
  const QuickStatusSection({required this.summary, super.key});

  final DashboardSummary? summary;

  @override
  Widget build(BuildContext context) {
    final tracer = summary?.tracerStatus;
    final ika = summary?.ikaStatus;

    return Row(
      children: [
        Expanded(
          child: _MiniStatusCard(
            icon: Icons.assignment_rounded,
            title: 'Tracer',
            value: '${(((tracer?.progress ?? 0) * 100).round())}%',
            label: tracer?.state == TracerCompletionState.submitted
                ? 'Selesai'
                : 'Belum selesai',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MiniStatusCard(
            icon: Icons.groups_rounded,
            title: 'IKA',
            value: _shortIkaValue(ika?.state),
            label: _ikaActionLabel(ika?.state),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const Expanded(
          child: _MiniStatusCard(
            icon: Icons.diversity_3_rounded,
            title: 'Angkatan',
            value: 'Aktif',
            label: 'Lihat teman',
          ),
        ),
      ],
    );
  }

  static String _shortIkaValue(IkaMembershipState? state) {
    return switch (state) {
      IkaMembershipState.active => 'Active',
      IkaMembershipState.board => 'Pengurus',
      IkaMembershipState.pending => 'Pending',
      _ => 'Inactive',
    };
  }

  static String _ikaActionLabel(IkaMembershipState? state) {
    return switch (state) {
      IkaMembershipState.active || IkaMembershipState.board => 'Aktif',
      IkaMembershipState.pending => 'Menunggu',
      _ => 'Daftar',
    };
  }
}

class _MiniStatusCard extends StatelessWidget {
  const _MiniStatusCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String title;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: SizedBox(
        height: 76,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.maroon),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.maroon,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompactMenuGrid extends StatelessWidget {
  const CompactMenuGrid({
    required this.unreadCount,
    required this.onSelected,
    super.key,
  });

  final int unreadCount;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      _ShortcutItem(
        routeName: AppRoutes.generalInfo,
        icon: Icons.info_rounded,
        title: 'Informasi',
        gradientColors: [Color(0xFFFFF3C4), Color(0xFFFFE0B2)],
      ),
      _ShortcutItem(
        routeName: AppRoutes.tracer,
        icon: Icons.assignment_rounded,
        title: 'Tracer',
        gradientColors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
      ),
      _ShortcutItem(
        routeName: AppRoutes.ika,
        icon: Icons.groups_rounded,
        title: 'Member IKA',
        gradientColors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
      ),
      _ShortcutItem(
        routeName: AppRoutes.jobs,
        icon: Icons.work_rounded,
        title: 'Loker',
        gradientColors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
      ),
      _ShortcutItem(
        routeName: AppRoutes.events,
        icon: Icons.event_rounded,
        title: 'Event',
        gradientColors: [Color(0xFFFFF3E0), Color(0xFFFFCCBC)],
      ),
      _ShortcutItem(
        routeName: AppRoutes.alumniCard,
        icon: Icons.badge_rounded,
        title: 'Digital Kartu Alumni',
        gradientColors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
      ),
      _ShortcutItem(
        routeName: AppRoutes.batchmates,
        icon: Icons.diversity_3_rounded,
        title: 'Lacak Teman',
        gradientColors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
      ),
      _ShortcutItem(
        routeName: AppRoutes.notifications,
        icon: Icons.notifications_rounded,
        title: 'Notifikasi',
        badge: unreadCount > 0 ? '$unreadCount' : null,
        gradientColors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
      ),
    ];

    return _SurfaceCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisExtent: 104,
          crossAxisSpacing: AppSpacing.xs,
          mainAxisSpacing: AppSpacing.xs,
        ),
        itemCount: shortcuts.length,
        itemBuilder: (context, index) {
          final item = shortcuts[index];
          return _ShortcutTile(
            item: item,
            onTap: () => onSelected(item.routeName),
          );
        },
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({required this.item, required this.onTap});

  final _ShortcutItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: item.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.maroon.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(item.icon, size: 30, color: AppColors.maroon),
                ),
                if (item.badge != null)
                  Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.badge!,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImportantInfoSection extends StatelessWidget {
  const ImportantInfoSection({
    required this.summary,
    required this.onShortcutSelected,
    super.key,
  });

  final DashboardSummary? summary;
  final ValueChanged<String> onShortcutSelected;

  @override
  Widget build(BuildContext context) {
    final announcement = summary?.latestAnnouncements.firstOrNull;
    final job = summary?.latestJobs.firstOrNull;
    final event = summary?.latestEvents.firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          title: 'Info Penting',
          actionLabel: 'Lihat semua',
          onAction: () => onShortcutSelected(AppRoutes.generalInfo),
        ),
        const SizedBox(height: AppSpacing.sm),
        _SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              if (announcement == null)
                const CompactEmptyRow(
                  icon: Icons.campaign_rounded,
                  title: 'Belum ada pengumuman',
                )
              else
                _InfoRow(
                  icon: Icons.campaign_rounded,
                  title: announcement.title,
                  subtitle: announcement.message ?? announcement.category,
                  onTap: () => onShortcutSelected(AppRoutes.generalInfo),
                ),
              const _ThinDivider(),
              if (job == null)
                const CompactEmptyRow(
                  icon: Icons.work_rounded,
                  title: 'Belum ada loker terbaru',
                )
              else
                _InfoRow(
                  icon: Icons.work_rounded,
                  title: job.position,
                  subtitle:
                      '${job.company}${job.location == null ? '' : ' • ${job.location}'}',
                  onTap: () => onShortcutSelected(AppRoutes.jobs),
                ),
              const _ThinDivider(),
              if (event == null)
                const CompactEmptyRow(
                  icon: Icons.event_rounded,
                  title: 'Belum ada event terbaru',
                )
              else
                _InfoRow(
                  icon: Icons.event_rounded,
                  title: event.title,
                  subtitle: event.location ?? event.category,
                  onTap: () => onShortcutSelected(AppRoutes.events),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class CompactEmptyRow extends StatelessWidget {
  const CompactEmptyRow({required this.icon, required this.title, super.key});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 19, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Text(
            'Belum tersedia',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.softGold,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 19, color: AppColors.maroon),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle?.trim().isNotEmpty == true
                        ? subtitle!
                        : 'Belum tersedia',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactVerificationPanel extends StatelessWidget {
  const _CompactVerificationPanel({
    required this.status,
    required this.onFixProfile,
  });

  final AlumniVerificationStatus status;
  final VoidCallback onFixProfile;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          _InfoRow(
            icon: _iconForStatus(status.state),
            title: _titleForStatus(status),
            subtitle: _subtitleForStatus(status),
            onTap: status.state == AlumniVerificationState.revisionRequired
                ? onFixProfile
                : () {},
          ),
          const _ThinDivider(),
          const _InfoRow(
            icon: Icons.lock_rounded,
            title: 'Fitur aktif setelah verifikasi',
            subtitle: 'Tracer, IKA, Angkatan, Kartu',
            onTap: _noop,
          ),
        ],
      ),
    );
  }

  static void _noop() {}

  static IconData _iconForStatus(AlumniVerificationState state) {
    return switch (state) {
      AlumniVerificationState.revisionRequired => Icons.edit_note_rounded,
      AlumniVerificationState.declined ||
      AlumniVerificationState.rejected => Icons.block_rounded,
      AlumniVerificationState.inactive => Icons.pause_circle_rounded,
      _ => Icons.info_rounded,
    };
  }

  static String _titleForStatus(AlumniVerificationStatus status) {
    return switch (status.state) {
      AlumniVerificationState.pending => 'Menunggu verifikasi',
      AlumniVerificationState.revisionRequired => 'Perbaikan data diperlukan',
      AlumniVerificationState.declined ||
      AlumniVerificationState.rejected => 'Verifikasi ditolak',
      AlumniVerificationState.inactive => 'Akun alumni nonaktif',
      _ => 'Status verifikasi belum tersedia',
    };
  }

  static String _subtitleForStatus(AlumniVerificationStatus status) {
    return status.adminNote ??
        status.notes ??
        'Fitur utama aktif setelah diverifikasi Bagian Alumni.';
  }
}

class _CompactMessage extends StatelessWidget {
  const _CompactMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.softGold,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.maroon),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            ),
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.mediumGrey),
        boxShadow: AppShadows.soft,
      ),
      child: child,
    );
  }
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ThinDivider extends StatelessWidget {
  const _ThinDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: AppColors.mediumGrey);
  }
}

class _ShortcutItem {
  const _ShortcutItem({
    required this.routeName,
    required this.icon,
    required this.title,
    required this.gradientColors,
    this.badge,
  });

  final String routeName;
  final IconData icon;
  final String title;
  final List<Color> gradientColors;
  final String? badge;
}
