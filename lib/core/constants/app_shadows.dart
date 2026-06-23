import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> get soft => [
    BoxShadow(
      color: AppColors.darkMaroon.withValues(alpha: 0.06),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get medium => [
    BoxShadow(
      color: AppColors.darkMaroon.withValues(alpha: 0.12),
      blurRadius: 28,
      offset: const Offset(0, 14),
    ),
  ];
}
