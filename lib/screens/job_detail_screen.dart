import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({
    required this.appState,
    required this.jobId,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final String jobId;
  final VoidCallback onBack;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  JobPost? _job;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'Memuat detail loker...');
    }
    if (_errorMessage != null) {
      return ErrorState(
        title: 'Detail loker belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    final job = _job;
    if (job == null) {
      return const EmptyState(
        icon: Icons.work_outline_rounded,
        title: 'Detail loker belum tersedia',
        description: 'Detail lowongan akan ditampilkan dari SIMAWA-GS.',
      );
    }

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
                'Detail Loker',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        AppHeader(
          title: job.position,
          subtitle: job.company,
          leadingIcon: Icons.work_rounded,
        ),
        const SizedBox(height: AppSpacing.xl),
        StatusCard(
          title: 'Informasi Lowongan',
          description:
              'Lokasi: ${job.location ?? '-'}\nJenis: ${job.employmentType ?? '-'}\nKategori: ${job.category ?? '-'}\nDeadline: ${_date(job.deadlineAt)}',
          icon: Icons.info_rounded,
          accentColor: AppColors.maroon,
        ),
        if (job.description != null) ...[
          const SizedBox(height: AppSpacing.lg),
          StatusCard(
            title: 'Deskripsi',
            description: job.description!,
            icon: Icons.description_rounded,
            accentColor: AppColors.gold,
          ),
        ],
        if (job.requirements.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          StatusCard(
            title: 'Persyaratan',
            description: job.requirements.join('\n'),
            icon: Icons.checklist_rounded,
            accentColor: AppColors.maroon,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        _ApplyActions(job: job),
      ],
    );
  }

  Future<void> _load() async {
    final response = await widget.appState.jobService.getJobDetail(
      widget.jobId,
    );
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _job = response.data;
      } else {
        _errorMessage = response.message ?? 'Detail loker belum tersedia.';
      }
    });
  }

  String _date(DateTime? value) {
    return value?.toLocal().toString().split(' ').first ?? '-';
  }
}

class _ApplyActions extends StatelessWidget {
  const _ApplyActions({required this.job});

  final JobPost job;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];
    if (_hasValue(job.applicationUrl)) {
      actions.add(
        PrimaryButton(
          label: 'Lamar via Link Resmi',
          icon: Icons.open_in_new_rounded,
          fullWidth: true,
          onPressed: () => _open(context, Uri.parse(job.applicationUrl!)),
        ),
      );
    }
    if (_hasValue(job.applicationEmail)) {
      actions.add(
        SecondaryButton(
          label: 'Lamar via Email',
          icon: Icons.email_rounded,
          fullWidth: true,
          onPressed: () =>
              _open(context, Uri(scheme: 'mailto', path: job.applicationEmail)),
        ),
      );
    }
    if (_hasValue(job.applicationWhatsapp)) {
      final phone = job.applicationWhatsapp!.replaceAll(RegExp(r'\D'), '');
      actions.add(
        SecondaryButton(
          label: 'Lamar via WhatsApp',
          icon: Icons.chat_rounded,
          fullWidth: true,
          onPressed: () => _open(context, Uri.parse('https://wa.me/$phone')),
        ),
      );
    }

    if (actions.isEmpty) {
      return const StatusCard(
        title: 'Kanal lamaran belum tersedia',
        description:
            'Link/email/WhatsApp resmi instansi akan ditampilkan jika disediakan oleh admin SIMAWA-GS.',
        icon: Icons.info_rounded,
        accentColor: AppColors.gold,
      );
    }

    return Column(
      children: [
        for (final action in actions) ...[
          action,
          if (action != actions.last) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

  Future<void> _open(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kanal lamaran belum dapat dibuka.')),
      );
    }
  }
}
