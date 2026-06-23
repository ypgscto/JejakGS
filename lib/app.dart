import 'package:flutter/material.dart';

import 'providers/state/app_state.dart';
import 'screens/activation_screen.dart';
import 'screens/complete_profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/verification_waiting_screen.dart';
import 'themes/app_theme.dart';

class JejakGsApp extends StatelessWidget {
  const JejakGsApp({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return MaterialApp(
          title: appState.config.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: _resolveScreen(),
        );
      },
    );
  }

  Widget _resolveScreen() {
    switch (appState.authFlowStatus) {
      case AuthFlowStatus.splash:
        return SplashScreen(appState: appState);
      case AuthFlowStatus.unauthenticated:
        return LoginScreen(appState: appState);
      case AuthFlowStatus.activation:
        return ActivationScreen(appState: appState);
      case AuthFlowStatus.completingProfile:
        return CompleteProfileScreen(appState: appState);
      case AuthFlowStatus.waitingVerification:
        return VerificationWaitingScreen(appState: appState);
      case AuthFlowStatus.authenticated:
        return MainShellScreen(appState: appState);
    }
  }
}
