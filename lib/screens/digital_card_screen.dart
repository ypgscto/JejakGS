import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import 'access_blocked_screen.dart';
import '../widgets/design_system/design_system.dart';

enum DigitalCardType { alumni, ika }

class DigitalCardScreen extends StatefulWidget {
  const DigitalCardScreen({
    required this.appState,
    required this.type,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final DigitalCardType type;
  final VoidCallback onBack;

  @override
  State<DigitalCardScreen> createState() => _DigitalCardScreenState();
}

class _DigitalCardScreenState extends State<DigitalCardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  AlumniCard? _alumniCard;
  IkaMemberCard? _ikaCard;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == DigitalCardType.alumni
        ? 'Digital Kartu Alumni'
        : 'Kartu Anggota IKA';
    final feature = widget.type == DigitalCardType.alumni
        ? AlumniFeature.alumniCard
        : AlumniFeature.ikaCard;

    if (!widget.appState.canAccessFeature(feature)) {
      return AccessBlockedScreen(
        title: title,
        message: widget.appState.accessDeniedMessage(feature),
        onBack: widget.onBack,
      );
    }

    if (_isLoading) {
      return LoadingState(message: 'Memuat $title...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: '$title belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    final card = _buildCard();

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
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        if (card == null)
          EmptyState(
            icon: Icons.credit_card_rounded,
            title: '$title belum tersedia',
            description:
                '$title akan ditampilkan setelah data tersedia dari SIMAWA-GS.',
          )
        else
          _CardContentLayout(card: card, onDownload: _showDownloadInfo),
      ],
    );
  }

  Widget? _buildCard() {
    if (widget.type == DigitalCardType.alumni) {
      final card = _alumniCard;
      if (card == null) return null;
      final verificationStatus =
          widget.appState.alumniProfile?.verificationStatus ??
          card.verificationStatus;

      return DigitalCardView(
        title: 'Digital Kartu Alumni',
        name: card.name,
        photoUrl: card.avatarUrl,
        qrData: _alumniNumber(card),
        qrCodeUrl: card.qrCodeUrl,
        badge: verificationStatus.label ?? verificationStatus.state.name,
        fields: {
          'No.Alumni (NIM)': '${_alumniNumber(card)} (${card.nim})',
          'Prodi': card.programStudy,
          'Angkatan': card.batchYear.toString(),
          'Tahun lulus': card.graduationYear.toString(),
        },
      );
    }

    final card = _ikaCard;
    if (card == null) return null;

    return DigitalCardView(
      title: 'Kartu Anggota IKA',
      name: card.alumniName,
      photoUrl: card.avatarUrl,
      qrData: card.qrValue,
      qrCodeUrl: card.qrCodeUrl,
      badge: card.memberStatusLabel ?? card.memberStatus,
      fields: {
        'NIM': card.nim,
        'Prodi': card.programStudy,
        'Angkatan': card.batchYear.toString(),
        'Tahun lulus': card.graduationYear.toString(),
        'Nomor anggota': card.memberNumber,
        'Status anggota': card.memberStatusLabel ?? card.memberStatus ?? '-',
        'Tanggal bergabung': _date(card.joinedAt),
      },
    );
  }

  String _alumniNumber(AlumniCard card) {
    final value = card.alumniNumber?.trim();
    return value == null || value.isEmpty ? '-' : value;
  }

  String _date(DateTime? value) {
    return value?.toLocal().toString().split(' ').first ?? '-';
  }

  Future<void> _load() async {
    final feature = widget.type == DigitalCardType.alumni
        ? AlumniFeature.alumniCard
        : AlumniFeature.ikaCard;
    if (!widget.appState.canAccessFeature(feature)) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (widget.type == DigitalCardType.alumni) {
      final response = await widget.appState.alumniService.getAlumniCard();
      setState(() {
        _isLoading = false;
        if (response.isSuccess) {
          _alumniCard = response.data;
        } else {
          _errorMessage = response.message ?? 'Kartu Alumni belum tersedia.';
        }
      });
      return;
    }

    final response = await widget.appState.ikaService.getMemberCard();
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _ikaCard = response.data;
      } else {
        _errorMessage = response.message ?? 'Kartu IKA belum tersedia.';
      }
    });
  }

  void _showDownloadInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Fitur simpan/download memerlukan integrasi penyimpanan platform. Kartu tetap dapat ditampilkan dari data SIMAWA-GS.',
        ),
        backgroundColor: AppColors.maroon,
      ),
    );
  }
}

class _CardContentLayout extends StatelessWidget {
  const _CardContentLayout({required this.card, required this.onDownload});

  final Widget card;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 760) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: card),
              const SizedBox(width: AppSpacing.lg),
              SizedBox(
                width: 220,
                child: SecondaryButton(
                  label: 'Download',
                  icon: Icons.download_rounded,
                  fullWidth: true,
                  onPressed: onDownload,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            card,
            const SizedBox(height: AppSpacing.xl),
            SecondaryButton(
              label: 'Simpan ke Galeri / Download',
              icon: Icons.download_rounded,
              fullWidth: true,
              onPressed: onDownload,
            ),
          ],
        );
      },
    );
  }
}
