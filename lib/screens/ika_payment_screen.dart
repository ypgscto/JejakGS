import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../forum/forum_safety.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_shadows.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

enum _IkaPaymentPage { list, detail, uploadProof, history }

class IkaPaymentScreen extends StatefulWidget {
  const IkaPaymentScreen({
    required this.appState,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;

  @override
  State<IkaPaymentScreen> createState() => _IkaPaymentScreenState();
}

class _IkaPaymentScreenState extends State<IkaPaymentScreen> {
  _IkaPaymentPage _page = _IkaPaymentPage.list;
  IkaPaymentItem? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      _IkaPaymentPage.list => IkaPaymentListScreen(
        appState: widget.appState,
        onBack: widget.onBack,
        onOpenDetail: _openDetail,
        onOpenHistory: _openHistory,
      ),
      _IkaPaymentPage.detail => IkaPaymentDetailScreen(
        appState: widget.appState,
        item: _selectedItem!,
        onBack: _backToList,
        onUploadProof: _openUploadProof,
      ),
      _IkaPaymentPage.uploadProof => IkaUploadPaymentProofScreen(
        appState: widget.appState,
        item: _selectedItem!,
        onBack: _backToDetail,
        onUploaded: _openDetail,
      ),
      _IkaPaymentPage.history => IkaPaymentHistoryScreen(
        appState: widget.appState,
        onBack: _backToList,
      ),
    };
  }

  void _openDetail(IkaPaymentItem item) {
    setState(() {
      _selectedItem = item;
      _page = _IkaPaymentPage.detail;
    });
  }

  void _openUploadProof(IkaPaymentItem item) {
    setState(() {
      _selectedItem = item;
      _page = _IkaPaymentPage.uploadProof;
    });
  }

  void _openHistory() {
    setState(() => _page = _IkaPaymentPage.history);
  }

  void _backToList() {
    setState(() {
      _selectedItem = null;
      _page = _IkaPaymentPage.list;
    });
  }

  void _backToDetail() {
    setState(() => _page = _IkaPaymentPage.detail);
  }
}

class IkaPaymentListScreen extends StatefulWidget {
  const IkaPaymentListScreen({
    required this.appState,
    required this.onBack,
    required this.onOpenDetail,
    required this.onOpenHistory,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;
  final ValueChanged<IkaPaymentItem> onOpenDetail;
  final VoidCallback onOpenHistory;

  @override
  State<IkaPaymentListScreen> createState() => _IkaPaymentListScreenState();
}

class _IkaPaymentListScreenState extends State<IkaPaymentListScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  IkaPaymentOverview _overview = const IkaPaymentOverview();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'Memuat iuran/donasi...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: 'Iuran/donasi belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Iuran/Donasi', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.lg),
        SecondaryButton(
          label: 'Riwayat Pembayaran',
          icon: Icons.history_rounded,
          fullWidth: true,
          onPressed: widget.onOpenHistory,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (_overview.items.isEmpty)
          const EmptyState(
            icon: Icons.payments_rounded,
            title: 'Belum ada iuran/donasi',
            description: 'Data iuran/donasi akan ditampilkan dari SIMAWA-GS.',
          )
        else
          for (final item in _overview.items) ...[
            _PaymentItemCard(
              item: item,
              onTap: () => widget.onOpenDetail(item),
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

    final response = await widget.appState.ikaService.getPayments();
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _overview = response.data ?? const IkaPaymentOverview();
      } else {
        _errorMessage = response.message ?? 'Data iuran/donasi belum tersedia.';
      }
    });
  }
}

class IkaPaymentDetailScreen extends StatefulWidget {
  const IkaPaymentDetailScreen({
    required this.appState,
    required this.item,
    required this.onBack,
    required this.onUploadProof,
    super.key,
  });

  final AppState appState;
  final IkaPaymentItem item;
  final VoidCallback onBack;
  final ValueChanged<IkaPaymentItem> onUploadProof;

  @override
  State<IkaPaymentDetailScreen> createState() => _IkaPaymentDetailScreenState();
}

class _IkaPaymentDetailScreenState extends State<IkaPaymentDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  IkaPaymentItem? _item;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'Memuat detail pembayaran...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: 'Detail pembayaran belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    final item = _item ?? widget.item;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Detail Iuran/Donasi', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        AppHeader(
          title: item.title,
          subtitle: item.typeLabel ?? 'Iuran/Donasi IKA',
          leadingIcon: Icons.payments_rounded,
        ),
        const SizedBox(height: AppSpacing.xl),
        _PaymentDetailPanel(item: item),
        if (item.description != null &&
            item.description!.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          StatusCard(
            title: 'Deskripsi',
            description: item.description!,
            icon: Icons.notes_rounded,
            accentColor: AppColors.maroon,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        _PaymentInstructions(instructions: item.instructions),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'Upload Bukti Pembayaran',
          icon: Icons.upload_file_rounded,
          fullWidth: true,
          onPressed: _canUploadProof(item)
              ? () => widget.onUploadProof(item)
              : null,
        ),
      ],
    );
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await widget.appState.ikaService.getPaymentDetail(
      widget.item.id,
    );
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _item = response.data;
      } else {
        _errorMessage = response.message ?? 'Detail pembayaran belum tersedia.';
      }
    });
  }
}

class IkaUploadPaymentProofScreen extends StatefulWidget {
  const IkaUploadPaymentProofScreen({
    required this.appState,
    required this.item,
    required this.onBack,
    required this.onUploaded,
    super.key,
  });

  final AppState appState;
  final IkaPaymentItem item;
  final VoidCallback onBack;
  final ValueChanged<IkaPaymentItem> onUploaded;

  @override
  State<IkaUploadPaymentProofScreen> createState() =>
      _IkaUploadPaymentProofScreenState();
}

class _IkaUploadPaymentProofScreenState
    extends State<IkaUploadPaymentProofScreen> {
  final _amountController = TextEditingController();
  final _methodController = TextEditingController();
  final _noteController = TextEditingController();
  final _picker = ImagePicker();
  XFile? _proofFile;
  bool _isSubmitting = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.item.amount.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _methodController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Upload Bukti Pembayaran', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        StatusCard(
          title: widget.item.title,
          description:
              'Nominal: ${_currency(widget.item.amount)}\nStatus: ${_statusLabel(widget.item.paymentStatus, widget.item.paymentStatusLabel)}',
          icon: Icons.receipt_long_rounded,
          accentColor: AppColors.maroon,
        ),
        const SizedBox(height: AppSpacing.xl),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Nominal dibayar'),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _methodController,
          decoration: const InputDecoration(
            labelText: 'Metode pembayaran',
            hintText: 'Contoh: Transfer BRI',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Catatan pembayaran'),
        ),
        const SizedBox(height: AppSpacing.xl),
        _ProofPickerTile(file: _proofFile, onPick: _pickProof),
        if (_message != null) ...[
          const SizedBox(height: AppSpacing.md),
          StatusCard(
            title: 'Status upload',
            description: _message!,
            icon: Icons.info_rounded,
            accentColor: AppColors.gold,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'Kirim Bukti Pembayaran',
          icon: Icons.send_rounded,
          fullWidth: true,
          isLoading: _isSubmitting,
          onPressed: _submit,
        ),
      ],
    );
  }

  Future<void> _pickProof() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() => _proofFile = file);
  }

  Future<void> _submit() async {
    final file = _proofFile;
    if (file == null) {
      setState(() => _message = 'Pilih bukti pembayaran terlebih dahulu.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    final response = await widget.appState.ikaService.uploadPaymentProof(
      id: widget.item.id,
      bytes: await file.readAsBytes(),
      fileName: file.name,
      fields: {
        if (_amountController.text.trim().isNotEmpty)
          'amount': _amountController.text.trim(),
        if (_methodController.text.trim().isNotEmpty)
          'payment_method': _methodController.text.trim(),
        if (_noteController.text.trim().isNotEmpty)
          'payment_note': _noteController.text.trim(),
      },
    );

    if (!mounted) return;

    if (response.isSuccess) {
      final detailResponse = await widget.appState.ikaService.getPaymentDetail(
        widget.item.id,
      );
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _message =
            response.message ??
            'Bukti pembayaran berhasil dikirim dan menunggu verifikasi.';
      });
      widget.onUploaded(detailResponse.data ?? widget.item);
      return;
    }

    setState(() {
      _isSubmitting = false;
      _message = response.message ?? 'Bukti pembayaran belum dapat dikirim.';
    });
  }
}

class IkaPaymentHistoryScreen extends StatefulWidget {
  const IkaPaymentHistoryScreen({
    required this.appState,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;

  @override
  State<IkaPaymentHistoryScreen> createState() =>
      _IkaPaymentHistoryScreenState();
}

class _IkaPaymentHistoryScreenState extends State<IkaPaymentHistoryScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<IkaPaymentRecord> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'Memuat riwayat pembayaran...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: 'Riwayat belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Riwayat Pembayaran', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        if (_items.isEmpty)
          const EmptyState(
            icon: Icons.history_rounded,
            title: 'Belum ada riwayat pembayaran',
            description:
                'Riwayat akan tampil setelah bukti pembayaran dikirim.',
          )
        else
          for (final item in _items) ...[
            _PaymentHistoryCard(record: item),
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

    final response = await widget.appState.ikaService.getPaymentHistory();
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _items = response.data ?? const [];
      } else {
        _errorMessage =
            response.message ?? 'Riwayat pembayaran belum tersedia.';
      }
    });
  }
}

enum _IkaVotingPage { list, detail, result }

class IkaVotingScreen extends StatefulWidget {
  const IkaVotingScreen({
    required this.appState,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;

  @override
  State<IkaVotingScreen> createState() => _IkaVotingScreenState();
}

class _IkaVotingScreenState extends State<IkaVotingScreen> {
  _IkaVotingPage _page = _IkaVotingPage.list;
  IkaVoting? _selectedVoting;
  IkaVotingResult? _selectedResult;

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      _IkaVotingPage.list => IkaVotingListScreen(
        appState: widget.appState,
        onBack: widget.onBack,
        onOpenDetail: _openDetail,
      ),
      _IkaVotingPage.detail => IkaVotingDetailScreen(
        appState: widget.appState,
        voting: _selectedVoting!,
        onBack: _backToList,
        onOpenResult: _openResult,
      ),
      _IkaVotingPage.result => IkaVotingResultScreen(
        appState: widget.appState,
        voting: _selectedVoting!,
        initialResult: _selectedResult,
        onBack: _backToDetail,
      ),
    };
  }

  void _openDetail(IkaVoting voting) {
    setState(() {
      _selectedVoting = voting;
      _selectedResult = null;
      _page = _IkaVotingPage.detail;
    });
  }

  void _openResult(IkaVoting voting, IkaVotingResult? result) {
    setState(() {
      _selectedVoting = voting;
      _selectedResult = result;
      _page = _IkaVotingPage.result;
    });
  }

  void _backToList() {
    setState(() {
      _selectedVoting = null;
      _selectedResult = null;
      _page = _IkaVotingPage.list;
    });
  }

  void _backToDetail() {
    setState(() {
      _selectedResult = null;
      _page = _IkaVotingPage.detail;
    });
  }
}

class IkaVotingListScreen extends StatefulWidget {
  const IkaVotingListScreen({
    required this.appState,
    required this.onBack,
    required this.onOpenDetail,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;
  final ValueChanged<IkaVoting> onOpenDetail;

  @override
  State<IkaVotingListScreen> createState() => _IkaVotingListScreenState();
}

class _IkaVotingListScreenState extends State<IkaVotingListScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<IkaVoting> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingState(message: 'Memuat voting IKA...');
    if (_errorMessage != null) {
      return ErrorState(
        title: 'Voting belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Voting', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        if (_items.isEmpty)
          const EmptyState(
            icon: Icons.how_to_vote_rounded,
            title: 'Belum ada voting aktif',
            description: 'Voting IKA akan ditampilkan dari SIMAWA-GS.',
          )
        else
          for (final item in _items) ...[
            _VotingCard(voting: item, onTap: () => widget.onOpenDetail(item)),
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

    final response = await widget.appState.ikaService.getVotingItems();
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _items = response.data ?? const [];
      } else {
        _errorMessage = response.message ?? 'Voting belum tersedia.';
      }
    });
  }
}

class IkaVotingDetailScreen extends StatefulWidget {
  const IkaVotingDetailScreen({
    required this.appState,
    required this.voting,
    required this.onBack,
    required this.onOpenResult,
    super.key,
  });

  final AppState appState;
  final IkaVoting voting;
  final VoidCallback onBack;
  final void Function(IkaVoting voting, IkaVotingResult? result) onOpenResult;

  @override
  State<IkaVotingDetailScreen> createState() => _IkaVotingDetailScreenState();
}

class _IkaVotingDetailScreenState extends State<IkaVotingDetailScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _message;
  IkaVoting? _voting;
  String? _selectedOptionId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'Memuat detail voting...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: 'Detail voting belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    final voting = _voting ?? widget.voting;
    final canSubmitVote = voting.canSubmitVote;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Detail Voting', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        AppHeader(
          title: voting.title,
          subtitle: voting.targetRoleLabel ?? 'Voting IKA',
          leadingIcon: Icons.how_to_vote_rounded,
        ),
        const SizedBox(height: AppSpacing.xl),
        _VotingDetailPanel(voting: voting),
        if (voting.description != null &&
            voting.description!.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          StatusCard(
            title: 'Deskripsi',
            description: voting.description!,
            icon: Icons.notes_rounded,
            accentColor: AppColors.maroon,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        if (voting.hasVoted)
          StatusCard(
            title: 'Suara sudah tersimpan',
            description: 'Anda sudah memberikan suara pada voting ini.',
            icon: Icons.check_circle_rounded,
            accentColor: AppColors.success,
          )
        else
          for (final option in voting.options) ...[
            _VotingOptionTile(
              option: option,
              selected: _selectedOptionId == option.id,
              onTap: canSubmitVote
                  ? () => setState(() => _selectedOptionId = option.id)
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        if (_message != null) ...[
          const SizedBox(height: AppSpacing.md),
          StatusCard(
            title: 'Status voting',
            description: _message!,
            icon: Icons.info_rounded,
            accentColor: AppColors.gold,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: voting.hasVoted ? 'Sudah Voting' : 'Submit Suara',
          icon: voting.hasVoted ? Icons.check_rounded : Icons.send_rounded,
          fullWidth: true,
          isLoading: _isSubmitting,
          onPressed: canSubmitVote ? _submitVote : null,
        ),
        if (voting.results != null ||
            voting.hasVoted ||
            voting.status == 'closed') ...[
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: 'Lihat Hasil',
            icon: Icons.bar_chart_rounded,
            fullWidth: true,
            onPressed: () => widget.onOpenResult(voting, voting.results),
          ),
        ],
      ],
    );
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await widget.appState.ikaService.getVotingDetail(
      widget.voting.id,
    );
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _voting = response.data;
        _selectedOptionId = response.data?.selectedOptionId;
      } else {
        _errorMessage = response.message ?? 'Detail voting belum tersedia.';
      }
    });
  }

  Future<void> _submitVote() async {
    final voting = _voting ?? widget.voting;
    final optionId = _selectedOptionId;
    if (optionId == null || optionId.isEmpty) {
      setState(() => _message = 'Pilih salah satu opsi terlebih dahulu.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    final response = await widget.appState.ikaService.submitVote(
      id: voting.id,
      optionId: optionId,
    );
    if (!mounted) return;

    if (response.isSuccess) {
      final detailResponse = await widget.appState.ikaService.getVotingDetail(
        voting.id,
      );
      if (!mounted) return;

      final refreshed = detailResponse.data ?? voting;
      setState(() {
        _isSubmitting = false;
        _voting = refreshed;
        _message = response.message ?? 'Suara berhasil disimpan.';
      });

      if (response.data?.results != null) {
        widget.onOpenResult(refreshed, response.data!.results);
      }
      return;
    }

    setState(() {
      _isSubmitting = false;
      _message = response.message ?? 'Suara belum dapat disimpan.';
    });
  }
}

class IkaVotingResultScreen extends StatefulWidget {
  const IkaVotingResultScreen({
    required this.appState,
    required this.voting,
    required this.onBack,
    this.initialResult,
    super.key,
  });

  final AppState appState;
  final IkaVoting voting;
  final IkaVotingResult? initialResult;
  final VoidCallback onBack;

  @override
  State<IkaVotingResultScreen> createState() => _IkaVotingResultScreenState();
}

class _IkaVotingResultScreenState extends State<IkaVotingResultScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  IkaVotingResult? _result;

  @override
  void initState() {
    super.initState();
    _result = widget.initialResult;
    if (_result != null) {
      _isLoading = false;
    } else {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'Memuat hasil voting...');
    }
    if (_errorMessage != null) {
      return ErrorState(
        title: 'Hasil voting belum tersedia',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    final result = _result;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Hasil Voting', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        if (result == null)
          const EmptyState(
            icon: Icons.bar_chart_rounded,
            title: 'Hasil belum tersedia',
            description: 'Hasil voting akan tampil jika diizinkan backend.',
          )
        else ...[
          StatusCard(
            title: widget.voting.title,
            description: 'Total suara: ${result.totalVotes}',
            icon: Icons.bar_chart_rounded,
            accentColor: AppColors.maroon,
          ),
          const SizedBox(height: AppSpacing.xl),
          for (final option in result.options) ...[
            _VotingResultBar(option: option),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ],
    );
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await widget.appState.ikaService.getVotingResults(
      widget.voting.id,
    );
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _result = response.data;
      } else {
        _errorMessage =
            response.message ?? 'Hasil voting belum diizinkan backend.';
      }
    });
  }
}

class _VotingCard extends StatelessWidget {
  const _VotingCard({required this.voting, required this.onTap});

  final IkaVoting voting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.mediumGrey),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.maroon, AppColors.darkMaroon],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(
                  Icons.how_to_vote_rounded,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voting.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${_date(voting.startAt)} - ${_date(voting.endAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      voting.hasVoted
                          ? 'Anda sudah memberikan suara'
                          : voting.canVote
                          ? 'Voting aktif'
                          : voting.statusLabel ?? voting.status,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _VotingStatusBadge(voting: voting),
            ],
          ),
        ),
      ),
    );
  }
}

class _VotingDetailPanel extends StatelessWidget {
  const _VotingDetailPanel({required this.voting});

  final IkaVoting voting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.mediumGrey),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          _DetailRow(
            label: 'Status',
            value: voting.statusLabel ?? voting.status,
          ),
          _DetailRow(label: 'Target', value: voting.targetRoleLabel),
          _DetailRow(label: 'Mulai', value: _date(voting.startAt)),
          _DetailRow(label: 'Selesai', value: _date(voting.endAt)),
          _DetailRow(
            label: 'Status suara',
            value: voting.hasVoted ? 'Sudah voting' : 'Belum voting',
          ),
        ],
      ),
    );
  }
}

class _VotingOptionTile extends StatelessWidget {
  const _VotingOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final IkaVotingOption option;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected ? AppColors.softGold : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.mediumGrey,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.maroon : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (option.description != null &&
                      option.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      option.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VotingResultBar extends StatelessWidget {
  const _VotingResultBar({required this.option});

  final IkaVotingResultOption option;

  @override
  Widget build(BuildContext context) {
    final progress = (option.percentage / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.mediumGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  option.text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${option.percentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.maroon,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: AppColors.lightGrey,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${option.votesCount} suara',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _VotingStatusBadge extends StatelessWidget {
  const _VotingStatusBadge({required this.voting});

  final IkaVoting voting;

  @override
  Widget build(BuildContext context) {
    final label = voting.hasVoted
        ? 'Sudah voting'
        : voting.statusLabel ?? voting.status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: voting.hasVoted ? AppColors.softGold : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.maroon,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

enum _IkaForumPage { categories, posts, detail, create }

class IkaForumScreen extends StatefulWidget {
  const IkaForumScreen({
    required this.appState,
    required this.onBack,
    this.boardOnly = false,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;
  final bool boardOnly;

  @override
  State<IkaForumScreen> createState() => _IkaForumScreenState();
}

class _IkaForumScreenState extends State<IkaForumScreen> {
  _IkaForumPage _page = _IkaForumPage.categories;
  IkaForumCategory? _selectedCategory;
  IkaForumPost? _selectedPost;

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      _IkaForumPage.categories => IkaForumCategoryScreen(
        appState: widget.appState,
        onBack: widget.onBack,
        onOpenCategory: _openCategory,
      ),
      _IkaForumPage.posts => IkaForumPostListScreen(
        appState: widget.appState,
        category: _selectedCategory,
        onBack: _backToCategories,
        onOpenPost: _openPost,
        onCreatePost: _openCreate,
      ),
      _IkaForumPage.detail => IkaForumPostDetailScreen(
        appState: widget.appState,
        post: _selectedPost!,
        onBack: _backToPosts,
        onDeleted: _backToPosts,
      ),
      _IkaForumPage.create => IkaForumCreatePostScreen(
        appState: widget.appState,
        category: _selectedCategory,
        onBack: _backToPosts,
        onCreated: _openPost,
      ),
    };
  }

  void _openCategory(IkaForumCategory category) {
    setState(() {
      _selectedCategory = category;
      _selectedPost = null;
      _page = _IkaForumPage.posts;
    });
  }

  void _openPost(IkaForumPost post) {
    setState(() {
      _selectedPost = post;
      _page = _IkaForumPage.detail;
    });
  }

  void _openCreate() {
    setState(() => _page = _IkaForumPage.create);
  }

  void _backToCategories() {
    setState(() {
      _selectedCategory = null;
      _selectedPost = null;
      _page = _IkaForumPage.categories;
    });
  }

  void _backToPosts() {
    setState(() {
      _selectedPost = null;
      _page = _IkaForumPage.posts;
    });
  }
}

class IkaForumCategoryScreen extends StatefulWidget {
  const IkaForumCategoryScreen({
    required this.appState,
    required this.onBack,
    required this.onOpenCategory,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;
  final ValueChanged<IkaForumCategory> onOpenCategory;

  @override
  State<IkaForumCategoryScreen> createState() => _IkaForumCategoryScreenState();
}

class _IkaForumCategoryScreenState extends State<IkaForumCategoryScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<IkaForumCategory> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'Memuat kategori forum...');
    }
    if (_errorMessage != null) {
      return ErrorState(
        title: 'Kategori forum belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Forum Anggota', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => showForumSupportSheet(context, widget.appState),
            icon: const Icon(Icons.support_agent_rounded),
            label: const Text('Bantuan & Pelaporan'),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (_items.isEmpty)
          const EmptyState(
            icon: Icons.forum_rounded,
            title: 'Belum ada kategori forum',
            description: 'Kategori forum akan ditampilkan dari SIMAWA-GS.',
          )
        else
          for (final item in _items) ...[
            _ForumCategoryCard(
              category: item,
              onTap: () => widget.onOpenCategory(item),
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

    final response = await widget.appState.ikaService.getForumCategories();
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _items = response.data ?? const [];
      } else {
        _errorMessage = response.message ?? 'Kategori forum belum tersedia.';
      }
    });
  }
}

class IkaForumPostListScreen extends StatefulWidget {
  const IkaForumPostListScreen({
    required this.appState,
    required this.category,
    required this.onBack,
    required this.onOpenPost,
    required this.onCreatePost,
    super.key,
  });

  final AppState appState;
  final IkaForumCategory? category;
  final VoidCallback onBack;
  final ValueChanged<IkaForumPost> onOpenPost;
  final VoidCallback onCreatePost;

  @override
  State<IkaForumPostListScreen> createState() => _IkaForumPostListScreenState();
}

class _IkaForumPostListScreenState extends State<IkaForumPostListScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<IkaForumPost> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'Memuat postingan forum...');
    }
    if (_errorMessage != null) {
      return ErrorState(
        title: 'Postingan forum belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(
          title: widget.category?.name ?? 'Postingan Forum',
          onBack: widget.onBack,
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Buat Postingan',
          icon: Icons.add_rounded,
          fullWidth: true,
          onPressed: widget.onCreatePost,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (_items.isEmpty)
          const EmptyState(
            icon: Icons.forum_outlined,
            title: 'Belum ada postingan',
            description: 'Jadilah yang pertama membuat postingan.',
          )
        else
          for (final item in _items) ...[
            _ForumPostCard(
              post: item,
              onTap: () => widget.onOpenPost(item),
              onReport: item.isOwner
                  ? null
                  : () => _reportPost(item),
              onBlock: item.isOwner || item.author.id.isEmpty
                  ? null
                  : () => _blockAuthor(item),
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

    final response = await widget.appState.ikaService.getForumPosts(
      categoryId: widget.category?.id,
    );
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _items = response.data ?? const [];
      } else {
        _errorMessage = response.message ?? 'Postingan forum belum tersedia.';
      }
    });
  }

  Future<void> _reportPost(IkaForumPost post) async {
    final sent = await showForumReportSheet(
      context: context,
      title: 'Laporkan Post',
      onSubmit: (reason, description) => widget.appState.ikaService.reportForumPost(
        postId: post.id,
        reason: reason,
        description: description,
      ),
    );
    if (!sent || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terima kasih. Laporan Anda telah dikirim untuk ditinjau.')),
    );
  }

  Future<void> _blockAuthor(IkaForumPost post) async {
    final confirmed = await confirmBlockAlumni(context);
    if (!confirmed || !mounted) return;
    final response = await widget.appState.ikaService.blockForumUser(post.author.id);
    if (!mounted) return;
    if (response.statusCode == 401) {
      await widget.appState.logout();
      return;
    }
    if (response.isSuccess) {
      setState(() {
        _items = _items.where((item) => item.author.id != post.author.id).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alumni berhasil diblokir.')),
      );
      await _load();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(forumActionMessage(response))),
    );
  }
}

class IkaForumPostDetailScreen extends StatefulWidget {
  const IkaForumPostDetailScreen({
    required this.appState,
    required this.post,
    required this.onBack,
    required this.onDeleted,
    super.key,
  });

  final AppState appState;
  final IkaForumPost post;
  final VoidCallback onBack;
  final VoidCallback onDeleted;

  @override
  State<IkaForumPostDetailScreen> createState() =>
      _IkaForumPostDetailScreenState();
}

class _IkaForumPostDetailScreenState extends State<IkaForumPostDetailScreen> {
  bool _isLoading = true;
  bool _isDeleting = false;
  bool _isUnavailable = false;
  bool _isActing = false;
  String? _errorMessage;
  String? _commentError;
  IkaForumPost? _post;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'Memuat detail postingan...');
    }
    if (_isUnavailable) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          _BackTitle(title: 'Detail Postingan', onBack: widget.onBack),
          const SizedBox(height: AppSpacing.xl),
          const EmptyState(
            icon: Icons.hide_source_rounded,
            title: 'Konten ini sudah tidak tersedia.',
            description: 'Kembali ke daftar forum untuk melihat postingan lain.',
          ),
          const SizedBox(height: AppSpacing.lg),
          SecondaryButton(
            label: 'Kembali ke Forum',
            fullWidth: true,
            onPressed: widget.onBack,
          ),
        ],
      );
    }
    if (_errorMessage != null) {
      return ErrorState(
        title: 'Postingan belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    final post = _post ?? widget.post;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Detail Postingan', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        _ForumPostDetailCard(
          post: post,
          onLike: _toggleLike,
          onDelete: post.isOwner && !_isDeleting ? _deletePost : null,
          onReport: post.isOwner || _isActing ? null : () => _reportPost(post),
          onBlock: post.isOwner || post.author.id.isEmpty || _isActing
              ? null
              : () => _blockAuthor(post),
        ),
        const SizedBox(height: AppSpacing.xl),
        IkaForumCommentSection(
          comments: post.comments,
          onSubmit: _addComment,
          errorMessage: _commentError,
          onReport: _isActing ? null : _reportComment,
          onBlock: _isActing ? null : _blockCommentAuthor,
        ),
      ],
    );
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isUnavailable = false;
    });

    final response = await widget.appState.ikaService.getForumPostDetail(
      widget.post.id,
    );
    if (!mounted) return;
    if (response.statusCode == 401) {
      await widget.appState.logout();
      return;
    }
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _post = response.data;
      } else if (response.statusCode == 404) {
        _isUnavailable = true;
      } else {
        _errorMessage = forumActionMessage(response);
      }
    });
  }

  Future<void> _toggleLike() async {
    final post = _post ?? widget.post;
    final response = await widget.appState.ikaService.toggleForumPostLike(
      post.id,
    );
    if (!mounted) return;

    if (response.isSuccess) {
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Like belum dapat diproses.'),
        ),
      );
    }
  }

  Future<void> _addComment(String content) async {
    final post = _post ?? widget.post;
    final response = await widget.appState.ikaService.addForumComment(
      postId: post.id,
      content: content,
    );
    if (!mounted) return;

    if (response.isSuccess) {
      setState(() => _commentError = null);
      await _load();
    } else if (response.statusCode == 401) {
      await widget.appState.logout();
    } else {
      final message = forumActionMessage(response);
      setState(() => _commentError = message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _reportPost(IkaForumPost post) async {
    if (_isActing) return;
    setState(() => _isActing = true);
    final sent = await showForumReportSheet(
      context: context,
      title: 'Laporkan Post',
      onSubmit: (reason, description) => widget.appState.ikaService.reportForumPost(
        postId: post.id,
        reason: reason,
        description: description,
      ),
    );
    if (!mounted) return;
    setState(() => _isActing = false);
    if (!sent) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terima kasih. Laporan Anda telah dikirim untuk ditinjau.')),
    );
  }

  Future<void> _reportComment(IkaForumComment comment) async {
    if (_isActing) return;
    setState(() => _isActing = true);
    final sent = await showForumReportSheet(
      context: context,
      title: 'Laporkan Komentar',
      onSubmit: (reason, description) => widget.appState.ikaService.reportForumComment(
        commentId: comment.id,
        reason: reason,
        description: description,
      ),
    );
    if (!mounted) return;
    setState(() => _isActing = false);
    if (!sent) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terima kasih. Laporan Anda telah dikirim untuk ditinjau.')),
    );
  }

  Future<void> _blockAuthor(IkaForumPost post) async {
    await _blockAlumni(post.author.id);
  }

  Future<void> _blockCommentAuthor(IkaForumComment comment) async {
    await _blockAlumni(comment.author.id);
  }

  Future<void> _blockAlumni(String alumniId) async {
    if (_isActing || alumniId.isEmpty) return;
    final confirmed = await confirmBlockAlumni(context);
    if (!confirmed || !mounted) return;
    setState(() => _isActing = true);
    final response = await widget.appState.ikaService.blockForumUser(alumniId);
    if (!mounted) return;
    setState(() => _isActing = false);
    if (response.statusCode == 401) {
      await widget.appState.logout();
      return;
    }
    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alumni berhasil diblokir.')),
      );
      widget.onDeleted();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(forumActionMessage(response))),
    );
  }

  Future<void> _deletePost() async {
    final post = _post ?? widget.post;
    setState(() => _isDeleting = true);
    final response = await widget.appState.ikaService.deleteForumPost(post.id);
    if (!mounted) return;

    setState(() => _isDeleting = false);
    if (response.isSuccess) {
      widget.onDeleted();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message ?? 'Postingan belum dapat dihapus.'),
        ),
      );
    }
  }
}

class IkaForumCreatePostScreen extends StatefulWidget {
  const IkaForumCreatePostScreen({
    required this.appState,
    required this.category,
    required this.onBack,
    required this.onCreated,
    super.key,
  });

  final AppState appState;
  final IkaForumCategory? category;
  final VoidCallback onBack;
  final ValueChanged<IkaForumPost> onCreated;

  @override
  State<IkaForumCreatePostScreen> createState() =>
      _IkaForumCreatePostScreenState();
}

class _IkaForumCreatePostScreenState extends State<IkaForumCreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;
  String? _message;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Buat Postingan', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        StatusCard(
          title: widget.category?.name ?? 'Forum Anggota',
          description: 'Postingan akan tampil di forum setelah dikirim.',
          icon: Icons.forum_rounded,
          accentColor: AppColors.maroon,
        ),
        const SizedBox(height: AppSpacing.xl),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Judul postingan'),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _contentController,
          maxLines: 6,
          decoration: const InputDecoration(labelText: 'Isi postingan'),
        ),
        if (_message != null) ...[
          const SizedBox(height: AppSpacing.md),
          StatusCard(
            title: 'Postingan belum terkirim',
            description: _message!,
            icon: Icons.info_rounded,
            accentColor: AppColors.gold,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'Kirim Postingan',
          icon: Icons.send_rounded,
          fullWidth: true,
          isLoading: _isSubmitting,
          onPressed: _submit,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final category = widget.category;
    if (category == null) {
      setState(() => _message = 'Pilih kategori forum terlebih dahulu.');
      return;
    }

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      setState(() => _message = 'Judul dan isi postingan wajib diisi.');
      return;
    }

    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _message = null;
    });

    final response = await widget.appState.ikaService.createForumPost(
      categoryId: category.id,
      title: title,
      content: content,
    );
    if (!mounted) return;

    if (response.isSuccess && response.data != null) {
      setState(() => _isSubmitting = false);
      widget.onCreated(response.data!);
      return;
    }

    setState(() {
      _isSubmitting = false;
      _message = forumActionMessage(response);
    });
  }
}

class IkaForumCommentSection extends StatefulWidget {
  const IkaForumCommentSection({
    required this.comments,
    required this.onSubmit,
    this.errorMessage,
    this.onReport,
    this.onBlock,
    super.key,
  });

  final List<IkaForumComment> comments;
  final Future<void> Function(String content) onSubmit;
  final String? errorMessage;
  final Future<void> Function(IkaForumComment comment)? onReport;
  final Future<void> Function(IkaForumComment comment)? onBlock;

  @override
  State<IkaForumCommentSection> createState() => _IkaForumCommentSectionState();
}

class _IkaForumCommentSectionState extends State<IkaForumCommentSection> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Komentar', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _controller,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Tambah komentar'),
        ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: 'Kirim Komentar',
          icon: Icons.comment_rounded,
          isLoading: _isSubmitting,
          fullWidth: true,
          onPressed: _submit,
        ),
        if (widget.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          StatusCard(
            title: 'Komentar belum terkirim',
            description: widget.errorMessage!,
            icon: Icons.info_rounded,
            accentColor: AppColors.gold,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        if (widget.comments.isEmpty)
          const EmptyState(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Belum ada komentar',
            description: 'Komentar anggota akan tampil di sini.',
          )
        else
          for (final comment in widget.comments) ...[
            _ForumCommentCard(
              comment: comment,
              onReport: comment.isOwner ? null : widget.onReport,
              onBlock: comment.isOwner || comment.author.id.isEmpty
                  ? null
                  : widget.onBlock,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    await widget.onSubmit(content);
    if (!mounted) return;

    _controller.clear();
    setState(() => _isSubmitting = false);
  }
}

class _ForumCategoryCard extends StatelessWidget {
  const _ForumCategoryCard({required this.category, required this.onTap});

  final IkaForumCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.mediumGrey),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.maroon, AppColors.darkMaroon],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(Icons.forum_rounded, color: AppColors.gold),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (category.description != null &&
                        category.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        category.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForumPostCard extends StatelessWidget {
  const _ForumPostCard({
    required this.post,
    required this.onTap,
    this.onReport,
    this.onBlock,
  });

  final IkaForumPost post;
  final VoidCallback onTap;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.mediumGrey),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (post.isPinned)
                    const Icon(Icons.push_pin_rounded, color: AppColors.gold),
                  if (onReport != null || onBlock != null)
                    _ForumActionMenu(onReport: onReport, onBlock: onBlock, reportLabel: 'Laporkan Post'),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                post.contentExcerpt ?? post.content ?? '-',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              _ForumMetaRow(post: post),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForumPostDetailCard extends StatelessWidget {
  const _ForumPostDetailCard({
    required this.post,
    required this.onLike,
    required this.onDelete,
    this.onReport,
    this.onBlock,
  });

  final IkaForumPost post;
  final VoidCallback onLike;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.mediumGrey),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(post.title, style: Theme.of(context).textTheme.titleLarge),
              ),
              if (onReport != null || onBlock != null)
                _ForumActionMenu(
                  onReport: onReport,
                  onBlock: onBlock,
                  reportLabel: 'Laporkan Post',
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${post.author.name} • ${_date(post.createdAt)}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(post.content ?? post.contentExcerpt ?? '-'),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: post.isLiked
                      ? 'Disukai (${post.likesCount})'
                      : 'Like (${post.likesCount})',
                  icon: post.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  onPressed: onLike,
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: SecondaryButton(
                    label: 'Hapus',
                    icon: Icons.delete_outline_rounded,
                    onPressed: onDelete,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ForumCommentCard extends StatelessWidget {
  const _ForumCommentCard({
    required this.comment,
    this.onReport,
    this.onBlock,
  });

  final IkaForumComment comment;
  final Future<void> Function(IkaForumComment comment)? onReport;
  final Future<void> Function(IkaForumComment comment)? onBlock;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.mediumGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  comment.author.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (onReport != null || onBlock != null)
                _ForumActionMenu(
                  onReport: onReport == null ? null : () => onReport!(comment),
                  onBlock: onBlock == null ? null : () => onBlock!(comment),
                  reportLabel: 'Laporkan Komentar',
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _date(comment.createdAt),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(comment.content),
        ],
      ),
    );
  }
}

class _ForumActionMenu extends StatelessWidget {
  const _ForumActionMenu({
    required this.reportLabel,
    this.onReport,
    this.onBlock,
  });

  final String reportLabel;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Tindakan',
      onSelected: (value) {
        if (value == 'report') onReport?.call();
        if (value == 'block') onBlock?.call();
      },
      itemBuilder: (context) => [
        if (onReport != null)
          PopupMenuItem(value: 'report', child: Text(reportLabel)),
        if (onBlock != null)
          const PopupMenuItem(value: 'block', child: Text('Blokir Alumni')),
      ],
      icon: const Icon(Icons.more_vert_rounded),
    );
  }
}

class _ForumMetaRow extends StatelessWidget {
  const _ForumMetaRow({required this.post});

  final IkaForumPost post;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        _ForumMeta(icon: Icons.person_rounded, text: post.author.name),
        _ForumMeta(icon: Icons.comment_rounded, text: '${post.commentsCount}'),
        _ForumMeta(icon: Icons.favorite_rounded, text: '${post.likesCount}'),
        _ForumMeta(icon: Icons.schedule_rounded, text: _date(post.createdAt)),
      ],
    );
  }
}

class _ForumMeta extends StatelessWidget {
  const _ForumMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _PaymentItemCard extends StatelessWidget {
  const _PaymentItemCard({required this.item, required this.onTap});

  final IkaPaymentItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.mediumGrey),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.maroon, AppColors.darkMaroon],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: const Icon(
                      Icons.payments_rounded,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          item.typeLabel ?? 'Iuran/Donasi',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _PaymentStatusBadge(
                    status: item.paymentStatus,
                    label: item.paymentStatusLabel,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _MetaLine(
                icon: Icons.attach_money_rounded,
                text: _currency(item.amount),
              ),
              const SizedBox(height: AppSpacing.sm),
              _MetaLine(
                icon: Icons.event_rounded,
                text: 'Deadline: ${_date(item.dueDate)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentDetailPanel extends StatelessWidget {
  const _PaymentDetailPanel({required this.item});

  final IkaPaymentItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.mediumGrey),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          _DetailRow(label: 'Nominal', value: _currency(item.amount)),
          _DetailRow(label: 'Deadline', value: _date(item.dueDate)),
          _DetailRow(
            label: 'Status pembayaran',
            value: _statusLabel(item.paymentStatus, item.paymentStatusLabel),
          ),
          _DetailRow(label: 'Tipe', value: item.typeLabel ?? item.type),
          if (item.payment != null) ...[
            _DetailRow(label: 'Metode', value: item.payment!.paymentMethod),
            _DetailRow(label: 'Catatan', value: item.payment!.paymentNote),
            _DetailRow(label: 'Catatan admin', value: item.payment!.adminNote),
          ],
        ],
      ),
    );
  }
}

class _PaymentInstructions extends StatelessWidget {
  const _PaymentInstructions({required this.instructions});

  final Map<String, dynamic> instructions;

  @override
  Widget build(BuildContext context) {
    final accounts = instructions['bank_accounts'];
    final notes = instructions['notes']?.toString();

    return StatusCard(
      title: 'Instruksi pembayaran',
      description: [
        if (accounts is List && accounts.isNotEmpty)
          for (final account in accounts) _accountText(account),
        if (notes != null && notes.trim().isNotEmpty) notes,
        if ((accounts is! List || accounts.isEmpty) &&
            (notes == null || notes.trim().isEmpty))
          'Instruksi pembayaran belum tersedia dari SIMAWA-GS.',
      ].where((item) => item.trim().isNotEmpty).join('\n'),
      icon: Icons.info_rounded,
      accentColor: AppColors.maroon,
    );
  }

  String _accountText(Object? value) {
    final account = value is Map ? Map<String, dynamic>.from(value) : const {};
    final bank =
        account['bank']?.toString() ?? account['name']?.toString() ?? '';
    final number =
        account['number']?.toString() ??
        account['account_number']?.toString() ??
        '';
    final holder =
        account['holder']?.toString() ??
        account['account_name']?.toString() ??
        '';

    return [
      bank,
      number,
      holder,
    ].where((item) => item.trim().isNotEmpty).join(' - ');
  }
}

class _ProofPickerTile extends StatelessWidget {
  const _ProofPickerTile({required this.file, required this.onPick});

  final XFile? file;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.mediumGrey),
        ),
        child: Row(
          children: [
            const Icon(Icons.upload_file_rounded, color: AppColors.maroon),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                file == null ? 'Pilih bukti pembayaran' : file!.name,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  const _PaymentHistoryCard({required this.record});

  final IkaPaymentRecord record;

  @override
  Widget build(BuildContext context) {
    return StatusCard(
      title: record.title,
      description:
          'Nominal: ${_currency(record.amount)}\nStatus: ${_statusLabel(record.paymentStatus, record.paymentStatusLabel)}\nTanggal: ${_date(record.paidAt)}',
      icon: Icons.receipt_long_rounded,
      accentColor: _statusColor(record.paymentStatus),
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  const _PaymentStatusBadge({required this.status, this.label});

  final String status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor(status).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        _statusLabel(status, label),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _statusColor(status),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value == null || value!.trim().isEmpty ? '-' : value!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
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

bool _canUploadProof(IkaPaymentItem item) {
  return item.paymentStatus == 'unpaid' || item.paymentStatus == 'rejected';
}

String _statusLabel(String status, String? label) {
  if (label != null && label.trim().isNotEmpty) return label;

  return switch (status) {
    'unpaid' => 'Belum bayar',
    'pending_verification' => 'Menunggu verifikasi',
    'paid' => 'Lunas',
    'rejected' => 'Ditolak',
    _ => status,
  };
}

Color _statusColor(String status) {
  return switch (status) {
    'paid' => AppColors.success,
    'pending_verification' => AppColors.gold,
    'rejected' => AppColors.danger,
    _ => AppColors.maroon,
  };
}

String _date(DateTime? value) {
  if (value == null) return '-';

  return value.toLocal().toString().split(' ').first;
}

String _currency(double value) {
  final whole = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    final fromRight = whole.length - i;
    buffer.write(whole[i]);
    if (fromRight > 1 && fromRight % 3 == 1) {
      buffer.write('.');
    }
  }

  return 'Rp ${buffer.toString()}';
}
