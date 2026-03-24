import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../storage/secure_storage.dart';

// =============================================================================
// Auth state
// =============================================================================

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.userRole,
    this.user,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        userRole = null,
        user = null;

  const AuthState.authenticated({
    required String this.userRole,
    required Map<String, dynamic> this.user,
  }) : status = AuthStatus.authenticated;

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        userRole = null,
        user = null;

  final AuthStatus status;

  /// One of: owner, manager, staff, customer
  final String? userRole;

  /// Raw user JSON from the API / secure storage.
  final Map<String, dynamic>? user;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isStaff =>
      userRole == 'staff' || userRole == 'manager' || userRole == 'owner';
  bool get isCustomer => userRole == 'customer';
}

// =============================================================================
// Providers
// =============================================================================

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final authNotifier = ref.read(authProvider.notifier);
  return ApiClient(
    secureStorage: storage,
    onAuthFailure: () {
      authNotifier.logout();
    },
  );
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(secureStorage: storage);
});

// =============================================================================
// Auth notifier
// =============================================================================

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({required SecureStorage secureStorage})
      : _secureStorage = secureStorage,
        super(const AuthState.initial());

  final SecureStorage _secureStorage;

  /// Check stored tokens and hydrate auth state on app startup.
  Future<void> checkAuthStatus() async {
    final token = await _secureStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      state = const AuthState.unauthenticated();
      return;
    }

    final user = await _secureStorage.getUser();
    if (user == null) {
      state = const AuthState.unauthenticated();
      return;
    }

    final role = user['role'] as String? ?? 'customer';
    state = AuthState.authenticated(userRole: role, user: user);
  }

  /// Persist tokens + user after a successful login/register API response.
  Future<void> loginSuccess({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    await _secureStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _secureStorage.saveUser(user);

    final role = user['role'] as String? ?? 'customer';
    state = AuthState.authenticated(userRole: role, user: user);
  }

  /// Clear tokens and return to unauthenticated state.
  Future<void> logout() async {
    await _secureStorage.clearAll();
    state = const AuthState.unauthenticated();
  }

  /// Update the cached user data (e.g. after a profile update).
  Future<void> updateUser(Map<String, dynamic> user) async {
    await _secureStorage.saveUser(user);
    final role = user['role'] as String? ?? state.userRole ?? 'customer';
    state = AuthState.authenticated(userRole: role, user: user);
  }
}
