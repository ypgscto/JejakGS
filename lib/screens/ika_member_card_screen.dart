import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import 'access_blocked_screen.dart';
import '../widgets/design_system/design_system.dart';

class IkaMemberCardScreen extends StatefulWidget {
  const IkaMemberCardScreen({
    required this.appState,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;

  @override
  State<IkaMemberCardScreen> createState() => _IkaMemberCardScreenState();
}

class _IkaMemberCardScreenState extends State<IkaMemberCardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  IkaMemberCard? _card;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.appState.canAccessFeature(AlumniFeature.ikaCard)) {
      return AccessBlockedScreen(
        title: 'Kartu Anggota IKA',
        message: widget.appState.accessDeniedMessage(AlumniFeature.ikaCard),
        onBack: widget.onBack,
      );
    }

    if (_isLoading) return const LoadingState(message: 'Memuat kartu IKA...');
    if (_errorMessage != null) {
      return ErrorState(
        title: 'Kartu IKA belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Kartu Anggota IKA', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        if (_card == null)
          const EmptyState(
            icon: Icons.credit_card_rounded,
            title: 'Kartu anggota belum tersedia',
            description:
                'Kartu digital akan ditampilkan dari SIMAWA-GS untuk anggota IKA.',
          )
        else ...[
          DigitalCardView(
            title: 'Kartu Anggota IKA',
            name: _card!.alumniName,
            qrCodeUrl: _card!.qrCodeUrl,
            badge: _card!.memberStatus,
            fields: {
              'NIM': _card!.nim,
              'Prodi': _card!.programStudy,
              'Angkatan': _card!.batchYear.toString(),
              'Nomor anggota': _card!.memberNumber,
              'Status anggota': _card!.memberStatus ?? '-',
              'Jabatan IKA': _card!.ikaPosition ?? '-',
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          SecondaryButton(
            label: 'Simpan ke Galeri / Download',
            icon: Icons.download_rounded,
            fullWidth: true,
            onPressed: _showDownloadInfo,
          ),
        ],
      ],
    );
  }

  Future<void> _load() async {
    if (!widget.appState.canAccessFeature(AlumniFeature.ikaCard)) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final response = await widget.appState.ikaService.getMemberCard();
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _card = response.data;
      } else {
        _errorMessage = response.message ?? 'Kartu anggota belum tersedia.';
      }
    });
  }

  void _showDownloadInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Fitur simpan/download memerlukan integrasi penyimpanan platform.',
        ),
      ),
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
