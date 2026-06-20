import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/customer/screens/profile_screen.dart';
import '../../features/loyalty_card/screens/card_screen.dart';
import '../../features/rewards/screens/rewards_screen.dart';
import '../../features/staff/screens/scanner_screen.dart';
import '../../features/staff/screens/staff_profile_screen.dart';
import '../../features/staff/screens/visits_screen.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

// =============================================================================
// Navigation keys for StatefulShellRoute branches
// =============================================================================

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _customerShellKey = GlobalKey<NavigatorState>();
final _staffShellKey = GlobalKey<NavigatorState>();

// =============================================================================
// Router provider
// =============================================================================

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,

    // -------------------------------------------------------------------------
    // Redirect logic
    // -------------------------------------------------------------------------
    redirect: (context, state) {
      final status = authState.status;
      final currentPath = state.matchedLocation;

      // Still loading auth state -- stay put.
      if (status == AuthStatus.initial) return null;

      final isOnAuth =
          currentPath == '/login' || currentPath == '/register';
      final isAuthenticated = status == AuthStatus.authenticated;

      // Not authenticated -- force login.
      if (!isAuthenticated) {
        return isOnAuth ? null : '/login';
      }

      // Authenticated but on an auth page -- redirect based on role.
      if (isOnAuth) {
        return authState.isStaff ? '/scanner' : '/home';
      }

      // Authenticated customer trying to access staff routes.
      if (authState.isCustomer &&
          (currentPath.startsWith('/scanner') ||
              currentPath.startsWith('/visits') ||
              currentPath.startsWith('/staff-profile'))) {
        return '/home';
      }

      // Authenticated staff trying to access customer routes.
      if (authState.isStaff &&
          (currentPath.startsWith('/home') ||
              currentPath.startsWith('/rewards') ||
              currentPath == '/profile')) {
        return '/scanner';
      }

      return null;
    },

    // -------------------------------------------------------------------------
    // Routes
    // -------------------------------------------------------------------------
    routes: [
      // ---- Auth routes (no shell / bottom nav) ----
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ---- Customer shell with bottom navigation ----
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _CustomerShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _customerShellKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const CardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rewards',
                name: 'rewards',
                builder: (context, state) => const RewardsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ---- Staff shell with bottom navigation ----
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _StaffShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _staffShellKey,
            routes: [
              GoRoute(
                path: '/scanner',
                name: 'scanner',
                builder: (context, state) => const ScannerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/visits',
                name: 'visits',
                builder: (context, state) => const VisitsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/staff-profile',
                name: 'staffProfile',
                builder: (context, state) => const StaffProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// =============================================================================
// Customer bottom navigation shell
// =============================================================================

class _CustomerShell extends StatelessWidget {
  const _CustomerShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          backgroundColor: AppColors.cream,
          indicatorColor: AppColors.matte.withValues(alpha: 0.08),
          elevation: 0,
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.credit_card_outlined),
              selectedIcon: const Icon(Icons.credit_card),
              label: l10n.navMyCard,
            ),
            NavigationDestination(
              icon: const Icon(Icons.card_giftcard_outlined),
              selectedIcon: const Icon(Icons.card_giftcard),
              label: l10n.navRewards,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outlined),
              selectedIcon: const Icon(Icons.person),
              label: l10n.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Staff bottom navigation shell
// =============================================================================

class _StaffShell extends StatelessWidget {
  const _StaffShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          backgroundColor: AppColors.cream,
          indicatorColor: AppColors.matte.withValues(alpha: 0.08),
          elevation: 0,
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.qr_code_scanner_outlined),
              selectedIcon: const Icon(Icons.qr_code_scanner),
              label: l10n.navScanner,
            ),
            NavigationDestination(
              icon: const Icon(Icons.history_outlined),
              selectedIcon: const Icon(Icons.history),
              label: l10n.navVisits,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outlined),
              selectedIcon: const Icon(Icons.person),
              label: l10n.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
