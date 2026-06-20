import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post('/auth/sign_in', data: {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      });

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final refreshToken = data['refresh_token'] as String;
      final user = Map<String, dynamic>.from(data['user'] as Map);

      await ref.read(authProvider.notifier).loginSuccess(
            accessToken: token,
            refreshToken: refreshToken,
            user: user,
          );
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context).loginInvalidCredentials;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // -------------------- App icon --------------------
                  const Icon(
                    Icons.loyalty_rounded,
                    size: 56,
                    color: AppColors.matte,
                  ),
                  const SizedBox(height: 12),

                  // -------------------- App title --------------------
                  Text('Loyalty', style: AppTypography.headlineLarge),
                  const SizedBox(height: 8),
                  Text(
                    l10n.loginSubtitle,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.secondary),
                  ),
                  const SizedBox(height: 40),

                  // ------------------- Error banner ------------------
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ------------------- Email field -------------------
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    style: AppTypography.bodyMedium,
                    decoration: InputDecoration(
                      labelText: l10n.loginEmailLabel,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.loginEmailRequired;
                      }
                      if (!value.contains('@')) {
                        return l10n.loginEmailInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ----------------- Password field ------------------
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSignIn(),
                    style: AppTypography.bodyMedium,
                    decoration: InputDecoration(
                      labelText: l10n.loginPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(
                              () => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.loginPasswordRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // ------------------- Sign in button ----------------
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignIn,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.cream,
                              ),
                            )
                          : Text(l10n.loginSignInButton),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ------------------- Register link -----------------
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: Text.rich(
                      TextSpan(
                        text: l10n.loginNoAccountPrefix,
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.secondary),
                        children: [
                          TextSpan(
                            text: l10n.loginSignUpLink,
                            style: AppTypography.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                  .moveY(
                    begin: 12,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
