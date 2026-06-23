import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_shadows.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

enum BatchmateFilter { all, sameCity, working, furtherStudy, ikaMember }

class BatchmateScreen extends StatefulWidget {
  const BatchmateScreen({
    required this.appState,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;

  @override
  State<BatchmateScreen> createState() => _BatchmateScreenState();
}

class _BatchmateScreenState extends State<BatchmateScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  List<BatchmateProfile> _items = const [];
  BatchmateFilter _filter = BatchmateFilter.all;
  BatchmateProfile? _selected;

  @override
  void initState() {
    super.initState();
    _loadIfAllowed();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_selected != null) {
      return BatchmateDetailScreen(
        profile: _selected!,
        onBack: () => setState(() => _selected = null),
      );
    }

    final profile = widget.appState.alumniProfile;
    if (!_canAccessBatchmates(profile)) {
      return _BlockedBatchmateView(
        onBack: widget.onBack,
        message:
            'Fitur Jejak Angkatan aktif setelah data alumni Anda diverifikasi oleh Bagian Alumni Institusi.',
      );
    }

    if (_isLoading) {
      return const LoadingState(message: 'Memuat Jejak Angkatan...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: 'Jejak Angkatan belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _loadIfAllowed,
      );
    }

    final currentProfile = profile!;
    final eligibleItems = _eligibleItems(currentProfile);
    final filtered = _filteredItems(currentProfile, eligibleItems);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                'Jejak Angkatan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppHeader(
          title: 'Jejak Angkatan',
          subtitle:
              '${currentProfile.programStudy} • Angkatan ${currentProfile.batchYear}',
          leadingIcon: Icons.diversity_3_rounded,
        ),
        const SizedBox(height: AppSpacing.xl),
        _SummaryRow(items: eligibleItems),
        const SizedBox(height: AppSpacing.xl),
        CustomTextField(
          label: 'Cari nama teman',
          controller: _searchController,
          prefixIcon: Icons.search_rounded,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.md),
        _FilterChips(
          selected: _filter,
          onSelected: (value) => setState(() => _filter = value),
        ),
        const SizedBox(height: AppSpacing.xl),
        const StatusCard(
          title: 'Catatan privasi',
          description:
              'Nomor telepon tidak ditampilkan kepada alumni lain. Data kontak hanya digunakan untuk kepentingan resmi kampus.',
          icon: Icons.privacy_tip_rounded,
          accentColor: AppColors.maroon,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (filtered.isEmpty)
          const EmptyState(
            icon: Icons.people_outline_rounded,
            title: 'Belum ada teman seangkatan',
            description:
                'Belum ada teman seangkatan yang terdaftar atau mengaktifkan profil publik.',
          )
        else
          for (final item in filtered) ...[
            _BatchmateCard(
              profile: item,
              onTap: () => setState(() => _selected = item),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }

  Future<void> _loadIfAllowed() async {
    final profile = widget.appState.alumniProfile;
    if (!_canAccessBatchmates(profile)) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await widget.appState.batchmateService.getBatchmates(
      filters: {
        'program_study': profile!.programStudy,
        'batch_year': profile.batchYear,
      },
    );
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _items = response.data ?? const [];
      } else {
        _errorMessage =
            response.message ?? 'Data Jejak Angkatan belum tersedia.';
      }
    });
  }

  List<BatchmateProfile> _eligibleItems(AlumniProfile currentProfile) {
    return _items.where((item) {
      final sourceAllowed =
          item.sourceType == AlumniSourceType.siakad ||
          item.sourceType == AlumniSourceType.manualRegister;
      return sourceAllowed &&
          item.verificationStatus.state == AlumniVerificationState.verified &&
          item.showInBatchmates &&
          item.programStudy == currentProfile.programStudy &&
          item.batchYear == currentProfile.batchYear;
    }).toList();
  }

  List<BatchmateProfile> _filteredItems(
    AlumniProfile currentProfile,
    List<BatchmateProfile> source,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    return source.where((item) {
      if (query.isNotEmpty && !item.name.toLowerCase().contains(query)) {
        return false;
      }

      return switch (_filter) {
        BatchmateFilter.all => true,
        BatchmateFilter.sameCity =>
          currentProfile.city != null && item.city == currentProfile.city,
        BatchmateFilter.working =>
          _hasValue(item.jobTitle) || _hasValue(item.institution),
        BatchmateFilter.furtherStudy =>
          (item.jobTitle ?? '').toLowerCase().contains('studi'),
        BatchmateFilter.ikaMember =>
          (item.ikaStatusLabel ?? '').toLowerCase().contains('ika') ||
              (item.ikaStatusLabel ?? '').toLowerCase().contains('aktif'),
      };
    }).toList();
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

  bool _canAccessBatchmates(AlumniProfile? profile) {
    return widget.appState.canAccessFeature(AlumniFeature.batchmates) &&
        profile != null &&
        profile.programStudy.trim().isNotEmpty &&
        profile.batchYear > 0;
  }
}

class BatchmateDetailScreen extends StatelessWidget {
  const BatchmateDetailScreen({
    required this.profile,
    required this.onBack,
    super.key,
  });

  final BatchmateProfile profile;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                profile.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _BatchmateCard(profile: profile),
      ],
    );
  }
}

class _BlockedBatchmateView extends StatelessWidget {
  const _BlockedBatchmateView({required this.onBack, required this.message});

  final VoidCallback onBack;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                'Jejak Angkatan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        StatusCard(
          title: 'Jejak Angkatan belum aktif',
          description: message,
          icon: Icons.lock_rounded,
          accentColor: AppColors.gold,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.items});

  final List<BatchmateProfile> items;

  @override
  Widget build(BuildContext context) {
    final active = items
        .where(
          (item) => (item.ikaStatusLabel ?? '').toLowerCase().contains('aktif'),
        )
        .length;
    final social = items
        .where(
          (item) =>
              item.showSocialMedia &&
              (item.publicSocialMedia['instagram']?.isNotEmpty == true ||
                  item.publicSocialMedia['linkedin']?.isNotEmpty == true),
        )
        .length;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(label: 'Terdaftar', value: '${items.length}'),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryCard(label: 'Aktif', value: '$active'),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryCard(label: 'Sosial', value: '$social'),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.mediumGrey),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final BatchmateFilter selected;
  final ValueChanged<BatchmateFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final labels = {
      BatchmateFilter.all: 'Semua',
      BatchmateFilter.sameCity: 'Satu kota',
      BatchmateFilter.working: 'Sudah bekerja',
      BatchmateFilter.furtherStudy: 'Studi lanjut',
      BatchmateFilter.ikaMember: 'Anggota IKA',
    };

    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        for (final entry in labels.entries)
          ChoiceChip(
            label: Text(entry.value),
            selected: selected == entry.key,
            onSelected: (_) => onSelected(entry.key),
          ),
      ],
    );
  }
}

class _BatchmateCard extends StatelessWidget {
  const _BatchmateCard({required this.profile, this.onTap});

  final BatchmateProfile profile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 390;
    final avatar = CircleAvatar(
      radius: isCompact ? 24 : 28,
      backgroundColor: AppColors.softGold,
      backgroundImage: profile.showAvatar && profile.avatarUrl != null
          ? NetworkImage(profile.avatarUrl!)
          : null,
      child: profile.showAvatar && profile.avatarUrl != null
          ? null
          : Text(_initials(profile.name)),
    );
    final details = _BatchmateDetails(profile: profile);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.mediumGrey),
          boxShadow: AppShadows.soft,
        ),
        child: isCompact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  avatar,
                  const SizedBox(height: AppSpacing.md),
                  details,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  avatar,
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: details),
                ],
              ),
      ),
    );
  }

  String _initials(String value) {
    final words = value.trim().split(RegExp(r'\s+'));
    return words.isEmpty ? '-' : words.take(2).map((word) => word[0]).join();
  }
}

class _BatchmateDetails extends StatelessWidget {
  const _BatchmateDetails({required this.profile});

  final BatchmateProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(profile.name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${profile.programStudy} • Angkatan ${profile.batchYear}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (profile.showCity && _hasValue(profile.city))
          Text(
            'Domisili: ${profile.city}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        if (profile.showJobTitle && _hasValue(profile.jobTitle))
          Text(
            'Pekerjaan: ${profile.jobTitle}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        if (profile.showInstitution && _hasValue(profile.institution))
          Text(
            'Instansi: ${profile.institution}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        if (_hasValue(profile.ikaStatusLabel))
          Text(
            'Status IKA: ${profile.ikaStatusLabel}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        if (profile.showSocialMedia) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (_hasValue(profile.publicSocialMedia['instagram']))
                SecondaryButton(
                  label: 'Instagram',
                  onPressed: () =>
                      _openInstagram(profile.publicSocialMedia['instagram']!),
                ),
              if (_hasValue(profile.publicSocialMedia['linkedin']))
                SecondaryButton(
                  label: 'LinkedIn',
                  onPressed: () =>
                      _openUrl(profile.publicSocialMedia['linkedin']!),
                ),
            ],
          ),
        ],
      ],
    );
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

  Future<void> _openInstagram(String username) {
    final clean = username.replaceAll('@', '');
    return _openUrl('https://instagram.com/$clean');
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
