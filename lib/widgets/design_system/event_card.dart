import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    required this.title,
    required this.dateLabel,
    this.location,
    this.categoryLabel,
    this.isOnline = false,
    this.onTap,
    super.key,
  });

  final String title;
  final String dateLabel;
  final String? location;
  final String? categoryLabel;
  final bool isOnline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.mediumGrey),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 92,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.maroon, AppColors.darkMaroon],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xl),
                  ),
                ),
                child: Center(
                  child: Icon(
                    isOnline ? Icons.video_camera_front_rounded : Icons.event,
                    color: AppColors.gold,
                    size: 34,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (categoryLabel != null) ...[
                      _EventChip(label: categoryLabel!),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.md),
                    _EventMeta(
                      icon: Icons.calendar_today_rounded,
                      label: dateLabel,
                    ),
                    if (location != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _EventMeta(
                        icon: isOnline
                            ? Icons.link_rounded
                            : Icons.location_on_rounded,
                        label: location!,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventChip extends StatelessWidget {
  const _EventChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.softGold,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.maroon,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EventMeta extends StatelessWidget {
  const _EventMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
