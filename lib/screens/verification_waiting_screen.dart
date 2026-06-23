import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class VerificationWaitingScreen extends StatelessWidget {
  const VerificationWaitingScreen({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final profile = appState.alumniProfile;
    final verification = profile?.verificationStatus;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            AppHeader(
              title: 'Menunggu Verifikasi',
              subtitle:
                  'Profil alumni Anda sudah diterima dan sedang menunggu verifikasi SIMAWA-GS.',
              leadingIcon: Icons.hourglass_top_rounded,
            ),
            const SizedBox(height: AppSpacing.xxl),
            StatusCard(
              title: verification?.label ?? 'Status belum terverifikasi',
              description:
                  verification?.notes ??
                  'Anda belum dapat masuk ke Beranda sampai data alumni diverifikasi.',
              icon: Icons.verified_rounded,
              accentColor: AppColors.gold,
            ),
            if (profile != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AlumniProfileCard(
                name: profile.name,
                program: profile.programStudy,
                graduationYear: profile.batchYear.toString(),
                currentRole: profile.institution,
                avatarUrl: profile.avatarUrl,
              ),
            ],
            if (appState.errorMessage != null) ...[
              const SizedBox(height: AppSpacing.lg),
              StatusCard(
                title: 'Gagal memperbarui status',
                description: appState.errorMessage!,
                icon: Icons.info_rounded,
                accentColor: AppColors.danger,
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: 'Cek Status Terbaru',
              icon: Icons.refresh_rounded,
              isLoading: appState.isBusy,
              fullWidth: true,
              onPressed: appState.refreshProfile,
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Keluar',
              icon: Icons.logout_rounded,
              fullWidth: true,
              onPressed: appState.isBusy ? null : appState.logout,
            ),
          ],
        ),
      ),
    );
  }
}
