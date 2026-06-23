import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class TracerFormScreen extends StatefulWidget {
  const TracerFormScreen({
    required this.appState,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;

  @override
  State<TracerFormScreen> createState() => _TracerFormScreenState();
}

class _TracerFormScreenState extends State<TracerFormScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _validationMessage;
  TracerForm? _form;
  final Map<String, Object?> _answers = {};

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'Memuat pertanyaan tracer...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: 'Form tracer belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _loadForm,
      );
    }

    final form = _form;
    if (form == null || form.questions.isEmpty) {
      return const EmptyState(
        icon: Icons.assignment_outlined,
        title: 'Pertanyaan tracer belum tersedia',
        description:
            'Pertanyaan tracer akan diambil dari API SIMAWA-GS saat periode aktif tersedia.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: form.title, onBack: widget.onBack),
        if (form.description != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            form.description!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        for (final question in form.questions) ...[
          _QuestionField(
            question: question,
            value: _answers[question.id],
            onChanged: (value) => setState(() => _answers[question.id] = value),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (_validationMessage != null) ...[
          StatusCard(
            title: 'Tracer belum lengkap',
            description: _validationMessage!,
            icon: Icons.info_rounded,
            accentColor: AppColors.gold,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        PrimaryButton(
          label: 'Submit Final',
          icon: Icons.send_rounded,
          isLoading: _isSaving,
          fullWidth: true,
          onPressed: _submitFinal,
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: 'Simpan Draft',
          icon: Icons.save_rounded,
          fullWidth: true,
          onPressed: _isSaving ? null : _saveDraft,
        ),
      ],
    );
  }

  Future<void> _loadForm() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await widget.appState.tracerService.getActiveForm();
    if (!response.isSuccess) {
      setState(() {
        _errorMessage = response.message ?? 'Form tracer belum tersedia.';
        _isLoading = false;
      });
      return;
    }

    final form = response.data;
    setState(() {
      _form = form;
      _answers
        ..clear()
        ..addEntries(
          (form?.answers ?? const []).map(
            (answer) => MapEntry(
              answer.questionId,
              answer.values.isNotEmpty ? answer.values : answer.value,
            ),
          ),
        );
      _isLoading = false;
    });
  }

  Future<void> _saveDraft() async {
    final form = _form;
    if (form == null) return;

    setState(() => _isSaving = true);
    final response = await widget.appState.tracerService.saveDraft(
      _payloadFor(form),
    );

    setState(() => _isSaving = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response.isSuccess
              ? 'Draft tracer berhasil disimpan.'
              : response.message ?? 'Draft belum dapat disimpan.',
        ),
      ),
    );
  }

  Future<void> _submitFinal() async {
    final form = _form;
    if (form == null) return;

    final missing = form.questions
        .where((question) => question.isRequired && !_hasAnswer(question.id))
        .map((question) => question.label)
        .toList();

    if (missing.isNotEmpty) {
      setState(() {
        _validationMessage =
            'Pertanyaan wajib belum diisi: ${missing.join(', ')}';
      });
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Submit Final?'),
          content: const Text(
            'Pastikan semua jawaban sudah benar. Setelah submit final, data akan dikirim ke SIMAWA-GS.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isSaving = true;
      _validationMessage = null;
    });

    final response = await widget.appState.tracerService.submitFinal(
      _payloadFor(form),
    );
    setState(() => _isSaving = false);

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(response.isSuccess ? 'Tracer terkirim' : 'Submit gagal'),
          content: Text(
            response.isSuccess
                ? 'Jawaban tracer berhasil dikirim ke SIMAWA-GS.'
                : response.message ?? 'Jawaban tracer belum dapat dikirim.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (response.isSuccess) {
      widget.onBack();
    }
  }

  Map<String, dynamic> _payloadFor(TracerForm form) {
    return Map<String, dynamic>.fromEntries(
      _answers.entries.where((entry) => entry.value != null),
    );
  }

  bool _hasAnswer(String questionId) {
    final value = _answers[questionId];
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    return true;
  }
}

class _QuestionField extends StatelessWidget {
  const _QuestionField({
    required this.question,
    required this.value,
    required this.onChanged,
  });

  final TracerQuestion question;
  final Object? value;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final title = question.isRequired ? '${question.label} *' : question.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (question.description != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            question.description!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        _buildInput(context),
      ],
    );
  }

  Widget _buildInput(BuildContext context) {
    switch (question.type) {
      case TracerQuestionType.text:
      case TracerQuestionType.number:
        return TextFormField(
          initialValue: value?.toString(),
          keyboardType: question.type == TracerQuestionType.number
              ? TextInputType.number
              : TextInputType.text,
          onChanged: onChanged,
          decoration: const InputDecoration(labelText: 'Jawaban'),
        );
      case TracerQuestionType.textarea:
        return TextFormField(
          initialValue: value?.toString(),
          maxLines: 5,
          onChanged: onChanged,
          decoration: const InputDecoration(labelText: 'Jawaban'),
        );
      case TracerQuestionType.dropdown:
        return DropdownButtonFormField<String>(
          initialValue: value is String && question.options.contains(value)
              ? value as String
              : null,
          items: question.options
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(question.optionLabels[option] ?? option),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(labelText: 'Pilih jawaban'),
        );
      case TracerQuestionType.radio:
      case TracerQuestionType.singleChoice:
        return Column(
          children: question.options
              .map(
                (option) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    value == option
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: value == option ? AppColors.maroon : null,
                  ),
                  title: Text(question.optionLabels[option] ?? option),
                  onTap: () => onChanged(option),
                ),
              )
              .toList(),
        );
      case TracerQuestionType.checkbox:
      case TracerQuestionType.multipleChoice:
        final selected = value is List
            ? List<String>.from(value as List)
            : <String>[];
        return Column(
          children: question.options
              .map(
                (option) => CheckboxListTile(
                  value: selected.contains(option),
                  onChanged: (checked) {
                    final next = [...selected];
                    if (checked == true) {
                      next.add(option);
                    } else {
                      next.remove(option);
                    }
                    onChanged(next);
                  },
                  title: Text(option),
                ),
              )
              .toList(),
        );
      case TracerQuestionType.date:
        return OutlinedButton.icon(
          onPressed: () async {
            final selected = await showDatePicker(
              context: context,
              firstDate: DateTime(1970),
              lastDate: DateTime(2100),
              initialDate: DateTime.now(),
            );
            if (selected != null) {
              onChanged(selected.toIso8601String().split('T').first);
            }
          },
          icon: const Icon(Icons.calendar_month_rounded),
          label: Text(
            value?.toString().isNotEmpty == true
                ? value.toString()
                : 'Pilih tanggal',
          ),
        );
      case TracerQuestionType.file:
      case TracerQuestionType.unknown:
        return const StatusCard(
          title: 'Tipe pertanyaan belum didukung',
          description:
              'Tipe pertanyaan ini perlu disesuaikan dengan kontrak SIMAWA-GS.',
          icon: Icons.info_rounded,
          accentColor: AppColors.gold,
        );
    }
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
