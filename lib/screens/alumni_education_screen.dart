import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_spacing.dart';
import '../models/alumni_education.dart';
import '../providers/state/alumni_education_state.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class AlumniEducationScreen extends StatefulWidget {
  const AlumniEducationScreen({
    required this.appState,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;

  @override
  State<AlumniEducationScreen> createState() => _AlumniEducationScreenState();
}

class _AlumniEducationScreenState extends State<AlumniEducationScreen> {
  late final AlumniEducationState _state;
  bool _showForm = false;
  AlumniEducationRequest? _correction;

  @override
  void initState() {
    super.initState();
    _state = AlumniEducationState(
      service: widget.appState.alumniService,
      canAccess: () => widget.appState.canAccessBasicAlumniFeatures,
      onExpiredSession: widget.appState.handleExpiredSession,
    );
    _state.load();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  void _back() {
    if (_state.isSubmitting) return;
    if (_showForm) {
      setState(() => _showForm = false);
    } else {
      widget.onBack();
    }
  }

  void _openForm([AlumniEducationRequest? correction]) {
    _state.submissionError = null;
    _state.fieldErrors = {};
    setState(() {
      _correction = correction;
      _showForm = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_state, widget.appState]),
      builder: (context, _) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _back();
        },
        child: !widget.appState.canAccessBasicAlumniFeatures
            ? ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _heading('Riwayat Pendidikan'),
                  const SizedBox(height: 16),
                  const Text(
                    'Riwayat pendidikan tersedia setelah akun alumni terverifikasi.',
                  ),
                ],
              )
            : _showForm
            ? _EducationRequestForm(
                key: ValueKey(_correction?.id),
                state: _state,
                correction: _correction,
                onBack: _back,
                onSubmitted: () {
                  if (!mounted ||
                      !widget.appState.canAccessBasicAlumniFeatures) {
                    return;
                  }
                  setState(() => _showForm = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Pengajuan terkirim. Tunggu pemeriksaan Bagian Alumni.',
                      ),
                    ),
                  );
                },
              )
            : _overview(),
      ),
    );
  }

  Widget _heading(String title) => Row(
    children: [
      IconButton(
        tooltip: 'Kembali ke Profil',
        onPressed: _state.isSubmitting ? null : _back,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (!_showForm)
        IconButton(
          tooltip: 'Perbarui riwayat',
          onPressed: _state.isLoading ? null : _state.load,
          icon: const Icon(Icons.refresh_rounded),
        ),
    ],
  );

  Widget _overview() {
    final overview = _state.overview;
    return RefreshIndicator(
      onRefresh: _state.load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _heading('Riwayat Pendidikan'),
          const SizedBox(height: 12),
          const Text(
            'Hubungkan pendidikan D3, RPL, atau profesi dalam satu akun. Setiap NIM tambahan diperiksa oleh Bagian Alumni.',
          ),
          const SizedBox(height: 16),
          if (_state.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_state.errorMessage != null)
            ErrorState(
              title: 'Riwayat belum dapat dimuat',
              message: _state.errorMessage!,
              onRetry: _state.load,
            )
          else if (overview != null) ...[
            const SectionTitle(title: 'Pendidikan Terhubung'),
            const SizedBox(height: 10),
            if (overview.educations.isEmpty)
              const Text('Belum ada riwayat pendidikan yang terhubung.')
            else
              for (final education in overview.educations)
                _EducationCard(education: education),
            const SizedBox(height: 8),
            _EducationActionButton(
              label: 'Tambahkan Riwayat Pendidikan',
              icon: Icons.add_rounded,
              onPressed: _openForm,
            ),
            const SizedBox(height: 12),
            Text(
              'Pendidikan utama tetap menjadi acuan layanan akun Anda. Riwayat tambahan tidak membuat keanggotaan IKA baru.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'Riwayat Pengajuan'),
            const SizedBox(height: 10),
            if (overview.requests.isEmpty)
              const Text('Belum ada pengajuan pendidikan tambahan.')
            else
              for (final request in overview.requests.reversed)
                _EducationRequestCard(
                  request: request,
                  onResubmit: request.status.canResubmit
                      ? () => _openForm(request)
                      : null,
                ),
          ],
        ],
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard({required this.education});

  final AlumniEducation education;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.school_rounded, color: AppColors.maroon),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  education.studyProgram.isEmpty
                      ? 'Program studi belum tersedia'
                      : education.studyProgram,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('NIM ${education.nim}'),
          if (education.alumniNumber != null)
            Text('No. Alumni ${education.alumniNumber}'),
          Text(
            'Angkatan ${education.cohortYear ?? '—'} • Lulus ${education.graduationYear ?? '—'}',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (education.isPrimary)
                const _EducationBadge(
                  label: 'Pendidikan utama',
                  color: AppColors.maroon,
                ),
              _EducationBadge(
                label: education.isActive
                    ? education.verificationStatus.label
                    : 'Riwayat nonaktif',
                color: education.isActive
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _EducationRequestCard extends StatelessWidget {
  const _EducationRequestCard({required this.request, this.onResubmit});

  final AlumniEducationRequest request;
  final VoidCallback? onResubmit;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NIM ${request.nim}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          _EducationBadge(
            label: request.status.label,
            color: switch (request.status) {
              EducationRequestStatus.verified => AppColors.success,
              EducationRequestStatus.declined => AppColors.danger,
              _ => AppColors.maroon,
            },
          ),
          if (request.reviewNote != null) ...[
            const SizedBox(height: 10),
            Text(
              'Catatan Bagian Alumni',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(request.reviewNote!),
          ],
          if (onResubmit != null) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              label: const Text('Perbaiki & Kirim Ulang'),
              icon: const Icon(Icons.edit_note_rounded),
              onPressed: onResubmit,
            ),
          ],
        ],
      ),
    ),
  );
}

class _EducationBadge extends StatelessWidget {
  const _EducationBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
    ),
  );
}

class _EducationActionButton extends StatelessWidget {
  const _EducationActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
      icon: isLoading
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.white,
              ),
            )
          : Icon(icon, size: 18),
      label: Text(label, textAlign: TextAlign.center),
    ),
  );
}

class _EducationRequestForm extends StatefulWidget {
  const _EducationRequestForm({
    required this.state,
    required this.onBack,
    required this.onSubmitted,
    this.correction,
    super.key,
  });

  final AlumniEducationState state;
  final AlumniEducationRequest? correction;
  final VoidCallback onBack;
  final VoidCallback onSubmitted;

  @override
  State<_EducationRequestForm> createState() => _EducationRequestFormState();
}

class _EducationRequestFormState extends State<_EducationRequestForm> {
  late final TextEditingController _nim;
  late final TextEditingController _note;
  List<int>? _diplomaBytes;
  String? _fileName;
  String? _fileError;
  bool _confirmed = false;
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _nim = TextEditingController(text: widget.correction?.nim);
    _note = TextEditingController(text: widget.correction?.ownershipNote);
  }

  @override
  void dispose() {
    _nim.dispose();
    _note.dispose();
    _diplomaBytes = null;
    super.dispose();
  }

  Future<void> _pickDiploma() async {
    if (_isPicking || widget.state.isSubmitting) return;
    setState(() => _isPicking = true);
    try {
      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (file == null || !mounted) return;
      if (await file.length() > 5 * 1024 * 1024) {
        if (mounted) {
          setState(() => _fileError = 'Ukuran foto ijazah maksimal 5 MB.');
        }
        return;
      }
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (!AlumniEducationState.isValidDiploma(bytes, file.name)) {
        setState(
          () => _fileError = 'Pilih foto ijazah dalam format JPG/JPEG/PNG.',
        );
        return;
      }
      setState(() {
        _diplomaBytes = bytes;
        _fileName = file.name;
        _fileError = null;
      });
    } on Object {
      if (mounted) {
        setState(
          () => _fileError =
              'Foto belum dapat dipilih. Periksa izin akses foto dan coba lagi.',
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _submit() async {
    if (!_confirmed || _isPicking || widget.state.isSubmitting) return;
    final success = await widget.state.submit(
      nim: _nim.text,
      ownershipNote: _note.text,
      diplomaBytes: _diplomaBytes ?? const [],
      diplomaFileName: _fileName ?? '',
    );
    if (mounted && success) widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    final busy = widget.state.isSubmitting;
    final errors = widget.state.fieldErrors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: busy ? null : widget.onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                widget.correction == null
                    ? 'Tambah Pendidikan'
                    : 'Perbaiki Pengajuan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Masukkan NIM pendidikan tambahan. Program studi, angkatan, dan tahun lulus dicocokkan dengan SIAKAD oleh Bagian Alumni.',
        ),
        if (widget.correction?.reviewNote != null) ...[
          const SizedBox(height: 12),
          StatusCard(
            title: 'Catatan Bagian Alumni',
            description: widget.correction!.reviewNote!,
            icon: Icons.edit_note_rounded,
            accentColor: AppColors.gold,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        CustomTextField(
          label: 'NIM Pendidikan Tambahan',
          controller: _nim,
          enabled: !busy && widget.correction == null,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.badge_outlined,
          errorText: errors['nim'],
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomTextField(
          label: 'Penjelasan Kepemilikan',
          controller: _note,
          helperText:
              'Jelaskan hubungan pendidikan Anda dalam 20–2000 karakter.',
          enabled: !busy,
          maxLines: 4,
          errorText: errors['ownership_note'],
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: busy || _isPicking ? null : _pickDiploma,
          icon: const Icon(Icons.upload_file_rounded),
          label: Text(_isPicking ? 'Memilih foto…' : 'Pilih Foto Ijazah'),
        ),
        const SizedBox(height: 8),
        Text(
          _fileName ??
              'JPG/JPEG/PNG, maksimal 5 MB. Pilih bukti terbaru saat mengajukan ulang.',
        ),
        if (_fileError != null || errors['diploma_photo'] != null)
          Text(
            _fileError ?? errors['diploma_photo']!,
            style: const TextStyle(color: AppColors.danger),
          ),
        const SizedBox(height: 12),
        Text(
          'Foto ijazah hanya untuk pemeriksaan admin. Foto ini tidak ditampilkan di profil publik, Lacak Teman, atau kartu digital.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _confirmed,
          onChanged: busy
              ? null
              : (value) => setState(() => _confirmed = value ?? false),
          title: const Text(
            'Saya menyatakan NIM dan bukti pendidikan ini milik saya.',
          ),
        ),
        if (widget.state.submissionError != null) ...[
          Text(
            widget.state.submissionError!,
            style: const TextStyle(color: AppColors.danger),
          ),
          const SizedBox(height: 12),
        ],
        _EducationActionButton(
          label: widget.correction == null
              ? 'Kirim Pengajuan'
              : 'Kirim Pengajuan Ulang',
          icon: Icons.send_rounded,
          isLoading: busy,
          onPressed: _confirmed && !_isPicking && widget.state.canSubmit
              ? _submit
              : null,
        ),
        const SizedBox(height: 10),
        Text(
          'Pengajuan tidak langsung disetujui. Status akun utama dan keanggotaan IKA tetap dipertahankan.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
