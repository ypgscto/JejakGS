import 'package:flutter/material.dart';

import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class IkaEventsScreen extends StatefulWidget {
  const IkaEventsScreen({
    required this.appState,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;

  @override
  State<IkaEventsScreen> createState() => _IkaEventsScreenState();
}

class _IkaEventsScreenState extends State<IkaEventsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<AlumniEvent> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingState(message: 'Memuat event IKA...');
    if (_errorMessage != null) {
      return ErrorState(
        title: 'Event IKA belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Event Khusus Anggota', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        if (_items.isEmpty)
          const EmptyState(
            icon: Icons.event_rounded,
            title: 'Belum ada event IKA',
            description:
                'Event khusus anggota akan ditampilkan dari SIMAWA-GS.',
          )
        else
          for (final item in _items) ...[
            EventCard(
              title: item.title,
              dateLabel: item.startAt.toLocal().toString().split('.').first,
              location: item.location,
              categoryLabel: item.category,
              isOnline: item.isOnline,
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
    final response = await widget.appState.ikaService.getMemberEvents();
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _items = response.data ?? const [];
      } else {
        _errorMessage = response.message ?? 'Event IKA belum tersedia.';
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
