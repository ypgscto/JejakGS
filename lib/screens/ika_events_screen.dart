import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_shadows.dart';
import '../core/constants/app_spacing.dart';
import '../models/models.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

enum _IkaEventPage { list, detail, ticket }

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
  _IkaEventPage _page = _IkaEventPage.list;
  AlumniEvent? _selectedEvent;
  IkaEventTicket? _selectedTicket;

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      _IkaEventPage.list => IkaEventListScreen(
        appState: widget.appState,
        onBack: widget.onBack,
        onOpenDetail: _openDetail,
      ),
      _IkaEventPage.detail => IkaEventDetailScreen(
        appState: widget.appState,
        event: _selectedEvent!,
        onBack: _backToList,
        onOpenTicket: _openTicket,
      ),
      _IkaEventPage.ticket => IkaEventTicketScreen(
        appState: widget.appState,
        event: _selectedEvent!,
        initialTicket: _selectedTicket,
        onBack: _backToDetail,
      ),
    };
  }

  void _openDetail(AlumniEvent event) {
    setState(() {
      _selectedEvent = event;
      _selectedTicket = null;
      _page = _IkaEventPage.detail;
    });
  }

  void _openTicket(AlumniEvent event, IkaEventTicket? ticket) {
    setState(() {
      _selectedEvent = event;
      _selectedTicket = ticket;
      _page = _IkaEventPage.ticket;
    });
  }

  void _backToList() {
    setState(() {
      _page = _IkaEventPage.list;
      _selectedEvent = null;
      _selectedTicket = null;
    });
  }

  void _backToDetail() {
    setState(() {
      _page = _IkaEventPage.detail;
      _selectedTicket = null;
    });
  }
}

class IkaEventListScreen extends StatefulWidget {
  const IkaEventListScreen({
    required this.appState,
    required this.onBack,
    required this.onOpenDetail,
    super.key,
  });

  final AppState appState;
  final VoidCallback onBack;
  final ValueChanged<AlumniEvent> onOpenDetail;

  @override
  State<IkaEventListScreen> createState() => _IkaEventListScreenState();
}

class _IkaEventListScreenState extends State<IkaEventListScreen> {
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
        _BackTitle(title: 'Event Anggota IKA', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        if (_items.isEmpty)
          const _SmallEmptyState(message: 'Belum ada event anggota IKA.')
        else
          for (final item in _items) ...[
            _IkaEventCard(event: item, onTap: () => widget.onOpenDetail(item)),
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

class IkaEventDetailScreen extends StatefulWidget {
  const IkaEventDetailScreen({
    required this.appState,
    required this.event,
    required this.onBack,
    required this.onOpenTicket,
    super.key,
  });

  final AppState appState;
  final AlumniEvent event;
  final VoidCallback onBack;
  final void Function(AlumniEvent event, IkaEventTicket? ticket) onOpenTicket;

  @override
  State<IkaEventDetailScreen> createState() => _IkaEventDetailScreenState();
}

class _IkaEventDetailScreenState extends State<IkaEventDetailScreen> {
  bool _isLoading = true;
  bool _isRegistering = false;
  String? _errorMessage;
  String? _successMessage;
  AlumniEvent? _event;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingState(message: 'Memuat detail event IKA...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        title: 'Detail event belum dapat dimuat',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    final event = _event ?? widget.event;
    final canOpenTicket = event.ticketAvailable || event.isRegistered;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'Detail Event Anggota', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        AppHeader(
          title: event.title,
          subtitle: event.categoryLabel ?? event.category ?? 'Event IKA',
          leadingIcon: Icons.event_available_rounded,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_successMessage != null) ...[
          StatusCard(
            title: 'Pendaftaran berhasil',
            description: _successMessage!,
            icon: Icons.check_circle_rounded,
            accentColor: AppColors.gold,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        _DetailPanel(event: event),
        const SizedBox(height: AppSpacing.xl),
        if (event.description != null && event.description!.trim().isNotEmpty)
          StatusCard(
            title: 'Deskripsi',
            description: event.description!,
            icon: Icons.notes_rounded,
            accentColor: AppColors.maroon,
          ),
        if (event.description != null && event.description!.trim().isNotEmpty)
          const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: event.isRegistered ? 'Sudah Terdaftar' : 'Daftar Event',
          icon: event.isRegistered
              ? Icons.check_circle_rounded
              : Icons.how_to_reg_rounded,
          isLoading: _isRegistering,
          fullWidth: true,
          onPressed: event.isRegistered ? null : _register,
        ),
        if (canOpenTicket) ...[
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: 'Lihat QR Peserta',
            icon: Icons.qr_code_rounded,
            fullWidth: true,
            onPressed: () => widget.onOpenTicket(event, null),
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

    final response = await widget.appState.ikaService.getMemberEventDetail(
      widget.event.id,
    );
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _event = response.data;
      } else {
        _errorMessage = response.message ?? 'Detail event belum tersedia.';
      }
    });
  }

  Future<void> _register() async {
    final event = _event ?? widget.event;
    setState(() {
      _isRegistering = true;
      _successMessage = null;
    });

    final response = await widget.appState.ikaService.registerMemberEvent(
      event.id,
    );
    if (!mounted) return;

    if (response.isSuccess) {
      final detailResponse = await widget.appState.ikaService
          .getMemberEventDetail(event.id);
      if (!mounted) return;

      final refreshedEvent = detailResponse.data ?? event;
      setState(() {
        _isRegistering = false;
        _event = refreshedEvent;
        _successMessage =
            response.message ?? 'Pendaftaran event berhasil dikirim.';
      });
      widget.onOpenTicket(refreshedEvent, response.data);
      return;
    }

    setState(() {
      _isRegistering = false;
      _errorMessage = response.message ?? 'Pendaftaran belum dapat dikirim.';
    });
  }
}

class IkaEventTicketScreen extends StatefulWidget {
  const IkaEventTicketScreen({
    required this.appState,
    required this.event,
    required this.onBack,
    this.initialTicket,
    super.key,
  });

  final AppState appState;
  final AlumniEvent event;
  final IkaEventTicket? initialTicket;
  final VoidCallback onBack;

  @override
  State<IkaEventTicketScreen> createState() => _IkaEventTicketScreenState();
}

class _IkaEventTicketScreenState extends State<IkaEventTicketScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  IkaEventTicket? _ticket;

  @override
  void initState() {
    super.initState();
    _ticket = widget.initialTicket;
    if (_ticket != null) {
      _isLoading = false;
    } else {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingState(message: 'Memuat tiket event...');
    if (_errorMessage != null) {
      return ErrorState(
        title: 'Tiket event belum tersedia',
        message: _errorMessage!,
        onRetry: _load,
      );
    }

    final ticket = _ticket;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _BackTitle(title: 'QR Peserta Event', onBack: widget.onBack),
        const SizedBox(height: AppSpacing.xl),
        if (ticket == null)
          const EmptyState(
            icon: Icons.confirmation_number_outlined,
            title: 'Tiket belum tersedia',
            description: 'Silakan daftar event terlebih dahulu.',
          )
        else
          _TicketCard(ticket: ticket),
      ],
    );
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await widget.appState.ikaService.getMemberEventTicket(
      widget.event.id,
    );
    setState(() {
      _isLoading = false;
      if (response.isSuccess) {
        _ticket = response.data;
      } else {
        _errorMessage =
            response.message ??
            'Tiket event belum tersedia. Silakan daftar event terlebih dahulu.';
      }
    });
  }
}

class _IkaEventCard extends StatelessWidget {
  const _IkaEventCard({required this.event, required this.onTap});

  final AlumniEvent event;
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
                    child: Icon(
                      event.isOnline
                          ? Icons.video_camera_front_rounded
                          : Icons.event_rounded,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _MetaLine(
                          icon: Icons.category_rounded,
                          text: event.categoryLabel ?? event.category ?? '-',
                        ),
                      ],
                    ),
                  ),
                  _RegistrationBadge(event: event),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _MetaLine(
                icon: Icons.calendar_today_rounded,
                text: _date(event.startAt),
              ),
              const SizedBox(height: AppSpacing.sm),
              _MetaLine(icon: Icons.schedule_rounded, text: _timeRange(event)),
              const SizedBox(height: AppSpacing.sm),
              _MetaLine(
                icon: event.isOnline ? Icons.link_rounded : Icons.place_rounded,
                text: _location(event),
              ),
              if (event.quota != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _MetaLine(
                  icon: Icons.groups_rounded,
                  text: 'Kuota ${event.registeredCount}/${event.quota}',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.event});

  final AlumniEvent event;

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
          _DetailRow(
            label: 'Kategori',
            value: event.categoryLabel ?? event.category,
          ),
          _DetailRow(label: 'Tanggal', value: _date(event.startAt)),
          _DetailRow(label: 'Jam', value: _timeRange(event)),
          _DetailRow(label: 'Lokasi/link online', value: _location(event)),
          _DetailRow(
            label: 'Status pendaftaran',
            value: _registrationText(event),
          ),
          _DetailRow(
            label: 'Kuota',
            value: event.quota == null
                ? 'Tidak dibatasi'
                : '${event.registeredCount}/${event.quota}',
          ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final IkaEventTicket ticket;

  @override
  Widget build(BuildContext context) {
    final qrValue = ticket.qrCodeValue?.trim();

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            ticket.eventTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            ticket.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: 180,
            height: 180,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: qrValue != null && qrValue.isNotEmpty
                ? QrImageView(data: qrValue, padding: EdgeInsets.zero)
                : Center(
                    child: Text(
                      'QR peserta belum tersedia',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _TicketInfo(label: 'NIM', value: ticket.nim),
          _TicketInfo(label: 'Prodi', value: ticket.programStudy),
          _TicketInfo(label: 'Tanggal', value: _date(ticket.eventDate)),
          _TicketInfo(label: 'Lokasi', value: ticket.location),
          _TicketInfo(
            label: 'Status',
            value: ticket.registrationStatus ?? 'registered',
          ),
        ],
      ),
    );
  }
}

class _SmallEmptyState extends StatelessWidget {
  const _SmallEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_busy_rounded, color: AppColors.maroon),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _RegistrationBadge extends StatelessWidget {
  const _RegistrationBadge({required this.event});

  final AlumniEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: event.isRegistered ? AppColors.softGold : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        event.isRegistered ? 'Terdaftar' : event.statusLabel ?? 'Buka',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.maroon,
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
            width: 126,
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

class _TicketInfo extends StatelessWidget {
  const _TicketInfo({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white.withValues(alpha: 0.68),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value == null || value!.trim().isEmpty ? '-' : value!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
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

String _date(DateTime? value) {
  if (value == null || value.millisecondsSinceEpoch == 0) return '-';

  return value.toLocal().toString().split(' ').first;
}

String _timeRange(AlumniEvent event) {
  final start = event.startTime?.trim();
  final end = event.endTime?.trim();

  if (start != null && start.isNotEmpty && end != null && end.isNotEmpty) {
    return '$start - $end';
  }

  if (start != null && start.isNotEmpty) return start;
  if (end != null && end.isNotEmpty) return end;

  return '-';
}

String _location(AlumniEvent event) {
  final online = event.onlineLink?.trim();
  if (online != null && online.isNotEmpty) return online;

  final location = event.location?.trim();
  if (location != null && location.isNotEmpty) return location;

  return '-';
}

String _registrationText(AlumniEvent event) {
  if (event.isRegistered) {
    return event.participantStatus ?? 'Terdaftar';
  }

  return event.statusLabel ?? event.registrationStatus ?? '-';
}
