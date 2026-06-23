import 'package:flutter/material.dart';

import '../config/app_routes.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import 'access_blocked_screen.dart';
import 'batchmate_screen.dart';
import 'digital_card_screen.dart';
import '../providers/state/app_state.dart';
import 'event_screens.dart';
import 'home_screen.dart';
import 'ika_screen.dart';
import 'information_screen.dart';
import 'job_screen.dart';
import 'notification_screen.dart';
import 'profile_screen.dart';
import 'shortcut_detail_screen.dart';
import 'tracer_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;
  String? _shortcutRoute;
  DigitalCardType? _digitalCardType;
  bool _showEvents = false;
  bool _showBatchmates = false;
  bool _showNotifications = false;
  bool _showInformation = false;
  _BlockedFeature? _blockedFeature;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.mediumGrey),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkMaroon.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: NavigationBar(
              height: 72,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _selectTab,
              backgroundColor: AppColors.white,
              surfaceTintColor: AppColors.white,
              shadowColor: Colors.transparent,
              indicatorColor: AppColors.maroon.withValues(alpha: 0.1),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(
                    Icons.home_rounded,
                    color: AppColors.maroon,
                  ),
                  label: 'Beranda',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(
                    Icons.assignment_rounded,
                    color: AppColors.maroon,
                  ),
                  label: 'Tracer',
                ),
                NavigationDestination(
                  icon: Icon(Icons.work_outline_rounded),
                  selectedIcon: Icon(
                    Icons.work_rounded,
                    color: AppColors.maroon,
                  ),
                  label: 'Loker',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  selectedIcon: Icon(
                    Icons.groups_rounded,
                    color: AppColors.maroon,
                  ),
                  label: 'IKA',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(
                    Icons.person_rounded,
                    color: AppColors.maroon,
                  ),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_blockedFeature != null) {
      return AccessBlockedScreen(
        title: _blockedFeature!.title,
        message: widget.appState.accessDeniedMessage(_blockedFeature!.feature),
        onBack: () => setState(() => _blockedFeature = null),
      );
    }

    if (_digitalCardType != null) {
      return DigitalCardScreen(
        appState: widget.appState,
        type: _digitalCardType!,
        onBack: () => setState(() => _digitalCardType = null),
      );
    }

    if (_showEvents) {
      return EventListScreen(
        appState: widget.appState,
        onBack: () => setState(() => _showEvents = false),
      );
    }

    if (_showBatchmates) {
      return BatchmateScreen(
        appState: widget.appState,
        onBack: () => setState(() => _showBatchmates = false),
      );
    }

    if (_showNotifications) {
      return NotificationScreen(
        appState: widget.appState,
        onBack: () => setState(() => _showNotifications = false),
      );
    }

    if (_showInformation) {
      return InformationScreen(
        appState: widget.appState,
        onBack: () => setState(() => _showInformation = false),
      );
    }

    if (_shortcutRoute != null) {
      return ShortcutDetailScreen(
        routeName: _shortcutRoute!,
        onBack: () => setState(() => _shortcutRoute = null),
      );
    }

    return IndexedStack(
      index: _selectedIndex,
      children: [
        HomeScreen(
          appState: widget.appState,
          onShortcutSelected: _openShortcut,
        ),
        TracerScreen(appState: widget.appState),
        JobScreen(appState: widget.appState),
        IkaScreen(appState: widget.appState),
        ProfileScreen(appState: widget.appState),
      ],
    );
  }

  void _selectTab(int index) {
    if (index == 1 && !_canAccess(AlumniFeature.tracer, 'Tracer')) {
      return;
    }

    if (index == 3 && !_canAccess(AlumniFeature.ika, 'IKA')) {
      return;
    }

    setState(() {
      _selectedIndex = index;
      _shortcutRoute = null;
      _digitalCardType = null;
      _showEvents = false;
      _showBatchmates = false;
      _showNotifications = false;
      _showInformation = false;
      _blockedFeature = null;
    });
  }

  void _openShortcut(String routeName) {
    switch (routeName) {
      case AppRoutes.home:
        _selectTab(0);
        return;
      case AppRoutes.tracer:
        if (!_canAccess(AlumniFeature.tracer, 'Tracer')) {
          return;
        }
        _selectTab(1);
        return;
      case AppRoutes.jobs:
        _selectTab(2);
        return;
      case AppRoutes.ika:
        if (!_canAccess(AlumniFeature.ika, 'IKA')) {
          return;
        }
        _selectTab(3);
        return;
      case AppRoutes.profile:
        _selectTab(4);
        return;
      case AppRoutes.alumniCard:
        if (!_canAccess(AlumniFeature.alumniCard, 'Kartu Alumni')) {
          return;
        }
        setState(() => _digitalCardType = DigitalCardType.alumni);
        return;
      case AppRoutes.ikaCard:
        if (!_canAccess(AlumniFeature.ikaCard, 'Kartu IKA')) {
          return;
        }
        setState(() => _digitalCardType = DigitalCardType.ika);
        return;
      case AppRoutes.events:
        setState(() => _showEvents = true);
        return;
      case AppRoutes.batchmates:
        if (!_canAccess(AlumniFeature.batchmates, 'Jejak Angkatan')) {
          return;
        }
        setState(() => _showBatchmates = true);
        return;
      case AppRoutes.notifications:
        setState(() => _showNotifications = true);
        return;
      case AppRoutes.generalInfo:
        setState(() => _showInformation = true);
        return;
    }

    setState(() => _shortcutRoute = routeName);
  }

  bool _canAccess(AlumniFeature feature, String title) {
    if (widget.appState.canAccessFeature(feature)) {
      return true;
    }

    setState(() => _blockedFeature = _BlockedFeature(feature, title));
    return false;
  }
}

class _BlockedFeature {
  const _BlockedFeature(this.feature, this.title);

  final AlumniFeature feature;
  final String title;
}
