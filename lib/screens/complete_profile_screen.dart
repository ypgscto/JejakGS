import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _jobController = TextEditingController();
  final _institutionController = TextEditingController();
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _fillFromProfile(widget.appState.alumniProfile);
  }

  @override
  void didUpdateWidget(covariant CompleteProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appState.alumniProfile != widget.appState.alumniProfile) {
      _fillFromProfile(widget.appState.alumniProfile);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _jobController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.appState.alumniProfile;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            AppHeader(
              title: 'Lengkapi Profil',
              subtitle:
                  'Lengkapi data profil pribadi agar akun alumni dapat diproses dari SIMAWA-GS.',
              leadingIcon: Icons.assignment_ind_rounded,
            ),
            if (profile != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              AlumniProfileCard(
                name: profile.name,
                program: profile.programStudy,
                graduationYear: profile.batchYear.toString(),
                currentRole: profile.nim,
                avatarUrl: profile.avatarUrl,
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            CustomTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'Nomor HP',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'Domisili Kota',
              controller: _cityController,
              prefixIcon: Icons.location_city_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'Pekerjaan',
              controller: _jobController,
              prefixIcon: Icons.work_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'Instansi',
              controller: _institutionController,
              prefixIcon: Icons.apartment_rounded,
              textInputAction: TextInputAction.done,
            ),
            if (_validationMessage != null ||
                widget.appState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: StatusCard(
                  title: 'Profil belum dapat disimpan',
                  description:
                      _validationMessage ?? widget.appState.errorMessage!,
                  icon: Icons.info_rounded,
                  accentColor: AppColors.gold,
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: 'Simpan Profil',
              icon: Icons.save_rounded,
              isLoading: widget.appState.isBusy,
              fullWidth: true,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Keluar',
              icon: Icons.logout_rounded,
              fullWidth: true,
              onPressed: widget.appState.isBusy ? null : widget.appState.logout,
            ),
          ],
        ),
      ),
    );
  }

  void _fillFromProfile(AlumniProfile? profile) {
    _emailController.text = profile?.email ?? '';
    _phoneController.text = profile?.phoneNumber ?? '';
    _cityController.text = profile?.city ?? '';
    _jobController.text = profile?.jobTitle ?? '';
    _institutionController.text = profile?.institution ?? '';
  }

  Future<void> _submit() async {
    final payload = {
      'contact_email': _emailController.text.trim(),
      'contact_phone': _phoneController.text.trim(),
      'work_location': _cityController.text.trim(),
      'job_title': _jobController.text.trim(),
      'company_name': _institutionController.text.trim(),
    };

    if (payload.values.any((value) => value.isEmpty)) {
      setState(() {
        _validationMessage = 'Semua field wajib dilengkapi.';
      });
      return;
    }

    setState(() => _validationMessage = null);
    await widget.appState.completeProfile(payload);
  }
}
