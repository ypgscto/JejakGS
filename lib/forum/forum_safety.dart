import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

const forumReportReasons = <(String, String)>[
  ('inappropriate_content', 'Konten tidak pantas'),
  ('harassment', 'Pelecehan'),
  ('spam', 'Spam'),
  ('misinformation', 'Informasi menyesatkan'),
  ('other', 'Lainnya'),
];

String forumActionMessage(ApiResponse<dynamic> response) {
  switch (response.statusCode) {
    case 401:
      return 'Sesi tidak valid atau sudah berakhir. Silakan login kembali.';
    case 403:
      final message = response.message?.trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
      return 'Tindakan ini tidak diizinkan.';
    case 404:
      return 'Konten tidak ditemukan atau sudah tidak tersedia.';
    case 422:
      final message = response.message?.trim() ?? '';
      final normalized = message.toLowerCase();
      if (normalized.contains('menunggu tinjauan') ||
          normalized.contains('sudah pernah')) {
        return 'Konten ini sudah pernah Anda laporkan dan sedang ditinjau.';
      }
      if (message.isNotEmpty) {
        return message;
      }
      return 'Data yang dikirim belum dapat diproses.';
    case 429:
      return 'Anda melakukan terlalu banyak tindakan. Silakan coba beberapa saat lagi.';
    default:
      return 'Tindakan belum berhasil. Periksa koneksi Anda dan coba kembali.';
  }
}

Future<void> applyForumFailure(AppState appState, ApiResponse<dynamic> response) async {
  if (response.statusCode == 401) {
    await appState.logout();
    return;
  }
}

Future<bool> showForumReportSheet({
  required BuildContext context,
  required String title,
  required Future<ApiResponse<Map<String, dynamic>>> Function(
    String reason,
    String? description,
  )
  onSubmit,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ForumReportSheet(title: title, onSubmit: onSubmit),
  ).then((value) => value ?? false);
}

class _ForumReportSheet extends StatefulWidget {
  const _ForumReportSheet({required this.title, required this.onSubmit});

  final String title;
  final Future<ApiResponse<Map<String, dynamic>>> Function(
    String reason,
    String? description,
  )
  onSubmit;

  @override
  State<_ForumReportSheet> createState() => _ForumReportSheetState();
}

class _ForumReportSheetState extends State<_ForumReportSheet> {
  String _reason = 'inappropriate_content';
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          RadioGroup<String>(
            groupValue: _reason,
            onChanged: _isSubmitting
                ? (_) {}
                : (value) {
                    if (value != null) setState(() => _reason = value);
                  },
            child: Column(
              children: [
                for (final reason in forumReportReasons)
                  RadioListTile<String>(
                    value: reason.$1,
                    title: Text(reason.$2),
                  ),
              ],
            ),
          ),
          TextField(
            controller: _descriptionController,
            enabled: !_isSubmitting,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Keterangan tambahan (opsional)',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Kirim Laporan',
            fullWidth: true,
            isLoading: _isSubmitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final description = _descriptionController.text.trim();
    if (_reason == 'other' && description.isEmpty) {
      setState(() => _error = 'Keterangan tambahan wajib diisi untuk alasan Lainnya.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final response = await widget.onSubmit(
      _reason,
      description.isEmpty ? null : description,
    );
    if (!mounted) return;
    if (response.isSuccess) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _isSubmitting = false;
      _error = forumActionMessage(response);
    });
  }
}

Future<bool> confirmBlockAlumni(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Blokir alumni ini?'),
      content: const Text(
        'Post dan komentar dari alumni ini tidak akan ditampilkan kepada Anda. '
        'Alumni tersebut tidak akan diberi tahu bahwa Anda memblokirnya.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Blokir'),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<void> showForumSupportSheet(BuildContext context, AppState appState) async {
  final response = await appState.ikaService.getForumSupport();
  final support = response.isSuccess && response.data != null
      ? response.data!
      : ForumSupportInfo.fallback;
  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bantuan & Pelaporan', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.lg),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Email'),
            subtitle: Text(support.email),
            onTap: () => launchUrl(Uri.parse('mailto:${support.email}')),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Website'),
            subtitle: Text(support.website),
            onTap: () => launchUrl(Uri.parse(support.website)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('WhatsApp'),
            subtitle: Text(support.whatsapp),
            onTap: () => launchUrl(Uri.parse('https://wa.me/628114610095')),
          ),
        ],
      ),
    ),
  );
}

class BlockedForumUsersScreen extends StatefulWidget {
  const BlockedForumUsersScreen({
    required this.appState,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;

  @override
  State<BlockedForumUsersScreen> createState() => _BlockedForumUsersScreenState();
}

class _BlockedForumUsersScreenState extends State<BlockedForumUsersScreen> {
  bool _isLoading = true;
  String? _error;
  List<ForumBlockedUser> _items = const [];
  String? _unblockingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
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
                'Alumni Diblokir',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_isLoading)
          const LoadingState(message: 'Memuat alumni yang diblokir...')
        else if (_error != null)
          ErrorState(
            title: 'Daftar blokir belum dapat dimuat',
            message: _error!,
            onRetry: _load,
          )
        else if (_items.isEmpty)
          const EmptyState(
            icon: Icons.person_off_rounded,
            title: 'Belum ada alumni yang diblokir',
            description: 'Alumni yang Anda blokir di forum akan tampil di sini.',
          )
        else
          for (final item in _items) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.mediumGrey),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                  if (item.programStudy != null)
                    Text(item.programStudy!, style: Theme.of(context).textTheme.bodySmall),
                  if (item.batchYear != null)
                    Text('Angkatan ${item.batchYear}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.md),
                  SecondaryButton(
                    label: _unblockingId == item.alumniId
                        ? 'Membuka blokir...'
                        : 'Buka Blokir',
                    onPressed: _unblockingId == null
                        ? () => _unblock(item)
                        : null,
                  ),
                ],
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
      _error = null;
    });
    final response = await widget.appState.ikaService.getBlockedForumUsers();
    if (!mounted) return;
    if (response.statusCode == 401) {
      await widget.appState.logout();
      return;
    }
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _items = response.data ?? const [];
      } else {
        _error = forumActionMessage(response);
      }
    });
  }

  Future<void> _unblock(ForumBlockedUser item) async {
    if (_unblockingId != null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buka blokir alumni ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Buka Blokir'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _unblockingId = item.alumniId);
    final response = await widget.appState.ikaService.unblockForumUser(item.alumniId);
    if (!mounted) return;
    if (response.statusCode == 401) {
      await widget.appState.logout();
      return;
    }
    setState(() {
      _unblockingId = null;
      if (response.isSuccess) {
        _items = _items.where((user) => user.alumniId != item.alumniId).toList();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response.isSuccess ? 'Blokir berhasil dibuka.' : forumActionMessage(response),
        ),
      ),
    );
  }
}
