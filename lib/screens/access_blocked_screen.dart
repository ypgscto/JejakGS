import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../widgets/design_system/design_system.dart';

class AccessBlockedScreen extends StatelessWidget {
  const AccessBlockedScreen({
    required this.title,
    required this.message,
    required this.onBack,
    super.key,
  });

  final String title;
  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        StatusCard(
          title: '$title belum dapat diakses',
          description: message,
          icon: Icons.lock_rounded,
          accentColor: AppColors.gold,
        ),
      ],
    );
  }
}
