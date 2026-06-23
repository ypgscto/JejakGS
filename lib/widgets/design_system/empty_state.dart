import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';
import 'secondary_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    required this.description,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onActionPressed,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.mediumGrey),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.softGold,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Icon(icon, color: AppColors.maroon, size: 32),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (actionLabel != null && onActionPressed != null) ...[
            const SizedBox(height: AppSpacing.xl),
            SecondaryButton(label: actionLabel!, onPressed: onActionPressed),
          ],
        ],
      ),
    );
  }
}
