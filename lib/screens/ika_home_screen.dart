import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_shadows.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class IkaHomeScreen extends StatefulWidget {
  const IkaHomeScreen({
    required this.appState,
    required this.onOpenRegistration,
    required this.onOpenStatus,
    required this.onOpenCard,
    required this.onOpenEvents,
    required this.onOpenPayment,
    required this.onOpenVoting,
    required this.onOpenForum,
    super.key,
  });

  final AppState appState;
  final VoidCallback onOpenRegistration;
  final VoidCallback onOpenStatus;
  final VoidCallback onOpenCard;
  final VoidCallback onOpenEvents;
  final VoidCallback onOpenPayment;
  final VoidCallback onOpenVoting;
  final VoidCallback onOpenForum;

  @override
  State<IkaHomeScreen> createState() => _IkaHomeScreenState();
}

class _IkaHomeScreenState extends State<IkaHomeScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  IkaStatus? _status;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'Memuat data IKA...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: 'Data IKA belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    final status = _status;
    final isActiveMember = status?.canAccessMemberFeatures == true;
    final canAccessBoard =
        status?.canAccessBoardFeatures == true ||
        widget.appState.canAccessIkaOfficerFeatures;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _CompactIkaHeader(
          badge: status?.label ?? _descriptionFor(status?.state),
          isActive: isActiveMember,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (status != null)
          _CompactIkaStatusCard(
            status: status,
            onStatusPressed: widget.onOpenStatus,
            onRegisterPressed: widget.onOpenRegistration,
            descriptionFor: _descriptionFor,
          )
        else
          const _SmallInfoBox(
            icon: Icons.groups_outlined,
            text: 'Status IKA belum tersedia dari SIMAWA-GS.',
          ),
        if (!isActiveMember && status != null) ...[
          const SizedBox(height: AppSpacing.md),
          _MembershipHint(
            status: status,
            onRegisterPressed: widget.onOpenRegistration,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        const SectionTitle(title: 'Fitur Anggota'),
        const SizedBox(height: AppSpacing.md),
        _IkaMenuGrid(
          enabled: isActiveMember,
          lockedMessage: _lockedMessage(status),
          items: [
            _IkaMenuItem(
              title: 'Kartu Anggota',
              subtitle: 'Digital ID',
              icon: Icons.credit_card_rounded,
              onTap: widget.onOpenCard,
            ),
            _IkaMenuItem(
              title: 'Event',
              subtitle: 'Kegiatan IKA',
              icon: Icons.event_rounded,
              onTap: widget.onOpenEvents,
            ),
            _IkaMenuItem(
              title: 'Iuran/Donasi',
              subtitle: 'Pembayaran',
              icon: Icons.payments_rounded,
              onTap: widget.onOpenPayment,
            ),
            _IkaMenuItem(
              title: 'Voting',
              subtitle: 'Musyawarah',
              icon: Icons.how_to_vote_rounded,
              onTap: widget.onOpenVoting,
            ),
            _IkaMenuItem(
              title: 'Forum',
              subtitle: 'Diskusi',
              icon: Icons.forum_rounded,
              onTap: widget.onOpenForum,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionTitle(title: 'Info IKA Terbaru'),
        const SizedBox(height: AppSpacing.sm),
        const _SmallInfoBox(
          icon: Icons.info_outline_rounded,
          text: 'Belum ada info terbaru.',
        ),
        if (canAccessBoard) ...[
          const SizedBox(height: AppSpacing.lg),
          const SectionTitle(title: 'Fitur Pengurus IKA'),
          const SizedBox(height: AppSpacing.md),
          StatusCard(
            title: 'Dashboard Pengurus',
            description:
                'Validasi pendaftaran, broadcast informasi, kelola event, rekap anggota, rekap iuran/donasi, dan forum pengurus mengikuti role dari SIMAWA-GS.',
            icon: Icons.admin_panel_settings_rounded,
            accentColor: AppColors.maroon,
          ),
        ],
      ],
    );
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await widget.appState.ikaService.getMembershipStatus();
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _status = response.data;
      } else {
        _errorMessage = response.message ?? 'Status IKA belum tersedia.';
      }
    });
  }

  String _descriptionFor(IkaMembershipState? state) {
    return switch (state) {
      IkaMembershipState.notRegistered => 'Belum Mendaftar',
      IkaMembershipState.pending => 'Menunggu Verifikasi',
      IkaMembershipState.revisionRequired => 'Perlu Perbaikan',
      IkaMembershipState.declined => 'Ditolak',
      IkaMembershipState.active => 'Anggota Aktif',
      IkaMembershipState.inactive => 'Anggota Nonaktif',
      IkaMembershipState.board => 'Pengurus IKA',
      IkaMembershipState.expired => 'Keanggotaan kedaluwarsa',
      IkaMembershipState.unknown => 'Status belum tersedia',
      null => 'Status belum tersedia',
    };
  }

  String _lockedMessage(IkaStatus? status) {
    return switch (status?.state) {
      IkaMembershipState.pending =>
        'Pengajuan IKA Anda sedang menunggu verifikasi.',
      IkaMembershipState.inactive =>
        'Silakan aktifkan/daftar keanggotaan IKA untuk menggunakan fitur ini.',
      IkaMembershipState.notRegistered ||
      IkaMembershipState.unknown ||
      null => 'Fitur ini hanya tersedia untuk anggota IKA aktif.',
      _ => 'Fitur ini hanya tersedia untuk anggota IKA aktif.',
    };
  }
}

class _CompactIkaHeader extends StatelessWidget {
  const _CompactIkaHeader({required this.badge, required this.isActive});

  final String badge;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkMaroon, AppColors.maroon],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(Icons.groups_rounded, color: AppColors.gold),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IKA',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Ikatan Alumni STIKES Gunung Sari',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? AppColors.gold : AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              badge,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.darkMaroon,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactIkaStatusCard extends StatelessWidget {
  const _CompactIkaStatusCard({
    required this.status,
    required this.onStatusPressed,
    required this.onRegisterPressed,
    required this.descriptionFor,
  });

  final IkaStatus status;
  final VoidCallback onStatusPressed;
  final VoidCallback onRegisterPressed;
  final String Function(IkaMembershipState? state) descriptionFor;

  @override
  Widget build(BuildContext context) {
    final shouldRegister =
        status.state == IkaMembershipState.notRegistered ||
        status.state == IkaMembershipState.inactive ||
        status.state == IkaMembershipState.unknown;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.mediumGrey),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label ?? descriptionFor(status.state),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  [
                        if (status.memberNumber != null &&
                            status.memberNumber!.trim().isNotEmpty)
                          'No. ${status.memberNumber}',
                        if (status.registeredAt != null)
                          'Bergabung ${_date(status.registeredAt)}',
                      ].isEmpty
                      ? (status.description ?? descriptionFor(status.state))
                      : [
                          if (status.memberNumber != null &&
                              status.memberNumber!.trim().isNotEmpty)
                            'No. ${status.memberNumber}',
                          if (status.registeredAt != null)
                            'Bergabung ${_date(status.registeredAt)}',
                        ].join(' • '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          TextButton(
            onPressed: shouldRegister ? onRegisterPressed : onStatusPressed,
            child: Text(shouldRegister ? 'Daftar' : 'Lihat Status'),
          ),
        ],
      ),
    );
  }
}

class _MembershipHint extends StatelessWidget {
  const _MembershipHint({
    required this.status,
    required this.onRegisterPressed,
  });

  final IkaStatus status;
  final VoidCallback onRegisterPressed;

  @override
  Widget build(BuildContext context) {
    final message = switch (status.state) {
      IkaMembershipState.pending =>
        'Pengajuan IKA Anda sedang menunggu verifikasi.',
      IkaMembershipState.inactive =>
        'Silakan aktifkan/daftar keanggotaan IKA untuk menggunakan fitur ini.',
      _ => 'Fitur anggota aktif setelah keanggotaan IKA disetujui.',
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, color: AppColors.maroon),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall),
          ),
          if (status.state != IkaMembershipState.pending)
            TextButton(
              onPressed: onRegisterPressed,
              child: const Text('Daftar'),
            ),
        ],
      ),
    );
  }
}

class _SmallInfoBox extends StatelessWidget {
  const _SmallInfoBox({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactIkaMenuCard extends StatelessWidget {
  const _CompactIkaMenuCard({
    required this.item,
    required this.enabled,
    required this.lockedMessage,
  });

  final _IkaMenuItem item;
  final bool enabled;
  final String lockedMessage;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? item.onTap
            : () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(lockedMessage)));
              },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: enabled ? AppColors.white : AppColors.lightGrey,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: enabled ? AppColors.mediumGrey : AppColors.mediumGrey,
            ),
            boxShadow: enabled ? AppShadows.soft : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: enabled
                          ? AppColors.softGold
                          : AppColors.mediumGrey,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Icon(
                      enabled ? item.icon : Icons.lock_outline_rounded,
                      color: enabled
                          ? AppColors.maroon
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IkaMenuGrid extends StatelessWidget {
  const _IkaMenuGrid({
    required this.items,
    required this.enabled,
    required this.lockedMessage,
  });

  final List<_IkaMenuItem> items;
  final bool enabled;
  final String lockedMessage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth >= 720 ? 3 : 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            mainAxisExtent: 108,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _CompactIkaMenuCard(
              item: item,
              enabled: enabled,
              lockedMessage: lockedMessage,
            );
          },
        );
      },
    );
  }
}

String _date(DateTime? value) {
  if (value == null) return '-';

  return value.toLocal().toString().split(' ').first;
}

class _IkaMenuItem {
  const _IkaMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}
