import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
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
    final canAccessMember = widget.appState.canAccessIkaMemberFeatures;
    final canAccessBoard = widget.appState.canAccessIkaOfficerFeatures;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const AppHeader(
          title: 'IKA',
          subtitle:
              'Ikatan Alumni dikelola di SIMAWA-GS. JejakGS menjadi mobile client untuk informasi dan pengajuan.',
          leadingIcon: Icons.groups_rounded,
        ),
        const SizedBox(height: AppSpacing.xxl),
        if (status != null)
          IkaStatusCard(
            title: status.label ?? 'Status IKA',
            description: status.description ?? _descriptionFor(status.state),
            isActiveMember: canAccessMember,
            actionLabel:
                status.state == IkaMembershipState.notRegistered ||
                    status.state == IkaMembershipState.inactive ||
                    status.state == IkaMembershipState.unknown
                ? 'Ajukan Pendaftaran'
                : 'Lihat Status',
            onActionPressed:
                status.state == IkaMembershipState.notRegistered ||
                    status.state == IkaMembershipState.inactive ||
                    status.state == IkaMembershipState.unknown
                ? widget.onOpenRegistration
                : widget.onOpenStatus,
          )
        else
          const EmptyState(
            icon: Icons.groups_outlined,
            title: 'Status IKA belum tersedia',
            description: 'Status IKA akan diambil dari API SIMAWA-GS.',
          ),
        const SizedBox(height: AppSpacing.xl),
        const SectionTitle(
          title: 'Manfaat Bergabung IKA',
          subtitle: 'Akses jejaring alumni, event, forum, dan layanan anggota.',
        ),
        const SizedBox(height: AppSpacing.md),
        StatusCard(
          title: 'Informasi IKA',
          description:
              'Informasi, manfaat, dan ketentuan keanggotaan akan mengikuti data dari SIMAWA-GS.',
          icon: Icons.info_rounded,
          accentColor: AppColors.maroon,
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionTitle(title: 'Fitur Anggota'),
        const SizedBox(height: AppSpacing.md),
        _IkaMenuGrid(
          items: [
            _IkaMenuItem(
              title: 'Kartu Anggota',
              icon: Icons.credit_card_rounded,
              enabled: canAccessMember,
              onTap: widget.onOpenCard,
            ),
            _IkaMenuItem(
              title: 'Event Anggota',
              icon: Icons.event_rounded,
              enabled: canAccessMember,
              onTap: widget.onOpenEvents,
            ),
            _IkaMenuItem(
              title: 'Iuran/Donasi',
              icon: Icons.payments_rounded,
              enabled: canAccessMember,
              onTap: widget.onOpenPayment,
            ),
            _IkaMenuItem(
              title: 'Voting',
              icon: Icons.how_to_vote_rounded,
              enabled: canAccessMember,
              onTap: widget.onOpenVoting,
            ),
            _IkaMenuItem(
              title: 'Forum Anggota',
              icon: Icons.forum_rounded,
              enabled: canAccessMember,
              onTap: widget.onOpenForum,
            ),
          ],
        ),
        if (canAccessBoard) ...[
          const SizedBox(height: AppSpacing.xl),
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

  String _descriptionFor(IkaMembershipState state) {
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
    };
  }
}

class _IkaMenuGrid extends StatelessWidget {
  const _IkaMenuGrid({required this.items});

  final List<_IkaMenuItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.05,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MenuCard(
          icon: item.icon,
          title: item.title,
          subtitle: item.enabled ? 'Tersedia' : 'Khusus anggota IKA',
          onTap: item.enabled ? item.onTap : null,
        );
      },
    );
  }
}

class _IkaMenuItem {
  const _IkaMenuItem({
    required this.title,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
}
