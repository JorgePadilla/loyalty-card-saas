import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/config/env_config.dart';
import '../data/auth_repository.dart';
import '../data/user_model.dart';

// ---------------------------------------------------------------------------
// Auth State
// ---------------------------------------------------------------------------

class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  String toString() =>
      'AuthState(isAuthenticated: $isAuthenticated, isLoading: $isLoading, '
      'user: $user, error: $error)';
}

// ---------------------------------------------------------------------------
// Auth Notifier
// ---------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'auth_refresh_token';
  static const _userKey = 'auth_user';

  AuthNotifier({
    required AuthRepository repository,
    required FlutterSecureStorage storage,
  })  : _repository = repository,
        _storage = storage,
        super(const AuthState());

  // -----------------------------------------------------------------------
  // Check stored credentials on app launch
  // -----------------------------------------------------------------------
  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final token = await _storage.read(key: _tokenKey);
      final userJson = await _storage.read(key: _userKey);

      if (token != null && userJson != null) {
        final user = UserModel.fromJson(
          Map<String, dynamic>.from(jsonDecode(userJson) as Map),
        );
        state = AuthState(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = const AuthState(isLoading: false);
      }
    } catch (_) {
      // Corrupt storage — treat as signed out.
      await _clearStorage();
      state = const AuthState(isLoading: false);
    }
  }

  // -----------------------------------------------------------------------
  // Sign in
  // -----------------------------------------------------------------------
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final data = await _repository.signIn(email, password);
      await _persistSession(data);
    } on DioException catch (e) {
      final message = _extractError(e);
      state = state.copyWith(isLoading: false, error: message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // -----------------------------------------------------------------------
  // Sign up
  // -----------------------------------------------------------------------
  Future<void> signUp({
    required String tenantSlug,
    required String email,
    required String password,
    required String firstName,
    String? lastName,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final data = await _repository.signUp(
        tenantSlug: tenantSlug,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      await _persistSession(data);
    } on DioException catch (e) {
      final message = _extractError(e);
      state = state.copyWith(isLoading: false, error: message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // -----------------------------------------------------------------------
  // Sign out
  // -----------------------------------------------------------------------
  Future<void> signOut() async {
    await _clearStorage();
    state = const AuthState();
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  Future<void> _persistSession(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    final refreshToken = data['refresh_token'] as String;
    final userMap = Map<String, dynamic>.from(data['user'] as Map);
    final user = UserModel.fromJson(userMap);

    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userKey, value: jsonEncode(userMap));

    state = AuthState(
      user: user,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  Future<void> _clearStorage() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('error')) {
      return data['error'] as String;
    }
    if (data is Map && data.containsKey('errors')) {
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.join(', ');
      }
    }
    if (e.response?.statusCode == 401) {
      return 'Invalid email or password.';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Unable to connect to the server.';
    }
    return 'Something went wrong. Please try again.';
  }
}

// ---------------------------------------------------------------------------
// Provider definitions
// ---------------------------------------------------------------------------

/// Provides the [FlutterSecureStorage] instance used throughout the app.
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

/// Provides a [Dio] instance configured with the API base URL.
/// Override this provider in tests or when configuring the base URL.
final dioProvider = Provider<Dio>((_) {
  return Dio(BaseOptions(
    baseUrl: EnvConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
});

/// Provides the [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

/// Provides the [AuthNotifier] and its [AuthState].
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    repository: ref.watch(authRepositoryProvider),
    storage: ref.watch(secureStorageProvider),
  );
});
