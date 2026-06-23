import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class IkaRegistrationScreen extends StatefulWidget {
  const IkaRegistrationScreen({
    required this.appState,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;

  @override
  State<IkaRegistrationScreen> createState() => _IkaRegistrationScreenState();
}

class _IkaRegistrationScreenState extends State<IkaRegistrationScreen> {
  final _motivationController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  String? _message;

  @override
  void dispose() {
    _motivationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Pendaftaran IKA', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        const StatusCard(
          title: 'Ajukan pendaftaran IKA',
          description:
              'Pengajuan akan dikirim ke SIMAWA-GS dan diverifikasi oleh pengurus/Bagian Alumni sesuai kebijakan institusi.',
          icon: Icons.how_to_reg_rounded,
          accentColor: AppColors.maroon,
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomTextField(
          label: 'Motivasi bergabung',
          controller: _motivationController,
          maxLines: 4,
          prefixIcon: Icons.edit_note_rounded,
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomTextField(
          label: 'Catatan tambahan',
          controller: _notesController,
          maxLines: 3,
          prefixIcon: Icons.notes_rounded,
        ),
        if (_message != null) ...[
          const SizedBox(height: AppSpacing.lg),
          StatusCard(
            title: 'Status pengajuan',
            description: _message!,
            icon: Icons.info_rounded,
            accentColor: AppColors.gold,
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(
          label: 'Kirim Pengajuan',
          icon: Icons.send_rounded,
          isLoading: _isSubmitting,
          fullWidth: true,
          onPressed: _submit,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final profile = widget.appState.alumniProfile;
    final phone = profile?.phoneNumber?.trim() ?? '';

    if (phone.isEmpty) {
      setState(() {
        _message =
            'Nomor HP belum terbaca dari profil. Silakan simpan Nomor HP di Profil Alumni terlebih dahulu.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    final response = await widget.appState.ikaService.registerMembership({
      'contact_phone': phone,
      'contact_email': profile?.email?.trim(),
      'contact_whatsapp': phone,
      'work_location': profile?.city?.trim(),
      'consent': true,
      'motivation': _motivationController.text.trim(),
      'notes': _notesController.text.trim(),
    });

    setState(() {
      _isSubmitting = false;
      _message = response.isSuccess
          ? 'Pengajuan pendaftaran IKA berhasil dikirim.'
          : response.message ?? 'Pengajuan belum dapat dikirim.';
    });
  }
}

class _BackTitle extends StatelessWidget {
  const _BackTitle({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
      ],
    );
  }
}
