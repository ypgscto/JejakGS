import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

const jobCategories = [
  'Perawat',
  'Bidan',
  'Tenaga kesehatan',
  'Klinik/RS',
  'Puskesmas',
  'Dosen/tutor',
  'Kerja luar negeri',
  'Studi lanjut/profesi',
  'Magang/volunteer',
];

class JobListScreen extends StatefulWidget {
  const JobListScreen({
    required this.appState,
    required this.onOpenDetail,
    required this.onOpenSaved,
    required this.onOpenHistory,
    super.key,
  });

  final AppState appState;
  final ValueChanged<String> onOpenDetail;
  final VoidCallback onOpenSaved;
  final VoidCallback onOpenHistory;

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final _searchController = TextEditingController();
  final _locationController = TextEditingController();
  final _employmentTypeController = TextEditingController();
  String? _category;
  bool _isLoading = true;
  String? _errorMessage;
  List<JobPost> _jobs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _employmentTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingState(message: 'Memuat loker...');
    if (_errorMessage != null) {
      return ErrorState(
        title: 'Loker belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        AppHeader(
          title: 'Loker/Karier',
          subtitle: 'Data lowongan berasal dari SIMAWA-GS.',
          leadingIcon: Icons.work_rounded,
        ),
        const SizedBox(height: AppSpacing.xxl),
        CustomTextField(
          label: 'Search lowongan',
          controller: _searchController,
          prefixIcon: Icons.search_rounded,
          onChanged: (_) => _load(),
        ),
        const SizedBox(height: AppSpacing.md),
        CustomTextField(
          label: 'Filter lokasi',
          controller: _locationController,
          prefixIcon: Icons.location_on_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        CustomTextField(
          label: 'Jenis pekerjaan',
          controller: _employmentTypeController,
          prefixIcon: Icons.schedule_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String>(
          initialValue: _category,
          decoration: const InputDecoration(labelText: 'Kategori'),
          items: jobCategories
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) {
            setState(() => _category = value);
            _load();
          },
        ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: 'Terapkan Filter',
          icon: Icons.filter_alt_rounded,
          fullWidth: true,
          onPressed: _load,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (_jobs.isEmpty)
          const EmptyState(
            icon: Icons.work_outline_rounded,
            title: 'Belum ada lowongan',
            description: 'Lowongan akan tampil dari SIMAWA-GS saat tersedia.',
          )
        else
          for (final job in _jobs) ...[
            JobCard(
              position: job.position,
              company: job.company,
              location: job.location,
              employmentType: job.employmentType,
              category: job.categoryLabel ?? job.category,
              postedDateLabel: _dateLabel(job.publishedAt, 'Posting'),
              deadlineLabel: _dateLabel(job.deadlineAt, 'Deadline'),
              isSaved: job.isApplied,
              onSavePressed: null,
              onTap: () => widget.onOpenDetail(job.id),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }

  Future<void> _load() async {
    final response = await widget.appState.jobService.getJobs(
      filters: {
        if (_searchController.text.trim().isNotEmpty)
          'q': _searchController.text.trim(),
        if (_locationController.text.trim().isNotEmpty)
          'location': _locationController.text.trim(),
        if (_employmentTypeController.text.trim().isNotEmpty)
          'employment_type': _employmentTypeController.text.trim(),
        if (_category != null) 'category': _category,
      },
    );
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _jobs = response.data ?? const [];
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Loker belum tersedia.';
      }
    });
  }

  String? _dateLabel(DateTime? value, String prefix) {
    if (value == null) return null;
    return '$prefix: ${value.toLocal().toString().split(' ').first}';
  }
}
