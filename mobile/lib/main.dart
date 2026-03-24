import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/auth_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for a consistent mobile experience.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar styling.
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: LoyaltyApp()));
}

class LoyaltyApp extends ConsumerStatefulWidget {
  const LoyaltyApp({super.key});

  @override
  ConsumerState<LoyaltyApp> createState() => _LoyaltyAppState();
}

class _LoyaltyAppState extends ConsumerState<LoyaltyApp> {
  @override
  void initState() {
    super.initState();
    // Hydrate auth state from secure storage on app startup.
    Future.microtask(
      () => ref.read(authProvider.notifier).checkAuthStatus(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final router = ref.watch(routerProvider);

    // Show a splash screen while the auth state is still loading.
    if (authState.status == AuthStatus.initial) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _SplashScreen(),
      );
    }

    return MaterialApp.router(
      title: 'Loyalty',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}

// =============================================================================
// Splash screen — shown while checking stored auth tokens
// =============================================================================

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.loyalty_rounded,
              size: 64,
              color: AppColors.matte,
            ),
            const SizedBox(height: 20),
            Text(
              'Loyalty',
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.matte,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
