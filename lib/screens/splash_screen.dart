import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../providers/state/app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(widget.appState.initializeAuthFlow);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkMaroon, AppColors.maroon],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: AppColors.darkMaroon,
                size: 42,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              widget.appState.config.appName,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Menghubungkan alumni dengan SIMAWA-GS',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white.withValues(alpha: 0.84),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            const CircularProgressIndicator(
              color: AppColors.gold,
              strokeCap: StrokeCap.round,
            ),
          ],
        ),
      ),
    );
  }
}
