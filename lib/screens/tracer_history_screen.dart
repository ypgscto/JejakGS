import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class TracerHistoryScreen extends StatefulWidget {
  const TracerHistoryScreen({
    required this.appState,
    required this.onBack,
    required this.onOpenReview,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;
  final ValueChanged<String> onOpenReview;

  @override
  State<TracerHistoryScreen> createState() => _TracerHistoryScreenState();
}

class _TracerHistoryScreenState extends State<TracerHistoryScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<TracerSubmission> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'Memuat riwayat tracer...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: 'Riwayat tracer belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    if (_items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _BackTitle(title: 'Riwayat Tracer', onBack: widget.onBack),
          const SizedBox(height: AppSpacing.xxl),
          const EmptyState(
            icon: Icons.history_rounded,
            title: 'Belum ada riwayat pengisian',
            description:
                'Riwayat tracer akan tampil setelah data tersedia dari SIMAWA-GS.',
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Riwayat Tracer', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        for (final item in _items) ...[
          StatusCard(
            title: item.title ?? 'Tracer Study',
            description:
                'Status: ${item.status.name}${item.submittedAt == null ? '' : '\nDikirim: ${item.submittedAt!.toLocal().toString().split('.').first}'}',
            icon: item.hasRevisionNote
                ? Icons.rate_review_rounded
                : Icons.assignment_turned_in_rounded,
            accentColor: item.hasRevisionNote
                ? AppColors.gold
                : AppColors.maroon,
            action: SecondaryButton(
              label: 'Lihat Review',
              icon: Icons.visibility_rounded,
              fullWidth: true,
              onPressed: () => widget.onOpenReview(item.id),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await widget.appState.tracerService.getHistory();
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _items = response.data ?? const [];
      } else {
        _errorMessage = response.message ?? 'Riwayat tracer belum tersedia.';
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
