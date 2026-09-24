import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_spacing.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({
    required this.appState,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _confirmed = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _passwordController.text.trim().isNotEmpty &&
      _confirmed &&
      !_isSubmitting;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
          children: [
            IconButton(
              onPressed: _isSubmitting ? null : widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                'Hapus Akun JejakGS',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppHeader(
          title: 'Hapus Akun JejakGS',
          subtitle: 'Tindakan ini menghapus akses login akun aplikasi Anda.',
          leadingIcon: Icons.delete_forever_rounded,
        ),
        const SizedBox(height: AppSpacing.xxl),
        const StatusCard(
          title: 'Hapus Akun JejakGS',
          description:
              'Menghapus akun JejakGS akan menghapus akses login dan data pribadi yang terkait dengan akun aplikasi Anda.\n\n'
              'Data alumni yang merupakan arsip institusi STIKES Gunung Sari, termasuk identitas alumni dan riwayat administratif yang perlu dipertahankan, tidak ikut dihapus.\n\n'
              'Jika Anda telah menjadi anggota IKA, status dan riwayat keanggotaan IKA tetap tersimpan sebagai bagian dari data alumni.\n\n'
              'Jika di kemudian hari Anda mendaftar JejakGS kembali menggunakan NIM yang sama, akun baru akan dihubungkan kembali dengan data alumni Anda setelah proses verifikasi yang berlaku.',
          icon: Icons.info_rounded,
          accentColor: AppColors.maroon,
        ),
        const SizedBox(height: AppSpacing.lg),
        const StatusCard(
          title: 'Tidak dapat dibatalkan',
          description:
              'Tindakan ini tidak dapat membatalkan kembali akun JejakGS yang telah dihapus.',
          icon: Icons.warning_amber_rounded,
          accentColor: AppColors.danger,
        ),
        const SizedBox(height: AppSpacing.xxl),
        CustomTextField(
          label: 'Password saat ini',
          hintText: 'Masukkan password JejakGS',
          controller: _passwordController,
          prefixIcon: Icons.key_rounded,
          obscureText: _obscurePassword,
          enabled: !_isSubmitting,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          suffixIcon: IconButton(
            onPressed: _isSubmitting
                ? null
                : () => setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _confirmed,
          onChanged: _isSubmitting
              ? null
              : (value) => setState(() => _confirmed = value ?? false),
          activeColor: AppColors.maroon,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            'Saya memahami bahwa akun JejakGS saya akan dihapus.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        if (widget.appState.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          StatusCard(
            title: 'Akun belum dihapus',
            description: widget.appState.errorMessage!,
            icon: Icons.error_outline_rounded,
            accentColor: AppColors.danger,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _canSubmit ? _confirmAndDelete : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.danger.withValues(alpha: 0.35),
              disabledForegroundColor: AppColors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            icon: _isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Icon(Icons.delete_forever_rounded),
            label: const Text('Hapus Akun'),
          ),
        ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDelete() async {
    if (!_canSubmit) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: !_isSubmitting,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus akun JejakGS?'),
          content: const Text(
            'Akun JejakGS yang sudah dihapus tidak dapat dipulihkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus Akun'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);
    final deleted = await widget.appState.deleteAccount(
      _passwordController.text,
    );
    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);
    if (!deleted) {
      return;
    }
  }
}
