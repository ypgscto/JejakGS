import 'package:flutter/material.dart';

import '../providers/state/app_state.dart';
import 'access_blocked_screen.dart';
import 'tracer_form_screen.dart';
import 'tracer_history_screen.dart';
import 'tracer_home_screen.dart';
import 'tracer_review_screen.dart';

enum _TracerPage { home, form, history, review }

class TracerScreen extends StatefulWidget {
  const TracerScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<TracerScreen> createState() => _TracerScreenState();
}

class _TracerScreenState extends State<TracerScreen> {
  _TracerPage _page = _TracerPage.home;
  String? _selectedSubmissionId;

  @override
  Widget build(BuildContext context) {
    if (!widget.appState.canAccessFeature(AlumniFeature.tracer)) {
      return AccessBlockedScreen(
        title: 'Tracer',
        message: widget.appState.accessDeniedMessage(AlumniFeature.tracer),
        onBack: () {},
      );
    }

    switch (_page) {
      case _TracerPage.home:
        return TracerHomeScreen(
          appState: widget.appState,
          onOpenForm: () => setState(() => _page = _TracerPage.form),
          onOpenHistory: () => setState(() => _page = _TracerPage.history),
        );
      case _TracerPage.form:
        return TracerFormScreen(
          appState: widget.appState,
          onBack: () => setState(() => _page = _TracerPage.home),
        );
      case _TracerPage.history:
        return TracerHistoryScreen(
          appState: widget.appState,
          onBack: () => setState(() => _page = _TracerPage.home),
          onOpenReview: (id) => setState(() {
            _selectedSubmissionId = id;
            _page = _TracerPage.review;
          }),
        );
      case _TracerPage.review:
        return TracerReviewScreen(
          appState: widget.appState,
          submissionId: _selectedSubmissionId ?? '',
          onBack: () => setState(() => _page = _TracerPage.history),
        );
    }
  }
}
