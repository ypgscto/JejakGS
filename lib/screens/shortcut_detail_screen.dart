import 'package:flutter/material.dart';

import '../config/app_routes.dart';
import '../core/constants/app_spacing.dart';
import '../widgets/design_system/design_system.dart';

class ShortcutDetailScreen extends StatelessWidget {
  const ShortcutDetailScreen({
    required this.routeName,
    required this.onBack,
    super.key,
  });

  final String routeName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final detail = _ShortcutDetail.fromRoute(routeName);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                detail.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppHeader(
          title: detail.title,
          subtitle: detail.subtitle,
          leadingIcon: detail.icon,
        ),
        const SizedBox(height: AppSpacing.xxl),
        EmptyState(
          icon: detail.icon,
          title: '${detail.title} belum dimuat',
          description:
              'Konten ${detail.title.toLowerCase()} akan ditampilkan dari API SIMAWA-GS saat endpoint tersedia.',
        ),
      ],
    );
  }
}

class _ShortcutDetail {
  const _ShortcutDetail({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  static _ShortcutDetail fromRoute(String routeName) {
    switch (routeName) {
      case AppRoutes.generalInfo:
        return const _ShortcutDetail(
          title: 'Informasi Umum',
          subtitle: 'Informasi resmi untuk alumni JejakGS.',
          icon: Icons.info_rounded,
        );
      case AppRoutes.batchmates:
        return const _ShortcutDetail(
          title: 'Jejak Angkatan',
          subtitle: 'Temukan rekan alumni berdasarkan angkatan.',
          icon: Icons.diversity_3_rounded,
        );
      case AppRoutes.events:
        return const _ShortcutDetail(
          title: 'Event Alumni',
          subtitle: 'Agenda kegiatan alumni dan kampus.',
          icon: Icons.event_rounded,
        );
      case AppRoutes.alumniCard:
        return const _ShortcutDetail(
          title: 'Kartu Alumni',
          subtitle: 'Kartu identitas alumni digital.',
          icon: Icons.badge_rounded,
        );
      case AppRoutes.ikaCard:
        return const _ShortcutDetail(
          title: 'Kartu IKA',
          subtitle: 'Kartu keanggotaan Ikatan Alumni.',
          icon: Icons.credit_card_rounded,
        );
      case AppRoutes.notifications:
        return const _ShortcutDetail(
          title: 'Notifikasi',
          subtitle: 'Pemberitahuan penting dari SIMAWA-GS.',
          icon: Icons.notifications_rounded,
        );
      case AppRoutes.help:
        return const _ShortcutDetail(
          title: 'Bantuan',
          subtitle: 'Pusat bantuan penggunaan aplikasi JejakGS.',
          icon: Icons.help_rounded,
        );
      default:
        return const _ShortcutDetail(
          title: 'JejakGS',
          subtitle: 'Halaman aplikasi JejakGS.',
          icon: Icons.apps_rounded,
        );
    }
  }
}
