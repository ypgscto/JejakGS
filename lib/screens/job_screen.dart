import 'package:flutter/material.dart';

import '../providers/state/app_state.dart';
import 'job_application_history_screen.dart';
import 'job_detail_screen.dart';
import 'job_list_screen.dart';
import 'saved_job_screen.dart';

enum _JobPage { list, detail, saved, history }

class JobScreen extends StatefulWidget {
  const JobScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  _JobPage _page = _JobPage.list;
  String? _selectedJobId;

  @override
  Widget build(BuildContext context) {
    switch (_page) {
      case _JobPage.list:
        return JobListScreen(
          appState: widget.appState,
          onOpenDetail: _openDetail,
          onOpenSaved: () => _open(_JobPage.saved),
          onOpenHistory: () => _open(_JobPage.history),
        );
      case _JobPage.detail:
        return JobDetailScreen(
          appState: widget.appState,
          jobId: _selectedJobId ?? '',
          onBack: () => _open(_JobPage.list),
        );
      case _JobPage.saved:
        return SavedJobScreen(
          appState: widget.appState,
          onBack: () => _open(_JobPage.list),
          onOpenDetail: _openDetail,
        );
      case _JobPage.history:
        return JobApplicationHistoryScreen(
          appState: widget.appState,
          onBack: () => _open(_JobPage.list),
        );
    }
  }

  void _open(_JobPage page) {
    setState(() => _page = page);
  }

  void _openDetail(String id) {
    setState(() {
      _selectedJobId = id;
      _page = _JobPage.detail;
    });
  }
}
