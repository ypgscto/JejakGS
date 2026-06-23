import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class IkaStatusScreen extends StatefulWidget {
  const IkaStatusScreen({
    required this.appState,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;

  @override
  State<IkaStatusScreen> createState() => _IkaStatusScreenState();
}

class _IkaStatusScreenState extends State<IkaStatusScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  IkaStatus? _status;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingState(message: 'Memuat status IKA...');
    if (_errorMessage != null) {
      return ErrorState(
        title: 'Status IKA belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    final status = _status;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Status Pengajuan IKA', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        if (status == null)
          const EmptyState(
            icon: Icons.groups_outlined,
            title: 'Status IKA belum tersedia',
            description: 'Status IKA akan diambil dari SIMAWA-GS.',
          )
        else ...[
          IkaStatusCard(
            title: status.label ?? status.state.name,
            description:
                status.description ??
                status.revisionNote ??
                status.rejectionReason ??
                'Status mengikuti data SIMAWA-GS.',
            isActiveMember: widget.appState.canAccessIkaMemberFeatures,
          ),
          if (status.revisionNote != null) ...[
            const SizedBox(height: AppSpacing.md),
            StatusCard(
              title: 'Catatan perbaikan',
              description: status.revisionNote!,
              icon: Icons.edit_note_rounded,
              accentColor: AppColors.gold,
            ),
          ],
          if (status.rejectionReason != null) ...[
            const SizedBox(height: AppSpacing.md),
            StatusCard(
              title: 'Alasan ditolak',
              description: status.rejectionReason!,
              icon: Icons.block_rounded,
              accentColor: AppColors.danger,
            ),
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
    final response = await widget.appState.ikaService.getMembershipStatus();
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _status = response.data;
      } else {
        _errorMessage = response.message ?? 'Status IKA belum tersedia.';
      }
    });
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
