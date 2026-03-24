import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/secure_storage.dart';

/// Dio interceptor that attaches the JWT access token to every request and
/// handles transparent token refresh on 401 responses.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required SecureStorage secureStorage,
    required Dio dio,
    VoidCallback? onAuthFailure,
  })  : _secureStorage = secureStorage,
        _dio = dio,
        _onAuthFailure = onAuthFailure;

  final SecureStorage _secureStorage;
  final Dio _dio;
  final VoidCallback? _onAuthFailure;

  bool _isRefreshing = false;

  // ---------------------------------------------------------------------------
  // Attach access token on request
  // ---------------------------------------------------------------------------

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ---------------------------------------------------------------------------
  // Handle 401 — attempt token refresh
  // ---------------------------------------------------------------------------

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Don't attempt refresh if the failing request is itself the refresh call.
    final requestPath = err.requestOptions.path;
    if (requestPath.contains('/auth/refresh')) {
      await _handleAuthFailure();
      return handler.next(err);
    }

    if (_isRefreshing) {
      return handler.next(err);
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _handleAuthFailure();
        return handler.next(err);
      }

      // Call the refresh endpoint using a fresh Dio instance to avoid
      // interceptor recursion.
      final refreshDio = Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: _dio.options.connectTimeout,
        receiveTimeout: _dio.options.receiveTimeout,
        contentType: 'application/json',
      ));

      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data['access_token'] as String?;
      final newRefreshToken = response.data['refresh_token'] as String?;

      if (newAccessToken == null) {
        await _handleAuthFailure();
        return handler.next(err);
      }

      // Persist the new tokens.
      await _secureStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken ?? refreshToken,
      );

      // Retry the original request with the new token.
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $newAccessToken';

      final retryResponse = await _dio.fetch(options);
      return handler.resolve(retryResponse);
    } on DioException {
      await _handleAuthFailure();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Auth failure — clear tokens, notify listener
  // ---------------------------------------------------------------------------

  Future<void> _handleAuthFailure() async {
    await _secureStorage.clearAll();
    _onAuthFailure?.call();
  }
}
