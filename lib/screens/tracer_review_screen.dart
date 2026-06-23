import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class TracerReviewScreen extends StatefulWidget {
  const TracerReviewScreen({
    required this.appState,
    required this.submissionId,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final String submissionId;
  final VoidCallback onBack;

  @override
  State<TracerReviewScreen> createState() => _TracerReviewScreenState();
}

class _TracerReviewScreenState extends State<TracerReviewScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  TracerSubmission? _submission;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'Memuat review tracer...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: 'Review belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    final submission = _submission;
    if (submission == null) {
      return const EmptyState(
        icon: Icons.rate_review_outlined,
        title: 'Review belum tersedia',
        description: 'Data review tracer akan berasal dari SIMAWA-GS.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Review Tracer', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        StatusCard(
          title: submission.title ?? 'Tracer Study',
          description: 'Status: ${submission.status.name}',
          icon: Icons.assignment_turned_in_rounded,
          accentColor: AppColors.maroon,
        ),
        if (submission.hasRevisionNote) ...[
          const SizedBox(height: AppSpacing.md),
          StatusCard(
            title: 'Catatan Revisi',
            description: submission.revisionNote!,
            icon: Icons.rate_review_rounded,
            accentColor: AppColors.gold,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        const SectionTitle(title: 'Jawaban Terkirim'),
        const SizedBox(height: AppSpacing.md),
        if (submission.answers.isEmpty)
          const EmptyState(
            icon: Icons.inbox_rounded,
            title: 'Jawaban belum tersedia',
            description: 'Jawaban review akan tampil dari API SIMAWA-GS.',
          )
        else
          for (final answer in submission.answers) ...[
            StatusCard(
              title:
                  answer.questionLabel ??
                  _fallbackQuestionLabel(answer.questionId),
              description:
                  answer.displayValue?.toString() ??
                  (answer.values.isNotEmpty
                      ? answer.values.join(', ')
                      : answer.value?.toString() ?? '-'),
              icon: Icons.check_circle_rounded,
              accentColor: AppColors.maroon,
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

    final response = await widget.appState.tracerService.getReview(
      widget.submissionId,
    );
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _submission = response.data;
      } else {
        _errorMessage = response.message ?? 'Review tracer belum tersedia.';
      }
    });
  }

  String _fallbackQuestionLabel(String value) {
    const labels = {
      'survey_year': 'Tahun survei',
      'employment_status': 'Status pekerjaan saat ini',
      'waiting_period_months': 'Lama tunggu kerja pertama (bulan)',
      'field_relevance': 'Kesesuaian bidang kerja dengan prodi',
      'company_name': 'Perusahaan / instansi',
      'job_title': 'Jabatan',
      'industry_sector': 'Bidang industri',
      'salary_range': 'Kisaran gaji',
      'business_name': 'Nama usaha (wirausaha)',
      'further_study_institution': 'Institusi studi lanjut',
      'further_study_program': 'Program studi lanjut',
      'further_study_level': 'Jenjang studi lanjut',
      'feedback': 'Masukan / saran',
    };

    return labels[value] ?? value.replaceAll('_', ' ');
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
