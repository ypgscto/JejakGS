import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_shadows.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';
import '../forum/forum_safety.dart';
import 'delete_account_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nimController = TextEditingController();
  final _nameController = TextEditingController();
  final _programController = TextEditingController();
  final _batchYearController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _employmentStatusController = TextEditingController();
  final _institutionController = TextEditingController();
  final _positionController = TextEditingController();
  final _instagramController = TextEditingController();
  final _linkedInController = TextEditingController();
  final _facebookController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _websiteController = TextEditingController();

  String? _validationMessage;
  _AccountPage _accountPage = _AccountPage.profile;

  @override
  void initState() {
    super.initState();
    _fillFromProfile(widget.appState.alumniProfile);
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appState.alumniProfile != widget.appState.alumniProfile) {
      _fillFromProfile(widget.appState.alumniProfile);
    }
  }

  @override
  void dispose() {
    _nimController.dispose();
    _nameController.dispose();
    _programController.dispose();
    _batchYearController.dispose();
    _graduationYearController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _employmentStatusController.dispose();
    _institutionController.dispose();
    _positionController.dispose();
    _instagramController.dispose();
    _linkedInController.dispose();
    _facebookController.dispose();
    _tiktokController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_accountPage == _AccountPage.settings) {
      return _AccountSettingsView(
        onBack: () => setState(() => _accountPage = _AccountPage.profile),
        onDeleteAccount: () =>
            setState(() => _accountPage = _AccountPage.delete),
        onBlockedUsers: () =>
            setState(() => _accountPage = _AccountPage.blockedUsers),
      );
    }

    if (_accountPage == _AccountPage.blockedUsers) {
      return BlockedForumUsersScreen(
        appState: widget.appState,
        onBack: () => setState(() => _accountPage = _AccountPage.settings),
      );
    }

    if (_accountPage == _AccountPage.delete) {
      return DeleteAccountScreen(
        appState: widget.appState,
        onBack: () => setState(() => _accountPage = _AccountPage.settings),
      );
    }

    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final profile = widget.appState.alumniProfile;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            const AppHeader(
              title: 'Profil Alumni',
              subtitle: 'Kelola data pribadi yang tersinkron dengan SIMAWA-GS.',
              leadingIcon: Icons.person_rounded,
            ),
            const SizedBox(height: AppSpacing.xxl),
            const SectionTitle(title: 'Akun'),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Pengaturan Akun',
              icon: Icons.manage_accounts_rounded,
              fullWidth: true,
              onPressed: widget.appState.isBusy ? null : _openAccountSettings,
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (profile == null)
              const EmptyState(
                icon: Icons.person_outline_rounded,
                title: 'Profil belum dimuat',
                description:
                    'Profil alumni akan ditampilkan setelah berhasil diambil dari API.',
              )
            else ...[
              _ProfileHeader(
                profile: profile,
                isBusy: widget.appState.isBusy,
                onChangePhoto: _changeProfilePhoto,
              ),
              const SizedBox(height: AppSpacing.lg),
              _VerificationSection(profile: profile),
              const SizedBox(height: AppSpacing.lg),
              _SourceSection(profile: profile),
              const SizedBox(height: AppSpacing.xxl),
              _AcademicSection(
                profile: profile,
                nimController: _nimController,
                nameController: _nameController,
                programController: _programController,
                batchYearController: _batchYearController,
                graduationYearController: _graduationYearController,
              ),
              const SizedBox(height: AppSpacing.xxl),
              _ContactSection(
                emailController: _emailController,
                phoneController: _phoneController,
                cityController: _cityController,
              ),
              const SizedBox(height: AppSpacing.xxl),
              _CareerSection(
                employmentStatusController: _employmentStatusController,
                institutionController: _institutionController,
                positionController: _positionController,
              ),
              const SizedBox(height: AppSpacing.xxl),
              _SocialSection(
                instagramController: _instagramController,
                linkedInController: _linkedInController,
                facebookController: _facebookController,
                tiktokController: _tiktokController,
                websiteController: _websiteController,
              ),
              if (profile.canUploadDiplomaPhoto) ...[
                const SizedBox(height: AppSpacing.xxl),
                _DiplomaPhotoSection(onUploadPressed: _showDiplomaUploadInfo),
              ],
              if (_validationMessage != null ||
                  widget.appState.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                StatusCard(
                  title: 'Perubahan belum dapat disimpan',
                  description:
                      _validationMessage ?? widget.appState.errorMessage!,
                  icon: Icons.info_rounded,
                  accentColor: AppColors.gold,
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: 'Simpan Perubahan',
                icon: Icons.save_rounded,
                isLoading: widget.appState.isBusy,
                fullWidth: true,
                onPressed: () => _submit(profile),
              ),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(
                label: 'Pengaturan Tampilan Profil',
                icon: Icons.privacy_tip_rounded,
                fullWidth: true,
                onPressed: _showPrivacySettings,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Logout',
              icon: Icons.logout_rounded,
              fullWidth: true,
              onPressed: widget.appState.isBusy ? null : widget.appState.logout,
            ),
          ],
        );
      },
    );
  }

  void _openAccountSettings() {
    setState(() => _accountPage = _AccountPage.settings);
  }

  void _fillFromProfile(AlumniProfile? profile) {
    _nimController.text = profile?.nim ?? '';
    _nameController.text = profile?.name ?? '';
    _programController.text = profile?.programStudy ?? '';
    _batchYearController.text = profile?.batchYear.toString() ?? '';
    _graduationYearController.text = profile?.graduationYear.toString() ?? '';
    _emailController.text = profile?.email ?? '';
    _phoneController.text = profile?.phoneNumber ?? '';
    _cityController.text = profile?.city ?? '';
    _employmentStatusController.text =
        profile?.employmentStatus ?? profile?.jobTitle ?? '';
    _institutionController.text = profile?.institution ?? '';
    _positionController.text = profile?.position ?? '';
    _instagramController.text = profile?.socialMedia['instagram'] ?? '';
    _linkedInController.text = profile?.socialMedia['linkedin'] ?? '';
    _facebookController.text = profile?.socialMedia['facebook'] ?? '';
    _tiktokController.text = profile?.socialMedia['tiktok'] ?? '';
    _websiteController.text =
        profile?.socialMedia['website'] ??
        profile?.socialMedia['portfolio'] ??
        '';
  }

  Future<void> _submit(AlumniProfile profile) async {
    final validationMessage = _validateForm(profile);
    if (validationMessage != null) {
      setState(() => _validationMessage = validationMessage);
      return;
    }

    final payload = <String, dynamic>{
      'contact_email': _emailController.text.trim(),
      'contact_phone': _phoneController.text.trim(),
      'work_location': _cityController.text.trim(),
      'company_name': _institutionController.text.trim(),
      'job_title': _positionController.text.trim(),
      'social_media': {
        'instagram': _instagramController.text.trim(),
        'linkedin': _linkedInController.text.trim(),
        'facebook': _facebookController.text.trim(),
        'tiktok': _tiktokController.text.trim(),
        'website': _websiteController.text.trim(),
      },
    };
    final employmentStatus = _normalizedEmploymentStatus(
      _employmentStatusController.text,
    );
    if (employmentStatus != null) {
      payload['employment_status'] = employmentStatus;
    }

    if (profile.canEditAcademicData) {
      payload.addAll({
        'nim': _nimController.text.trim(),
        'name': _nameController.text.trim(),
        'program_study': _programController.text.trim(),
        'batch_year': int.tryParse(_batchYearController.text.trim()),
        'graduation_year': int.tryParse(_graduationYearController.text.trim()),
      });
    }

    setState(() => _validationMessage = null);
    await widget.appState.completeProfile(payload);
    if (!mounted) return;

    final message = widget.appState.errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message == null
              ? 'Perubahan profil berhasil disimpan.'
              : 'Perubahan belum dapat disimpan: $message',
        ),
      ),
    );
  }

  String? _validateForm(AlumniProfile profile) {
    final phone = _phoneController.text.trim();
    final instagram = _instagramController.text.trim();
    final linkedIn = _linkedInController.text.trim();

    if (profile.canEditAcademicData) {
      final hasEmptyAcademic = [
        _nimController,
        _nameController,
        _programController,
        _batchYearController,
        _graduationYearController,
      ].any((controller) => controller.text.trim().isEmpty);

      if (hasEmptyAcademic) {
        return 'Data akademik wajib diisi saat perbaikan data.';
      }
    }

    if (phone.isNotEmpty && !_isValidIndonesianPhone(phone)) {
      return 'Nomor HP harus angka saja dan memakai format Indonesia.';
    }

    if (instagram.isNotEmpty && !_isValidInstagramUsername(instagram)) {
      return 'Instagram cukup username, tanpa URL instagram.com.';
    }

    if (linkedIn.isNotEmpty && !_isValidLinkedInUrl(linkedIn)) {
      return 'LinkedIn harus berupa URL valid, contoh https://www.linkedin.com/in/username.';
    }

    return null;
  }

  bool _isValidIndonesianPhone(String value) {
    final digitsOnly = RegExp(r'^\d+$');
    final hasIndonesiaPrefix =
        value.startsWith('08') || value.startsWith('628');
    return digitsOnly.hasMatch(value) &&
        hasIndonesiaPrefix &&
        value.length >= 10 &&
        value.length <= 15;
  }

  bool _isValidInstagramUsername(String value) {
    if (value.contains('://') || value.contains('instagram.com')) {
      return false;
    }

    return RegExp(r'^[A-Za-z0-9._]{1,30}$').hasMatch(value);
  }

  bool _isValidLinkedInUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return false;
    }

    final isHttp = uri.scheme == 'http' || uri.scheme == 'https';
    return isHttp && uri.host.toLowerCase().contains('linkedin.com');
  }

  String? _normalizedEmploymentStatus(String value) {
    final normalized = value.trim().toLowerCase().replaceAll('_', ' ');
    if (normalized.isEmpty) return null;

    const aliases = {
      'employed': 'employed',
      'bekerja': 'employed',
      'kerja': 'employed',
      'unemployed': 'unemployed',
      'belum bekerja': 'unemployed',
      'tidak bekerja': 'unemployed',
      'entrepreneur': 'entrepreneur',
      'wirausaha': 'entrepreneur',
      'mandiri': 'entrepreneur',
      'usaha mandiri': 'entrepreneur',
      'further study': 'further_study',
      'further_study': 'further_study',
      'studi lanjut': 'further_study',
      'kuliah lanjut': 'further_study',
      'unknown': 'unknown',
      'belum diisi': 'unknown',
    };

    return aliases[normalized];
  }

  void _showDiplomaUploadInfo() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: EmptyState(
            icon: Icons.upload_file_rounded,
            title: 'Upload foto ijazah',
            description:
                'Foto ijazah hanya untuk verifikasi admin SIMAWA-GS dan tidak ditampilkan di profil publik, Jejak Angkatan, atau direktori alumni. Integrasi upload file akan mengikuti endpoint SIMAWA-GS.',
          ),
        );
      },
    );
  }

  void _showPrivacySettings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: EmptyState(
            icon: Icons.privacy_tip_rounded,
            title: 'Pengaturan Tampilan Profil',
            description:
                'Pengaturan ini mengatur data publik di Jejak Angkatan saat endpoint privacy tersedia. Nomor HP tidak akan ditampilkan di profil publik atau direktori alumni.',
          ),
        );
      },
    );
  }

  Future<void> _changeProfilePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 900,
      imageQuality: 85,
    );
    if (image == null) return;

    final success = await widget.appState.updateProfilePhoto(
      bytes: await image.readAsBytes(),
      fileName: image.name,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Foto profil berhasil diperbarui.'
              : widget.appState.errorMessage ??
                    'Foto profil belum dapat diunggah.',
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.isBusy,
    required this.onChangePhoto,
  });

  final AlumniProfile profile;
  final bool isBusy;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: AppColors.softGold,
                backgroundImage: profile.avatarUrl == null
                    ? null
                    : NetworkImage(profile.avatarUrl!),
                child: profile.avatarUrl == null
                    ? Text(
                        _initials(profile.name),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.maroon,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: -6,
                bottom: -6,
                child: Material(
                  color: AppColors.maroon,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isBusy ? null : onChangePhoto,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  profile.nim,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  profile.verificationStatus.label ??
                      profile.verificationStatus.state.name,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: isBusy ? null : onChangePhoto,
                  icon: const Icon(Icons.photo_camera_rounded),
                  label: const Text('Ganti Foto'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    return words.isEmpty
        ? '-'
        : words.take(2).map((word) => word[0].toUpperCase()).join();
  }
}

class _VerificationSection extends StatelessWidget {
  const _VerificationSection({required this.profile});

  final AlumniProfile profile;

  @override
  Widget build(BuildContext context) {
    return _SectionGroup(
      title: 'Status Verifikasi Alumni',
      child: StatusCard(
        title:
            profile.verificationStatus.label ??
            profile.verificationStatus.state.name,
        description:
            profile.verificationStatus.adminNote ??
            profile.verificationStatus.notes ??
            'Status verifikasi mengikuti data SIMAWA-GS.',
        icon: Icons.verified_user_rounded,
        accentColor:
            profile.verificationStatus.state == AlumniVerificationState.verified
            ? AppColors.success
            : AppColors.gold,
      ),
    );
  }
}

class _SourceSection extends StatelessWidget {
  const _SourceSection({required this.profile});

  final AlumniProfile profile;

  @override
  Widget build(BuildContext context) {
    final sourceText = switch (profile.sourceType) {
      AlumniSourceType.siakad => 'Data akademik terhubung SIAKAD-GS',
      AlumniSourceType.manualRegister =>
        'Data diverifikasi oleh Bagian Alumni Institusi',
      AlumniSourceType.unknown => 'Sumber data alumni belum tersedia',
    };

    return _SectionGroup(
      title: 'Sumber Data Alumni',
      child: StatusCard(
        title: sourceText,
        description: profile.isAcademicDataLocked
            ? 'Data akademik bersifat read-only. Alumni hanya dapat mengubah data non-akademik.'
            : 'Data akademik dapat diperbaiki hanya saat status memerlukan revisi.',
        icon: Icons.source_rounded,
        accentColor: AppColors.maroon,
      ),
    );
  }
}

class _AcademicSection extends StatelessWidget {
  const _AcademicSection({
    required this.profile,
    required this.nimController,
    required this.nameController,
    required this.programController,
    required this.batchYearController,
    required this.graduationYearController,
  });

  final AlumniProfile profile;
  final TextEditingController nimController;
  final TextEditingController nameController;
  final TextEditingController programController;
  final TextEditingController batchYearController;
  final TextEditingController graduationYearController;

  @override
  Widget build(BuildContext context) {
    final canEdit = profile.canEditAcademicData;

    return _SectionGroup(
      title: 'Data Akademik',
      child: Column(
        children: [
          CustomTextField(
            label: 'NIM',
            controller: nimController,
            enabled: canEdit,
            prefixIcon: Icons.badge_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            label: 'Nama',
            controller: nameController,
            enabled: canEdit,
            prefixIcon: Icons.person_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            label: 'Prodi',
            controller: programController,
            enabled: canEdit,
            prefixIcon: Icons.school_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            label: 'Tahun angkatan',
            controller: batchYearController,
            enabled: canEdit,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.calendar_month_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            label: 'Tahun lulus',
            controller: graduationYearController,
            enabled: canEdit,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.event_available_rounded,
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({
    required this.emailController,
    required this.phoneController,
    required this.cityController,
  });

  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController cityController;

  @override
  Widget build(BuildContext context) {
    return _SectionGroup(
      title: 'Data Kontak',
      child: Column(
        children: [
          CustomTextField(
            label: 'Email',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            label: 'Nomor HP',
            controller: phoneController,
            helperText:
                'Hanya tampil di profil pribadi pemilik akun, bukan profil publik atau Jejak Angkatan.',
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            label: 'Domisili kota',
            controller: cityController,
            prefixIcon: Icons.location_city_rounded,
          ),
        ],
      ),
    );
  }
}

class _CareerSection extends StatelessWidget {
  const _CareerSection({
    required this.employmentStatusController,
    required this.institutionController,
    required this.positionController,
  });

  final TextEditingController employmentStatusController;
  final TextEditingController institutionController;
  final TextEditingController positionController;

  @override
  Widget build(BuildContext context) {
    return _SectionGroup(
      title: 'Data Karier',
      child: Column(
        children: [
          CustomTextField(
            label: 'Status pekerjaan',
            controller: employmentStatusController,
            hintText: 'bekerja / wirausaha / belum bekerja / studi lanjut',
            prefixIcon: Icons.business_center_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            label: 'Instansi',
            controller: institutionController,
            prefixIcon: Icons.apartment_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            label: 'Jabatan',
            controller: positionController,
            prefixIcon: Icons.badge_rounded,
          ),
        ],
      ),
    );
  }
}

class _SocialSection extends StatelessWidget {
  const _SocialSection({
    required this.instagramController,
    required this.linkedInController,
    required this.facebookController,
    required this.tiktokController,
    required this.websiteController,
  });

  final TextEditingController instagramController;
  final TextEditingController linkedInController;
  final TextEditingController facebookController;
  final TextEditingController tiktokController;
  final TextEditingController websiteController;

  @override
  Widget build(BuildContext context) {
    return _SectionGroup(
      title: 'Akun Sosial',
      child: Column(
        children: [
          CustomTextField(
            label: 'Instagram username',
            controller: instagramController,
            hintText: 'contoh: jejakgs_alumni',
            prefixIcon: Icons.camera_alt_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            label: 'LinkedIn URL',
            controller: linkedInController,
            hintText: 'https://www.linkedin.com/in/username',
            keyboardType: TextInputType.url,
            prefixIcon: Icons.link_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            label: 'Facebook URL',
            controller: facebookController,
            keyboardType: TextInputType.url,
            prefixIcon: Icons.link_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            label: 'TikTok username',
            controller: tiktokController,
            prefixIcon: Icons.alternate_email_rounded,
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            label: 'Website/portfolio',
            controller: websiteController,
            keyboardType: TextInputType.url,
            prefixIcon: Icons.language_rounded,
          ),
        ],
      ),
    );
  }
}

class _DiplomaPhotoSection extends StatelessWidget {
  const _DiplomaPhotoSection({required this.onUploadPressed});

  final VoidCallback onUploadPressed;

  @override
  Widget build(BuildContext context) {
    return _SectionGroup(
      title: 'Foto Ijazah',
      child: StatusCard(
        title: 'Dokumen verifikasi admin',
        description:
            'Foto ijazah hanya untuk proses verifikasi admin SIMAWA-GS dan tidak tampil di profil publik, Jejak Angkatan, atau direktori alumni.',
        icon: Icons.upload_file_rounded,
        accentColor: AppColors.gold,
        action: SecondaryButton(
          label: 'Upload Foto Ijazah',
          icon: Icons.upload_rounded,
          fullWidth: true,
          onPressed: onUploadPressed,
        ),
      ),
    );
  }
}

class _SectionGroup extends StatelessWidget {
  const _SectionGroup({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}

enum _AccountPage { profile, settings, delete, blockedUsers }

class _AccountSettingsView extends StatelessWidget {
  const _AccountSettingsView({
    required this.onBack,
    required this.onDeleteAccount,
    required this.onBlockedUsers,
  });

  final VoidCallback onBack;
  final VoidCallback onDeleteAccount;
  final VoidCallback onBlockedUsers;

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
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                'Pengaturan Akun',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppHeader(
          title: 'Pengaturan Akun',
          subtitle: 'Kelola akses akun JejakGS Anda.',
          leadingIcon: Icons.manage_accounts_rounded,
        ),
        const SizedBox(height: AppSpacing.xxl),
        const StatusCard(
          title: 'Arsip alumni tetap tersimpan',
          description:
              'Menghapus akun aplikasi tidak menghapus arsip alumni atau status keanggotaan IKA yang tersimpan di STIKES Gunung Sari.',
          icon: Icons.warning_amber_rounded,
          accentColor: AppColors.danger,
        ),
        const SizedBox(height: AppSpacing.xl),
        SecondaryButton(
          label: 'Alumni Diblokir',
          icon: Icons.person_off_rounded,
          fullWidth: true,
          onPressed: onBlockedUsers,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onDeleteAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            icon: const Icon(Icons.delete_forever_rounded),
            label: const Text('Hapus Akun JejakGS'),
          ),
        ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.mediumGrey),
        boxShadow: AppShadows.soft,
      ),
      child: child,
    );
  }
}
