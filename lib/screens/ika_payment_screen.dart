import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

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
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _items = const [];

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
    return _SimpleIkaList(
      title: 'Iuran/Donasi',
      onBack: widget.onBack,
      emptyTitle: 'Belum ada data iuran/donasi',
      items: _items,
      icon: Icons.payments_rounded,
    );
  }

  Future<void> _load() async {
    final response = await widget.appState.ikaService.getPayments();
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _items = response.data ?? const [];
      } else {
        _errorMessage = response.message ?? 'Data iuran/donasi belum tersedia.';
      }
    });
  }
}

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
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _items = const [];

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
    return _SimpleIkaList(
      title: 'Voting/Musyawarah',
      onBack: widget.onBack,
      emptyTitle: 'Belum ada agenda voting',
      items: _items,
      icon: Icons.how_to_vote_rounded,
    );
  }

  Future<void> _load() async {
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
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingState(message: 'Memuat forum IKA...');
    if (_errorMessage != null) {
      return ErrorState(
        title: 'Forum belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }
    return _SimpleIkaList(
      title: widget.boardOnly ? 'Forum Pengurus' : 'Forum Anggota',
      onBack: widget.onBack,
      emptyTitle: 'Belum ada topik forum',
      items: _items,
      icon: Icons.forum_rounded,
    );
  }

  Future<void> _load() async {
    final response = await widget.appState.ikaService.getForumTopics(
      boardOnly: widget.boardOnly,
    );
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _items = response.data ?? const [];
      } else {
        _errorMessage = response.message ?? 'Forum belum tersedia.';
      }
    });
  }
}

class _SimpleIkaList extends StatelessWidget {
  const _SimpleIkaList({
    required this.title,
    required this.onBack,
    required this.emptyTitle,
    required this.items,
    required this.icon,
  });

  final String title;
  final VoidCallback onBack;
  final String emptyTitle;
  final List<Map<String, dynamic>> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        if (items.isEmpty)
          EmptyState(
            icon: icon,
            title: emptyTitle,
            description: 'Data akan ditampilkan dari SIMAWA-GS saat tersedia.',
          )
        else
          for (final item in items) ...[
            StatusCard(
              title:
                  item['title']?.toString() ??
                  item['name']?.toString() ??
                  title,
              description:
                  item['description']?.toString() ??
                  item['status']?.toString() ??
                  'Data dari SIMAWA-GS.',
              icon: icon,
              accentColor: AppColors.maroon,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }
}
