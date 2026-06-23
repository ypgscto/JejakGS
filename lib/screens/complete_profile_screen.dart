import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final _nimController = TextEditingController();
  final _nameController = TextEditingController();
  final _cohortYearController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _imagePicker = ImagePicker();
  XFile? _diplomaPhoto;
  XFile? _profilePhoto;
  String? _validationMessage;
  String? _successMessage;

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
    _nimController.dispose();
    _nameController.dispose();
    _cohortYearController.dispose();
    _graduationYearController.dispose();
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
                  'Kirim data alumni dan berkas pendukung agar admin SIMAWA-GS dapat melakukan verifikasi manual.',
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
              label: 'NIM',
              controller: _nimController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.badge_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'Nama Alumni',
              controller: _nameController,
              prefixIcon: Icons.person_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'Tahun Angkatan',
              hintText: 'Contoh: 2019',
              controller: _cohortYearController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.groups_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'Tahun Lulus',
              hintText: 'Contoh: 2023',
              controller: _graduationYearController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.school_rounded,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),
            _FilePickerTile(
              title: 'Foto Ijazah',
              description:
                  _diplomaPhoto?.name ??
                  'Upload foto ijazah untuk verifikasi admin SIMAWA-GS.',
              icon: Icons.description_rounded,
              onPressed: widget.appState.isBusy
                  ? null
                  : () => _pickImage(isDiploma: true),
            ),
            const SizedBox(height: AppSpacing.lg),
            _FilePickerTile(
              title: 'Foto Terbaru',
              description:
                  _profilePhoto?.name ??
                  'Upload foto terbaru alumni untuk dicocokkan oleh admin.',
              icon: Icons.photo_camera_rounded,
              onPressed: widget.appState.isBusy
                  ? null
                  : () => _pickImage(isDiploma: false),
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
            if (_successMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: StatusCard(
                  title: 'Pengajuan terkirim',
                  description: _successMessage!,
                  icon: Icons.check_circle_rounded,
                  accentColor: AppColors.success,
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: 'Kirim untuk Verifikasi',
              icon: Icons.send_rounded,
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
    if (profile == null) {
      _nimController.clear();
      _nameController.clear();
      _cohortYearController.clear();
      _graduationYearController.clear();
      return;
    }

    _nimController.text = profile.nim;
    _nameController.text = profile.name;
    _cohortYearController.text = profile.batchYear <= 0
        ? ''
        : profile.batchYear.toString();
    _graduationYearController.text = profile.graduationYear <= 0
        ? ''
        : profile.graduationYear.toString();
  }

  Future<void> _pickImage({required bool isDiploma}) async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );
    if (image == null || !mounted) {
      return;
    }

    setState(() {
      if (isDiploma) {
        _diplomaPhoto = image;
      } else {
        _profilePhoto = image;
      }
      _validationMessage = null;
      _successMessage = null;
    });
  }

  Future<void> _submit() async {
    final nim = _nimController.text.trim();
    final name = _nameController.text.trim();
    final cohortYear = _cohortYearController.text.trim();
    final graduationYear = _graduationYearController.text.trim();

    if ([nim, name, cohortYear, graduationYear].any((value) => value.isEmpty)) {
      setState(() {
        _validationMessage = 'Semua field wajib dilengkapi.';
        _successMessage = null;
      });
      return;
    }

    if (cohortYear.length != 4 || graduationYear.length != 4) {
      setState(() {
        _validationMessage = 'Tahun angkatan dan tahun lulus harus 4 digit.';
        _successMessage = null;
      });
      return;
    }

    final diplomaPhoto = _diplomaPhoto;
    final profilePhoto = _profilePhoto;
    if (diplomaPhoto == null || profilePhoto == null) {
      setState(() {
        _validationMessage = 'Foto ijazah dan foto terbaru wajib diupload.';
        _successMessage = null;
      });
      return;
    }

    final diplomaBytes = await diplomaPhoto.readAsBytes();
    final profileBytes = await profilePhoto.readAsBytes();

    setState(() {
      _validationMessage = null;
      _successMessage = null;
    });
    final success = await widget.appState.submitVerificationProfile(
      fields: {
        'source_type': 'siakad',
        'nim': nim,
        'name': name,
        'cohort_year': cohortYear,
        'graduation_year': graduationYear,
      },
      diplomaPhotoBytes: diplomaBytes,
      diplomaPhotoFileName: diplomaPhoto.name,
      profilePhotoBytes: profileBytes,
      profilePhotoFileName: profilePhoto.name,
    );
    if (!mounted || !success) {
      return;
    }

    setState(() {
      _successMessage =
          'Data dan berkas berhasil dikirim. Akun alumni akan aktif setelah diverifikasi admin SIMAWA-GS.';
    });
  }
}

class _FilePickerTile extends StatelessWidget {
  const _FilePickerTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mediumGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.softGold,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.maroon),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.upload_rounded),
            label: const Text('Pilih'),
          ),
        ],
      ),
    );
  }
}
