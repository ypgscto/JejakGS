import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class SavedJobScreen extends StatefulWidget {
  const SavedJobScreen({
    required this.appState,
    required this.onBack,
    required this.onOpenDetail,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;
  final ValueChanged<String> onOpenDetail;

  @override
  State<SavedJobScreen> createState() => _SavedJobScreenState();
}

class _SavedJobScreenState extends State<SavedJobScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<JobPost> _jobs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'Memuat loker tersimpan...');
    }
    if (_errorMessage != null) {
      return ErrorState(
        title: 'Loker tersimpan belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Loker Tersimpan', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        if (_jobs.isEmpty)
          const EmptyState(
            icon: Icons.bookmark_border_rounded,
            title: 'Belum ada loker tersimpan',
            description: 'Lowongan yang disimpan akan tampil dari SIMAWA-GS.',
          )
        else
          for (final job in _jobs) ...[
            JobCard(
              position: job.position,
              company: job.company,
              location: job.location,
              employmentType: job.employmentType,
              category: job.category,
              deadlineLabel: _dateLabel(job.deadlineAt),
              isSaved: true,
              onSavePressed: () => _unsave(job),
              onTap: () => widget.onOpenDetail(job.id),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }

  Future<void> _load() async {
    final response = await widget.appState.jobService.getSavedJobs();
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _jobs = response.data ?? const [];
      } else {
        _errorMessage = response.message ?? 'Loker tersimpan belum tersedia.';
      }
    });
  }

  Future<void> _unsave(JobPost job) async {
    await widget.appState.jobService.unsaveJob(job.id);
    await _load();
  }

  String? _dateLabel(DateTime? value) {
    if (value == null) return null;
    return 'Deadline: ${value.toLocal().toString().split(' ').first}';
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
