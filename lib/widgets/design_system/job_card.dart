import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';

class JobCard extends StatelessWidget {
  const JobCard({
    required this.position,
    required this.company,
    this.location,
    this.employmentType,
    this.category,
    this.postedDateLabel,
    this.deadlineLabel,
    this.isSaved = false,
    this.onSavePressed,
    this.onTap,
    super.key,
  });

  final String position;
  final String company;
  final String? location;
  final String? employmentType;
  final String? category;
  final String? postedDateLabel;
  final String? deadlineLabel;
  final bool isSaved;
  final VoidCallback? onSavePressed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _TappableCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.maroon.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(Icons.work_rounded, color: AppColors.maroon),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      position,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      company,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onSavePressed,
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: AppColors.maroon,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (location != null)
                _MetaChip(icon: Icons.location_on_rounded, label: location!),
              if (employmentType != null)
                _MetaChip(icon: Icons.schedule_rounded, label: employmentType!),
              if (category != null)
                _MetaChip(icon: Icons.category_rounded, label: category!),
              if (postedDateLabel != null)
                _MetaChip(icon: Icons.publish_rounded, label: postedDateLabel!),
              if (deadlineLabel != null)
                _MetaChip(
                  icon: Icons.event_available_rounded,
                  label: deadlineLabel!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TappableCard extends StatelessWidget {
  const _TappableCard({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.mediumGrey),
            boxShadow: AppShadows.soft,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
