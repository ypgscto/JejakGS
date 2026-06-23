import 'package:flutter/material.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'providers/state/app_state.dart';
import 'repositories/simawa_repository.dart';
import 'services/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  final tokenStorage = SecureAuthTokenStorage();
  final apiClient = SimawaApiClient(
    config: config,
    interceptors: [AuthorizationInterceptor(tokenStorage: tokenStorage)],
  );
  final repository = SimawaRepository(apiService: apiClient);
  final authService = AuthService(
    apiService: apiClient,
    tokenStorage: tokenStorage,
  );
  final alumniService = AlumniService(apiService: apiClient);
  final dashboardService = DashboardService(apiService: apiClient);
  final tracerService = TracerService(apiService: apiClient);
  final ikaService = IkaService(apiService: apiClient);
  final jobService = JobService(apiService: apiClient);
  final eventService = EventService(apiService: apiClient);
  final batchmateService = BatchmateService(apiService: apiClient);
  final notificationService = NotificationService(apiService: apiClient);
  final informationService = InformationService(apiService: apiClient);

  runApp(
    JejakGsApp(
      appState: AppState(
        config: config,
        simawaRepository: repository,
        authService: authService,
        alumniService: alumniService,
        dashboardService: dashboardService,
        tracerService: tracerService,
        ikaService: ikaService,
        jobService: jobService,
        eventService: eventService,
        batchmateService: batchmateService,
        notificationService: notificationService,
        informationService: informationService,
      ),
    ),
  );
}
