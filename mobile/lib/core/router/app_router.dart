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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.credit_card_outlined),
              selectedIcon: Icon(Icons.credit_card),
              label: 'My Card',
            ),
            NavigationDestination(
              icon: Icon(Icons.card_giftcard_outlined),
              selectedIcon: Icon(Icons.card_giftcard),
              label: 'Rewards',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.qr_code_scanner_outlined),
              selectedIcon: Icon(Icons.qr_code_scanner),
              label: 'Scanner',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'Visits',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
