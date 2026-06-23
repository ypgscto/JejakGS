import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  String? _validationMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _nimController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            AppHeader(
              title: 'Register Alumni',
              subtitle:
                  'Daftarkan email pribadi terbaru sebagai akun JejakGS. NIM digunakan untuk mencocokkan data alumni tanpa password SSO.',
              leadingIcon: Icons.verified_user_rounded,
            ),
            const SizedBox(height: AppSpacing.xxl),
            CustomTextField(
              label: 'Email',
              hintText: 'Masukkan email aktif',
              controller: _emailController,
              prefixIcon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'Nama Alumni',
              hintText: 'Masukkan nama lengkap alumni',
              controller: _nameController,
              prefixIcon: Icons.person_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'Password JejakGS',
              hintText: 'Buat password untuk login JejakGS',
              controller: _passwordController,
              prefixIcon: Icons.key_rounded,
              obscureText: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'Konfirmasi Password',
              hintText: 'Ulangi password JejakGS',
              controller: _passwordConfirmationController,
              prefixIcon: Icons.lock_reset_rounded,
              obscureText: true,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'NIM',
              hintText: 'Contoh: 18182008',
              controller: _nimController,
              prefixIcon: Icons.badge_rounded,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
            ),
            if (_validationMessage != null ||
                widget.appState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: StatusCard(
                  title: 'Registrasi belum berhasil',
                  description:
                      _validationMessage ?? widget.appState.errorMessage!,
                  icon: Icons.info_rounded,
                  accentColor: AppColors.gold,
                ),
              ),
            if (_successMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: StatusCard(
                  title: 'Cek email verifikasi',
                  description: _successMessage!,
                  icon: Icons.mark_email_read_rounded,
                  accentColor: AppColors.success,
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: 'Register Alumni',
              icon: Icons.check_circle_rounded,
              isLoading: widget.appState.isBusy,
              fullWidth: true,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Kembali ke Login',
              icon: Icons.arrow_back_rounded,
              fullWidth: true,
              onPressed: widget.appState.isBusy
                  ? null
                  : widget.appState.showLogin,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim().toLowerCase();
    final name = _nameController.text.trim();
    final password = _passwordController.text;
    final passwordConfirmation = _passwordConfirmationController.text;
    final nim = _nimController.text.trim();

    if (email.isEmpty ||
        name.isEmpty ||
        password.isEmpty ||
        passwordConfirmation.isEmpty ||
        nim.isEmpty) {
      setState(() {
        _validationMessage =
            'Email, nama alumni, password, dan NIM wajib diisi.';
        _successMessage = null;
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _validationMessage = 'Format email belum valid.';
        _successMessage = null;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _validationMessage = 'Password JejakGS minimal 6 karakter.';
        _successMessage = null;
      });
      return;
    }

    if (password != passwordConfirmation) {
      setState(() {
        _validationMessage = 'Konfirmasi password tidak sama.';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _validationMessage = null;
      _successMessage = null;
    });
    final success = await widget.appState.registerAlumni(
      email: email,
      name: name,
      password: password,
      passwordConfirmation: passwordConfirmation,
      nim: nim,
    );
    if (!mounted || !success) {
      return;
    }

    setState(() {
      _successMessage =
          'Link verifikasi telah dikirim ke $email. Setelah email diverifikasi, silakan kembali ke aplikasi dan login untuk melengkapi profil alumni.';
    });
  }
}
