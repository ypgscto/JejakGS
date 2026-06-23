import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class AppStatusCard extends StatelessWidget {
  const AppStatusCard({
    required this.title,
    required this.description,
    required this.isReady,
    super.key,
  });

  final String title;
  final String description;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    final icon = isReady ? Icons.check_circle_rounded : Icons.info_rounded;
    final accentColor = isReady ? AppColors.maroon : AppColors.gold;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
