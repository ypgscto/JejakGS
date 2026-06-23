import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class TracerHomeScreen extends StatefulWidget {
  const TracerHomeScreen({
    required this.appState,
    required this.onOpenForm,
    required this.onOpenHistory,
    super.key,
  });

  final AppState appState;
  final VoidCallback onOpenForm;
  final VoidCallback onOpenHistory;

  @override
  State<TracerHomeScreen> createState() => _TracerHomeScreenState();
}

class _TracerHomeScreenState extends State<TracerHomeScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  TracerStatus? _status;
  TracerForm? _activeForm;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'Memuat status Tracer Study...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: 'Tracer Study belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const AppHeader(
          title: 'Tracer Study',
          subtitle:
              'Isi tracer study SIMAWA-GS melalui aplikasi mobile JejakGS.',
          leadingIcon: Icons.assignment_rounded,
        ),
        const SizedBox(height: AppSpacing.xxl),
        if (_status == null)
          const EmptyState(
            icon: Icons.assignment_outlined,
            title: 'Status tracer belum tersedia',
            description:
                'Status pengisian tracer akan tampil setelah endpoint SIMAWA-GS tersedia.',
          )
        else
          TracerProgressCard(
            title: 'Status Pengisian',
            progress: _status!.progress,
            description: _status!.state.name,
            currentStepLabel: _status!.currentStep,
          ),
        const SizedBox(height: AppSpacing.lg),
        _PeriodCard(form: _activeForm),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'Isi Tracer Study',
          icon: Icons.edit_document,
          fullWidth: true,
          onPressed: widget.onOpenForm,
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: 'Riwayat Pengisian',
          icon: Icons.history_rounded,
          fullWidth: true,
          onPressed: widget.onOpenHistory,
        ),
      ],
    );
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final statusResponse = await widget.appState.tracerService.getProgress();
    if (!statusResponse.isSuccess) {
      setState(() {
        _errorMessage =
            statusResponse.message ?? 'Status tracer belum tersedia.';
        _isLoading = false;
      });
      return;
    }

    final formResponse = await widget.appState.tracerService.getActiveForm();
    if (!formResponse.isSuccess) {
      setState(() {
        _status = statusResponse.data;
        _activeForm = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _status = statusResponse.data;
      _activeForm = formResponse.data;
      _isLoading = false;
    });
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.form});

  final TracerForm? form;

  @override
  Widget build(BuildContext context) {
    if (form == null) {
      return const StatusCard(
        title: 'Periode tracer aktif belum tersedia',
        description: 'Periode tracer akan diambil dari SIMAWA-GS.',
        icon: Icons.calendar_month_rounded,
        accentColor: AppColors.gold,
      );
    }

    return StatusCard(
      title: form!.title,
      description: _periodText(form!),
      icon: Icons.calendar_month_rounded,
      accentColor: AppColors.maroon,
    );
  }

  String _periodText(TracerForm form) {
    final open = form.opensAt?.toLocal().toString().split('.').first ?? '-';
    final close = form.closesAt?.toLocal().toString().split('.').first ?? '-';
    return 'Periode aktif: $open sampai $close';
  }
}
