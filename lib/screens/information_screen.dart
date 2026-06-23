import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_shadows.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

const informationCategories = [
  'Alumni',
  'IKA',
  'Kampus',
  'Tracer',
  'Karier',
  'Event',
  'Akademik Alumni',
];

class InformationScreen extends StatefulWidget {
  const InformationScreen({
    required this.appState,
    required this.onBack,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  String? _category;
  List<AnnouncementItem> _items = const [];
  AnnouncementItem? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_selected != null) {
      return _InformationDetail(
        appState: widget.appState,
        item: _selected!,
        onBack: () => setState(() => _selected = null),
      );
    }

    if (_isLoading) {
      return const LoadingState(message: 'Memuat informasi umum...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: 'Informasi belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    final banners = _items.where((item) => item.isBanner).toList();

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
                'Informasi Umum',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const AppHeader(
          title: 'Informasi Umum',
          subtitle: 'Pengumuman dan informasi resmi dari SIMAWA-GS.',
          leadingIcon: Icons.info_rounded,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (banners.isNotEmpty) ...[
          _BannerCarousel(
            items: banners,
            onTap: (item) => setState(() => _selected = item),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        CustomTextField(
          label: 'Search informasi',
          controller: _searchController,
          prefixIcon: Icons.search_rounded,
          onChanged: (_) => _load(),
        ),
        const SizedBox(height: AppSpacing.md),
        DropdownButtonFormField<String>(
          initialValue: _category,
          decoration: const InputDecoration(labelText: 'Kategori pengumuman'),
          items: informationCategories
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) {
            setState(() => _category = value);
            _load();
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        if (_items.isEmpty)
          const EmptyState(
            icon: Icons.campaign_outlined,
            title: 'Belum ada informasi',
            description:
                'Informasi umum akan tampil dari SIMAWA-GS saat tersedia.',
          )
        else
          for (final item in _items) ...[
            _InformationTile(
              item: item,
              onTap: () => setState(() => _selected = item),
              onBookmark: () => _toggleBookmark(item),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }

  Future<void> _load() async {
    final response = await widget.appState.informationService.getAnnouncements(
      filters: {
        if (_searchController.text.trim().isNotEmpty)
          'search': _searchController.text.trim(),
        if (_category != null) 'category': _category,
      },
    );

    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _items = response.data ?? const [];
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Informasi belum tersedia.';
      }
    });
  }

  Future<void> _toggleBookmark(AnnouncementItem item) async {
    final response = item.isBookmarked
        ? await widget.appState.informationService.removeBookmark(item.id)
        : await widget.appState.informationService.bookmarkAnnouncement(
            item.id,
          );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response.isSuccess
              ? 'Bookmark informasi diperbarui.'
              : response.message ?? 'Bookmark belum dapat diperbarui.',
        ),
      ),
    );
    await _load();
  }
}

class _InformationDetail extends StatelessWidget {
  const _InformationDetail({
    required this.appState,
    required this.item,
    required this.onBack,
  });

  final AppState appState;
  final AnnouncementItem item;
  final VoidCallback onBack;

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
              child: Text(
                'Detail Informasi',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        if (item.imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Image.network(item.imageUrl!, fit: BoxFit.cover),
          ),
        if (item.imageUrl != null) const SizedBox(height: AppSpacing.xl),
        StatusCard(
          title: item.title,
          description:
              '${item.message ?? 'Detail informasi akan tampil dari SIMAWA-GS.'}\n\nKategori: ${item.category ?? '-'}${item.publishedAt == null ? '' : '\nTanggal: ${item.publishedAt!.toLocal().toString().split('.').first}'}',
          icon: Icons.campaign_rounded,
          accentColor: AppColors.maroon,
        ),
      ],
    );
  }
}

class _InformationTile extends StatelessWidget {
  const _InformationTile({
    required this.item,
    required this.onTap,
    required this.onBookmark,
  });

  final AnnouncementItem item;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
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
            const Icon(Icons.campaign_rounded, color: AppColors.maroon),
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
                    item.category ?? 'Informasi',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (item.message != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.message!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: onBookmark,
              icon: Icon(
                item.isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: AppColors.maroon,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerCarousel extends StatelessWidget {
  const _BannerCarousel({required this.items, required this.onTap});

  final List<AnnouncementItem> items;
  final ValueChanged<AnnouncementItem> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () => onTap(item),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.maroon,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: AppShadows.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category ?? 'Informasi',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: AppColors.gold),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    item.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
