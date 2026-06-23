import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/constants/app_shadows.dart';
import '../core/constants/app_spacing.dart';
import '../providers/state/app_state.dart';
import '../widgets/design_system/design_system.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _validationMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (AppSpacing.xl * 2),
                ),
                child: Center(
                  child: isWide
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Expanded(child: _LoginMascot()),
                            const SizedBox(width: AppSpacing.xxxl),
                            SizedBox(width: 430, child: _loginPanel()),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const _LoginMascot(compact: true),
                            const SizedBox(height: AppSpacing.xl),
                            _loginPanel(),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _loginPanel() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.mediumGrey),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            label: 'Email',
            hintText: 'Masukkan email akun JejakGS',
            controller: _identifierController,
            prefixIcon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(
            label: 'Password',
            hintText: 'Masukkan password',
            controller: _passwordController,
            prefixIcon: Icons.key_rounded,
            obscureText: true,
            textInputAction: TextInputAction.done,
          ),
          if (_validationMessage != null ||
              widget.appState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: _MessageBox(
                message: _validationMessage ?? widget.appState.errorMessage!,
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: 'Masuk',
            icon: Icons.login_rounded,
            isLoading: widget.appState.isBusy,
            fullWidth: true,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: 'Register Alumni',
            icon: Icons.verified_user_rounded,
            fullWidth: true,
            onPressed: widget.appState.isBusy
                ? null
                : widget.appState.showActivation,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      setState(() {
        _validationMessage = 'Email dan password wajib diisi.';
      });
      return;
    }

    if (!identifier.contains('@')) {
      setState(() {
        _validationMessage = 'Masukkan email akun JejakGS yang valid.';
      });
      return;
    }

    setState(() => _validationMessage = null);
    await widget.appState.login(identifier: identifier, password: password);
  }
}

class _LoginMascot extends StatelessWidget {
  const _LoginMascot({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/maskot_jejakgs.png',
          height: compact ? 220 : 420,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'JejakGS Alumni',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.maroon,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.18)),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.danger),
      ),
    );
  }
}
