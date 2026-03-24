import 'package:dio/dio.dart';

class AuthRepository {
  final Dio dio;

  AuthRepository(this.dio);

  /// POST /auth/sign_in with {email, password}
  /// Returns {user: {...}, token: "...", refresh_token: "..."}
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final response = await dio.post('/auth/sign_in', data: {
      'email': email,
      'password': password,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /auth/sign_up with {tenant_slug, email, password, first_name, last_name, phone}
  /// Returns {user: {...}, token: "...", refresh_token: "..."}
  Future<Map<String, dynamic>> signUp({
    required String tenantSlug,
    required String email,
    required String password,
    required String firstName,
    String? lastName,
    String? phone,
  }) async {
    final response = await dio.post('/auth/sign_up', data: {
      'tenant_slug': tenantSlug,
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /auth/refresh with {refresh_token}
  /// Returns {token: "...", refresh_token: "..."}
  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final response = await dio.post('/auth/refresh', data: {
      'refresh_token': refreshToken,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }
}
