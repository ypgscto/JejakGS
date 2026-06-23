import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';

class AlumniProfileCard extends StatelessWidget {
  const AlumniProfileCard({
    required this.name,
    required this.program,
    required this.graduationYear,
    this.avatarUrl,
    this.currentRole,
    this.privacyLabel,
    this.onTap,
    super.key,
  });

  final String name;
  final String program;
  final String graduationYear;
  final String? avatarUrl;
  final String? currentRole;
  final String? privacyLabel;
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
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.softGold,
                backgroundImage: avatarUrl == null
                    ? null
                    : NetworkImage(avatarUrl!),
                child: avatarUrl == null
                    ? Text(
                        _initials(name),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.maroon),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$program - Angkatan $graduationYear',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (currentRole != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        currentRole!,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ],
                ),
              ),
              if (privacyLabel != null) ...[
                const SizedBox(width: AppSpacing.md),
                _PrivacyChip(label: privacyLabel!),
              ],
            ],
          ),
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

    if (words.isEmpty) {
      return '-';
    }

    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }
}

class _PrivacyChip extends StatelessWidget {
  const _PrivacyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
