import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';

class DigitalCardView extends StatelessWidget {
  const DigitalCardView({
    required this.title,
    required this.name,
    required this.fields,
    this.photoUrl,
    this.qrData,
    this.qrCodeUrl,
    this.badge,
    super.key,
  });

  final String title;
  final String name;
  final Map<String, String> fields;
  final String? photoUrl;
  final String? qrData;
  final String? qrCodeUrl;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 85.6 / 54,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.darkMaroon, AppColors.maroon],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          boxShadow: AppShadows.medium,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final dense = constraints.maxWidth < 360;
            final avatarSize = dense ? 104.0 : 124.0;
            final headerHeight = dense ? 64.0 : 74.0;

            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: avatarSize + AppSpacing.md),
                  child: SizedBox(
                    height: headerHeight,
                    child: _CardHeader(title: title, dense: dense),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: _CardAvatar(
                    name: name,
                    photoUrl: photoUrl,
                    dense: dense,
                    size: avatarSize,
                  ),
                ),
                Positioned.fill(
                  top: headerHeight + AppSpacing.md,
                  bottom: dense ? 42 : 50,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: dense ? AppSpacing.md : avatarSize * 0.2,
                          ),
                          child: _LandscapeProfileDetails(
                            name: name,
                            fields: fields,
                            dense: dense,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: _QrBox(
                          qrData: qrData,
                          qrCodeUrl: qrCodeUrl,
                          dense: dense,
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge != null)
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: _CardBadge(label: badge!, dense: dense),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, required this.dense});

  final String title;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/stikes_gunung_sari.png',
          width: dense ? 58 : 66,
          height: dense ? 58 : 66,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'STIKES Gunung Sari',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.white,
                  fontSize: dense ? 19 : 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.82),
                  fontSize: dense ? 11 : 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardAvatar extends StatelessWidget {
  const _CardAvatar({
    required this.name,
    required this.photoUrl,
    required this.dense,
    required this.size,
  });

  final String name;
  final String? photoUrl;
  final bool dense;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        width: size,
        height: size,
        color: AppColors.softGold,
        child: url == null || url.isEmpty
            ? _AvatarInitials(name: name, dense: dense)
            : Image.network(
                url,
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                errorBuilder: (context, error, stackTrace) {
                  return _AvatarInitials(name: name, dense: dense);
                },
                loadingBuilder: (context, child, progress) {
                  if (progress == null) {
                    return child;
                  }

                  return _AvatarInitials(name: name, dense: dense);
                },
              ),
      ),
    );
  }
}

class _AvatarInitials extends StatelessWidget {
  const _AvatarInitials({required this.name, required this.dense});

  final String name;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _initials(name),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.maroon,
          fontSize: dense ? 13 : 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LandscapeProfileDetails extends StatelessWidget {
  const _LandscapeProfileDetails({
    required this.name,
    required this.fields,
    required this.dense,
  });

  final String name;
  final Map<String, String> fields;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final visibleFields = fields.entries.toList();
    final primary = visibleFields.isNotEmpty ? visibleFields.first : null;
    final prodi = visibleFields.length > 1 ? visibleFields[1] : null;
    final remaining = visibleFields.skip(2).take(dense ? 2 : 3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontSize: dense ? 17 : 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (primary != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SizedBox(
                  width: dense ? 172 : 238,
                  child: _CardField(
                    label: primary.key,
                    value: primary.value,
                    dense: dense,
                    emphasize: true,
                  ),
                ),
              ),
            ],
          ),
        if (prodi != null) ...[
          const SizedBox(height: 2),
          SizedBox(
            width: dense ? 180 : 250,
            child: _CardField(
              label: prodi.key,
              value: prodi.value,
              dense: dense,
              enlarged: true,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: 2,
          children: [
            for (final entry in remaining)
              SizedBox(
                width: dense ? 76 : 110,
                child: _CardField(
                  label: entry.key,
                  value: entry.value,
                  dense: dense,
                  enlarged: true,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CardField extends StatelessWidget {
  const _CardField({
    required this.label,
    required this.value,
    required this.dense,
    this.emphasize = false,
    this.enlarged = false,
  });

  final String label;
  final String value;
  final bool dense;
  final bool emphasize;
  final bool enlarged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.70),
            fontSize: dense ? 8 : 10,
            height: 1.1,
          ),
        ),
        Text(
          value.isEmpty ? '-' : value,
          maxLines: emphasize ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.white,
            fontSize: emphasize
                ? (dense ? 12 : 14)
                : enlarged
                ? (dense ? 11 : 13)
                : (dense ? 9 : 11),
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _QrBox extends StatelessWidget {
  const _QrBox({
    required this.qrData,
    required this.qrCodeUrl,
    required this.dense,
  });

  final String? qrData;
  final String? qrCodeUrl;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dense ? 66 : 80,
      height: dense ? 66 : 80,
      padding: EdgeInsets.all(dense ? 7 : 9),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: qrData != null && qrData!.trim().isNotEmpty
          ? QrImageView(
              data: qrData!.trim(),
              padding: EdgeInsets.zero,
              backgroundColor: AppColors.white,
            )
          : qrCodeUrl == null || qrCodeUrl!.trim().isEmpty
          ? Center(
              child: Text(
                'QR belum tersedia',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: dense ? 8 : 9,
                ),
              ),
            )
          : Image.network(qrCodeUrl!, fit: BoxFit.contain),
    );
  }
}

class _CardBadge extends StatelessWidget {
  const _CardBadge({required this.label, required this.dense});

  final String label;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.darkMaroon,
          fontSize: dense ? 9 : 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String _initials(String value) {
  final words = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();

  return words.isEmpty
      ? '-'
      : words.take(2).map((word) => word[0].toUpperCase()).join();
}
