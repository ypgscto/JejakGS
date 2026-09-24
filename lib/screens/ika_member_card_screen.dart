import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_shadows.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
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
          _IkaDigitalMemberCard(card: _card!),
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
        _errorMessage =
            response.message ??
            'Kartu anggota hanya tersedia untuk anggota IKA aktif.';
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

class _IkaDigitalMemberCard extends StatelessWidget {
  const _IkaDigitalMemberCard({required this.card});

  final IkaMemberCard card;

  @override
  Widget build(BuildContext context) {
    final status = card.memberStatusLabel ?? card.memberStatus ?? '-';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkMaroon, AppColors.maroon],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/stikes_gunung_sari.png',
                width: 62,
                height: 62,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kartu Anggota IKA',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'STIKES Gunung Sari',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(label: status),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.alumniName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _InfoGrid(card: card, status: status),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              _QrBox(qrValue: card.qrValue, qrCodeUrl: card.qrCodeUrl),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.card, required this.status});

  final IkaMemberCard card;
  final String status;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('NIM', card.nim),
      ('Prodi', card.programStudy),
      ('Angkatan', _year(card.batchYear)),
      ('Tahun lulus', _year(card.graduationYear)),
      ('Nomor anggota IKA', card.memberNumber),
      ('Status anggota', status),
      ('Tanggal bergabung', _date(card.joinedAt)),
    ];

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final item in items)
          SizedBox(
            width: 150,
            child: _InfoItem(label: item.$1, value: item.$2),
          ),
      ],
    );
  }

  String _year(int value) => value <= 0 ? '-' : value.toString();

  String _date(DateTime? value) {
    return value?.toLocal().toString().split(' ').first ?? '-';
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.68),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.trim().isEmpty ? '-' : value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.darkMaroon,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _QrBox extends StatelessWidget {
  const _QrBox({required this.qrValue, required this.qrCodeUrl});

  final String? qrValue;
  final String? qrCodeUrl;

  @override
  Widget build(BuildContext context) {
    final value = qrValue?.trim();
    final url = qrCodeUrl?.trim();

    return Container(
      width: 92,
      height: 92,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: value != null && value.isNotEmpty
          ? QrImageView(data: value, padding: EdgeInsets.zero)
          : url != null && url.isNotEmpty
          ? Image.network(url, fit: BoxFit.contain)
          : Center(
              child: Text(
                'QR belum tersedia',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
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
