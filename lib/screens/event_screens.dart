import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

const eventCategories = [
  'Seminar/webinar',
  'Reuni',
  'Musyawarah IKA',
  'Bakti sosial',
  'Pelatihan karier',
  'Alumni sharing',
  'Campus hiring',
];

class EventListScreen extends StatefulWidget {
  const EventListScreen({
    required this.appState,
    required this.onBack,
    super.key,
  });
  final AppState appState;
  final VoidCallback onBack;
  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _category;
  List<AlumniEvent> _events = const [];
  AlumniEvent? _selected;
  _EventPage _page = _EventPage.list;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_page != _EventPage.list && _selected != null) {
      return switch (_page) {
        _EventPage.detail => EventDetailScreen(
          appState: widget.appState,
          event: _selected!,
          onBack: () => setState(() => _page = _EventPage.list),
          onRegister: () => setState(() => _page = _EventPage.registration),
          onTicket: () => setState(() => _page = _EventPage.ticket),
          onCertificate: () => setState(() => _page = _EventPage.certificate),
          onGallery: () => setState(() => _page = _EventPage.gallery),
        ),
        _EventPage.registration => EventRegistrationScreen(
          appState: widget.appState,
          event: _selected!,
          onBack: () => setState(() => _page = _EventPage.detail),
        ),
        _EventPage.ticket => EventTicketScreen(
          appState: widget.appState,
          event: _selected!,
          onBack: () => setState(() => _page = _EventPage.detail),
        ),
        _EventPage.certificate => EventCertificateScreen(
          appState: widget.appState,
          event: _selected!,
          onBack: () => setState(() => _page = _EventPage.detail),
        ),
        _EventPage.gallery => EventGalleryScreen(
          appState: widget.appState,
          event: _selected!,
          onBack: () => setState(() => _page = _EventPage.detail),
        ),
        _EventPage.list => const SizedBox.shrink(),
      };
    }

    if (_isLoading) {
      return const LoadingState(message: 'Memuat event alumni...');
    }
    if (_errorMessage != null) {
      return ErrorState(
        title: 'Event belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

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
                'Event Alumni',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AppHeader(
          title: 'Event Alumni/IKA',
          subtitle: 'Data event berasal dari SIMAWA-GS.',
          leadingIcon: Icons.event_rounded,
        ),
        const SizedBox(height: AppSpacing.xl),
        DropdownButtonFormField<String>(
          initialValue: _category,
          decoration: const InputDecoration(labelText: 'Jenis event'),
          items: eventCategories
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) {
            setState(() => _category = value);
            _load();
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        if (_events.isEmpty)
          const EmptyState(
            icon: Icons.event_busy_rounded,
            title: 'Belum ada event',
            description:
                'Event alumni/IKA akan tampil dari SIMAWA-GS saat tersedia.',
          )
        else
          for (final event in _events) ...[
            EventCard(
              title: event.title,
              dateLabel: _date(event.startAt),
              location: event.location,
              categoryLabel: event.category,
              isOnline: event.isOnline,
              onTap: () => _openEvent(event),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }

  Future<void> _load() async {
    final response = await widget.appState.eventService.getEvents(
      filters: {if (_category != null) 'category': _category},
    );
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _events = response.data ?? const [];
        _errorMessage = null;
      } else {
        _errorMessage = response.message ?? 'Event belum tersedia.';
      }
    });
  }

  void _openEvent(AlumniEvent event) {
    final access = event.accessLevel?.toLowerCase();
    final isMember = widget.appState.canAccessIkaMemberFeatures;
    final isBoard = widget.appState.canAccessIkaOfficerFeatures;
    if (access == 'ika_member' && !isMember) {
      _showLocked('Event ini khusus anggota IKA.');
      return;
    }
    if ((access == 'ika_board' || access == 'ika_officer') && !isBoard) {
      _showLocked('Event ini khusus pengurus IKA.');
      return;
    }
    setState(() {
      _selected = event;
      _page = _EventPage.detail;
    });
  }

  void _showLocked(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _date(DateTime value) => value.toLocal().toString().split('.').first;
}

enum _EventPage { list, detail, registration, ticket, certificate, gallery }

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({
    required this.appState,
    required this.event,
    required this.onBack,
    required this.onRegister,
    required this.onTicket,
    required this.onCertificate,
    required this.onGallery,
    super.key,
  });
  final AppState appState;
  final AlumniEvent event;
  final VoidCallback onBack;
  final VoidCallback onRegister;
  final VoidCallback onTicket;
  final VoidCallback onCertificate;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Detail Event', onBack: onBack),
        const SizedBox(height: AppSpacing.xl),
        AppHeader(
          title: event.title,
          subtitle: event.category ?? 'Event Alumni',
          leadingIcon: Icons.event_rounded,
        ),
        const SizedBox(height: AppSpacing.xl),
        StatusCard(
          title: 'Informasi Event',
          description:
              '${event.description ?? 'Detail event dari SIMAWA-GS.'}\n\nLokasi: ${event.location ?? '-'}\nMulai: ${event.startAt.toLocal().toString().split('.').first}',
          icon: Icons.info_rounded,
          accentColor: AppColors.maroon,
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'Daftar Event',
          icon: Icons.how_to_reg_rounded,
          fullWidth: true,
          onPressed: onRegister,
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: 'QR Peserta / Presensi',
          icon: Icons.qr_code_rounded,
          fullWidth: true,
          onPressed: onTicket,
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: 'Sertifikat Digital',
          icon: Icons.workspace_premium_rounded,
          fullWidth: true,
          onPressed: onCertificate,
        ),
        const SizedBox(height: AppSpacing.md),
        SecondaryButton(
          label: 'Galeri Dokumentasi',
          icon: Icons.photo_library_rounded,
          fullWidth: true,
          onPressed: onGallery,
        ),
      ],
    );
  }
}

class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({
    required this.appState,
    required this.event,
    required this.onBack,
    super.key,
  });
  final AppState appState;
  final AlumniEvent event;
  final VoidCallback onBack;
  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  bool _isSubmitting = false;
  String? _message;
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Daftar Event', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        StatusCard(
          title: widget.event.title,
          description: 'Pendaftaran akan dikirim ke SIMAWA-GS.',
          icon: Icons.how_to_reg_rounded,
          accentColor: AppColors.maroon,
        ),
        if (_message != null) ...[
          const SizedBox(height: AppSpacing.md),
          StatusCard(
            title: 'Status pendaftaran',
            description: _message!,
            icon: Icons.info_rounded,
            accentColor: AppColors.gold,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'Konfirmasi Pendaftaran',
          icon: Icons.send_rounded,
          isLoading: _isSubmitting,
          fullWidth: true,
          onPressed: _submit,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final response = await widget.appState.eventService.registerEvent(
      widget.event.id,
    );
    setState(() {
      _isSubmitting = false;
      _message = response.isSuccess
          ? 'Pendaftaran event berhasil dikirim.'
          : response.message ?? 'Pendaftaran belum dapat dikirim.';
    });
  }
}

class EventTicketScreen extends StatelessWidget {
  const EventTicketScreen({
    required this.appState,
    required this.event,
    required this.onBack,
    super.key,
  });
  final AppState appState;
  final AlumniEvent event;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return _QrPage(
      title: 'QR Peserta / Presensi',
      onBack: onBack,
      qrUrl: event.participantQrCodeUrl ?? event.attendanceQrCodeUrl,
      emptyText: 'QR peserta/presensi belum tersedia dari SIMAWA-GS.',
    );
  }
}

class EventCertificateScreen extends StatelessWidget {
  const EventCertificateScreen({
    required this.appState,
    required this.event,
    required this.onBack,
    super.key,
  });
  final AppState appState;
  final AlumniEvent event;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    final cert = event.certificateUrl;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Sertifikat Digital', onBack: onBack),
        const SizedBox(height: AppSpacing.xl),
        cert == null || cert.isEmpty
            ? const EmptyState(
                icon: Icons.workspace_premium_rounded,
                title: 'Sertifikat belum tersedia',
                description:
                    'Sertifikat digital akan tampil jika tersedia dari SIMAWA-GS.',
              )
            : StatusCard(
                title: 'Sertifikat tersedia',
                description: cert,
                icon: Icons.workspace_premium_rounded,
                accentColor: AppColors.maroon,
              ),
      ],
    );
  }
}

class EventGalleryScreen extends StatelessWidget {
  const EventGalleryScreen({
    required this.appState,
    required this.event,
    required this.onBack,
    super.key,
  });
  final AppState appState;
  final AlumniEvent event;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Galeri Dokumentasi', onBack: onBack),
        const SizedBox(height: AppSpacing.xl),
        if (event.galleryUrls.isEmpty)
          const EmptyState(
            icon: Icons.photo_library_rounded,
            title: 'Galeri belum tersedia',
            description: 'Dokumentasi event akan tampil dari SIMAWA-GS.',
          )
        else
          for (final url in event.galleryUrls) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(url),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        const SizedBox(height: AppSpacing.lg),
        const StatusCard(
          title: 'Evaluasi Event',
          description:
              'Form evaluasi event akan ditampilkan mengikuti endpoint SIMAWA-GS.',
          icon: Icons.rate_review_rounded,
          accentColor: AppColors.gold,
        ),
      ],
    );
  }
}

class _QrPage extends StatelessWidget {
  const _QrPage({
    required this.title,
    required this.onBack,
    required this.qrUrl,
    required this.emptyText,
  });
  final String title;
  final VoidCallback onBack;
  final String? qrUrl;
  final String emptyText;
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: title, onBack: onBack),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Container(
            width: 220,
            height: 220,
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.white,
            child: qrUrl == null || qrUrl!.isEmpty
                ? Center(child: Text(emptyText, textAlign: TextAlign.center))
                : Image.network(qrUrl!, fit: BoxFit.contain),
          ),
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
