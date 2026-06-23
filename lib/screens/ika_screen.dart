import 'package:flutter/material.dart';

import '../providers/state/app_state.dart';
import 'access_blocked_screen.dart';
import 'ika_events_screen.dart';
import 'ika_home_screen.dart';
import 'ika_member_card_screen.dart';
import 'ika_payment_screen.dart';
import 'ika_registration_screen.dart';
import 'ika_status_screen.dart';

enum _IkaPage {
  home,
  registration,
  status,
  memberCard,
  events,
  payment,
  voting,
  forum,
}

class IkaScreen extends StatefulWidget {
  const IkaScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<IkaScreen> createState() => _IkaScreenState();
}

class _IkaScreenState extends State<IkaScreen> {
  _IkaPage _page = _IkaPage.home;

  @override
  Widget build(BuildContext context) {
    if (!widget.appState.canAccessFeature(AlumniFeature.ika)) {
      return AccessBlockedScreen(
        title: 'IKA',
        message: widget.appState.accessDeniedMessage(AlumniFeature.ika),
        onBack: () {},
      );
    }

    switch (_page) {
      case _IkaPage.home:
        return IkaHomeScreen(
          appState: widget.appState,
          onOpenRegistration: () => _open(_IkaPage.registration),
          onOpenStatus: () => _open(_IkaPage.status),
          onOpenCard: () => _open(_IkaPage.memberCard),
          onOpenEvents: () => _open(_IkaPage.events),
          onOpenPayment: () => _open(_IkaPage.payment),
          onOpenVoting: () => _open(_IkaPage.voting),
          onOpenForum: () => _open(_IkaPage.forum),
        );
      case _IkaPage.registration:
        return IkaRegistrationScreen(
          appState: widget.appState,
          onBack: _backHome,
        );
      case _IkaPage.status:
        return IkaStatusScreen(appState: widget.appState, onBack: _backHome);
      case _IkaPage.memberCard:
        return IkaMemberCardScreen(
          appState: widget.appState,
          onBack: _backHome,
        );
      case _IkaPage.events:
        return IkaEventsScreen(appState: widget.appState, onBack: _backHome);
      case _IkaPage.payment:
        return IkaPaymentScreen(appState: widget.appState, onBack: _backHome);
      case _IkaPage.voting:
        return IkaVotingScreen(appState: widget.appState, onBack: _backHome);
      case _IkaPage.forum:
        return IkaForumScreen(appState: widget.appState, onBack: _backHome);
    }
  }

  void _open(_IkaPage page) {
    setState(() => _page = page);
  }

  void _backHome() {
    setState(() => _page = _IkaPage.home);
  }
}
