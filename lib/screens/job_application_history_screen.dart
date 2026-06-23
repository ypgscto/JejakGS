import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class JobApplicationHistoryScreen extends StatefulWidget {
  const JobApplicationHistoryScreen({
    required this.appState,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;

  @override
  State<JobApplicationHistoryScreen> createState() =>
      _JobApplicationHistoryScreenState();
}

class _JobApplicationHistoryScreenState
    extends State<JobApplicationHistoryScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<JobApplication> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'Memuat riwayat lamaran...');
    }
    if (_errorMessage != null) {
      return ErrorState(
        title: 'Riwayat lamaran belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Riwayat Lamaran', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        if (_items.isEmpty)
          const EmptyState(
            icon: Icons.history_rounded,
            title: 'Belum ada riwayat lamaran',
            description:
                'Riwayat lamaran internal akan tampil jika fitur lamaran tersedia di SIMAWA-GS.',
          )
        else
          for (final item in _items) ...[
            StatusCard(
              title: item.job?.position ?? 'Lamaran Loker',
              description:
                  'Status: ${item.status.name}${item.submittedAt == null ? '' : '\nDikirim: ${item.submittedAt!.toLocal().toString().split('.').first}'}',
              icon: Icons.assignment_turned_in_rounded,
              accentColor: AppColors.maroon,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }

  Future<void> _load() async {
    final response = await widget.appState.jobService.getApplicationHistory();
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _items = response.data ?? const [];
      } else {
        _errorMessage = response.message ?? 'Riwayat lamaran belum tersedia.';
      }
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
