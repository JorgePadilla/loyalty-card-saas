import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env_config.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';

/// Singleton-style API client backed by Dio.
///
/// Usage:
/// ```dart
/// final client = ApiClient(secureStorage: storage);
/// final response = await client.dio.get('/rewards');
/// ```
class ApiClient {
  ApiClient({
    required SecureStorage secureStorage,
    String? baseUrl,
    VoidCallback? onAuthFailure,
  }) : _secureStorage = secureStorage {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? _defaultBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    // Auth interceptor — attaches token, handles refresh.
    _dio.interceptors.add(
      AuthInterceptor(
        secureStorage: _secureStorage,
        dio: _dio,
        onAuthFailure: onAuthFailure,
      ),
    );

    // Logging interceptor — only in debug mode.
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const _defaultBaseUrl = EnvConfig.apiBaseUrl;

  // ---------------------------------------------------------------------------
  // Fields
  // ---------------------------------------------------------------------------

  final SecureStorage _secureStorage;
  late final Dio _dio;

  /// The underlying Dio instance for making HTTP calls.
  Dio get dio => _dio;

  // ---------------------------------------------------------------------------
  // Convenience methods
  // ---------------------------------------------------------------------------

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.patch<T>(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(path,
        data: data, queryParameters: queryParameters, options: options);
  }
}
