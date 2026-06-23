import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

class IkaStatusCard extends StatelessWidget {
  const IkaStatusCard({
    required this.title,
    required this.description,
    required this.isActiveMember,
    this.actionLabel,
    this.onActionPressed,
    super.key,
  });

  final String title;
  final String description;
  final bool isActiveMember;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final accentColor = isActiveMember ? AppColors.success : AppColors.gold;

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
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(Icons.groups_rounded, color: accentColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          if (actionLabel != null && onActionPressed != null) ...[
            const SizedBox(height: AppSpacing.lg),
            isActiveMember
                ? SecondaryButton(
                    label: actionLabel!,
                    onPressed: onActionPressed,
                    fullWidth: true,
                  )
                : PrimaryButton(
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
