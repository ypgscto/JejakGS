import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class VerificationWaitingScreen extends StatelessWidget {
  const VerificationWaitingScreen({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final profile = appState.alumniProfile;
    final verification = profile?.verificationStatus;
    final state = verification?.state ?? AlumniVerificationState.unknown;
    final needsCorrection = verification?.needsCorrection == true;
    final canResubmit =
        profile?.canResubmitVerification == true &&
        state != AlumniVerificationState.inactive;
    final accentColor = switch (state) {
      AlumniVerificationState.declined ||
      AlumniVerificationState.rejected =>
        AppColors.danger,
      AlumniVerificationState.revisionRequired => AppColors.gold,
      AlumniVerificationState.inactive => AppColors.danger,
      _ => AppColors.gold,
    };
    final headerTitle = switch (state) {
      AlumniVerificationState.declined ||
      AlumniVerificationState.rejected =>
        'Verifikasi Ditolak',
      AlumniVerificationState.revisionRequired => 'Perlu Perbaikan Data',
      AlumniVerificationState.inactive => 'Akun Nonaktif',
      _ => 'Menunggu Verifikasi',
    };
    final headerSubtitle = switch (state) {
      AlumniVerificationState.declined ||
      AlumniVerificationState.rejected =>
        'Pengajuan verifikasi alumni Anda ditolak oleh admin SIMAWA-GS. Perbaiki data lalu kirim ulang.',
      AlumniVerificationState.revisionRequired =>
        'Admin meminta perbaikan data. Silakan perbarui data/berkas lalu kirim verifikasi ulang.',
      AlumniVerificationState.inactive =>
        'Akun alumni Anda sedang nonaktif. Hubungi admin SIMAWA-GS bila memerlukan bantuan.',
      _ =>
        'Profil alumni Anda sudah diterima dan sedang menunggu verifikasi SIMAWA-GS.',
    };
    final statusDescription =
        verification?.displayNote ??
        switch (state) {
          AlumniVerificationState.declined ||
          AlumniVerificationState.rejected =>
            'Silakan perbaiki data alumni dan unggah ulang berkas yang diminta admin.',
          AlumniVerificationState.revisionRequired =>
            'Perbaiki data sesuai catatan admin, lalu kirim ulang untuk diverifikasi.',
          AlumniVerificationState.inactive =>
            'Fitur utama belum dapat diakses sampai akun diaktifkan kembali.',
          _ =>
            'Anda belum dapat masuk ke Beranda sampai data alumni diverifikasi.',
        };

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            AppHeader(
              title: headerTitle,
              subtitle: headerSubtitle,
              leadingIcon: needsCorrection
                  ? Icons.report_gmailerrorred_rounded
                  : Icons.hourglass_top_rounded,
            ),
            const SizedBox(height: AppSpacing.xxl),
            StatusCard(
              title: verification?.displayLabel ?? state.defaultLabel,
              description: statusDescription,
              icon: needsCorrection
                  ? Icons.info_rounded
                  : Icons.verified_rounded,
              accentColor: accentColor,
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
            if (canResubmit) ...[
              PrimaryButton(
                label: needsCorrection
                    ? 'Perbaiki Data & Kirim Ulang'
                    : 'Perbarui Data Verifikasi',
                icon: Icons.edit_rounded,
                fullWidth: true,
                onPressed: appState.isBusy
                    ? null
                    : appState.showCompleteProfile,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (canResubmit)
              SecondaryButton(
                label: 'Cek Status Terbaru',
                icon: Icons.refresh_rounded,
                fullWidth: true,
                onPressed: appState.isBusy ? null : appState.refreshProfile,
              )
            else
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
