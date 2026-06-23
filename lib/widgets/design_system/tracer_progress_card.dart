import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';
import 'primary_button.dart';

class TracerProgressCard extends StatelessWidget {
  const TracerProgressCard({
    required this.title,
    required this.progress,
    this.description,
    this.currentStepLabel,
    this.actionLabel,
    this.onActionPressed,
    super.key,
  });

  final String title;
  final double progress;
  final String? description;
  final String? currentStepLabel;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0, 1).toDouble();
    final percent = (normalizedProgress * 100).round();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.mediumGrey),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '$percent%',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.maroon),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(description!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: normalizedProgress,
              minHeight: 10,
              color: AppColors.gold,
              backgroundColor: AppColors.mediumGrey,
            ),
          ),
          if (currentStepLabel != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              currentStepLabel!,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
          if (actionLabel != null && onActionPressed != null) ...[
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: actionLabel!,
              onPressed: onActionPressed,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }
}
