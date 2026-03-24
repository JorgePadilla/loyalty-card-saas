import 'package:dio/dio.dart';

import 'visit_model.dart';

class StaffRepository {
  final Dio dio;

  StaffRepository(this.dio);

  /// POST /api/v1/staff/check_in
  /// Scans customer QR code, creates a visit, and awards points.
  /// Returns the created visit along with customer info.
  Future<Map<String, dynamic>> checkIn({
    required String qrCode,
    required String serviceName,
    required int amountCents,
  }) async {
    final response = await dio.post('/staff/check_in', data: {
      'qr_code': qrCode,
      'service_name': serviceName,
      'amount_cents': amountCents,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// GET /api/v1/staff/visits
  /// Returns a paginated list of recent visits for the current tenant.
  Future<List<VisitModel>> getVisits({int page = 1}) async {
    final response = await dio.get(
      '/staff/visits',
      queryParameters: {'page': page},
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['visits'] as List<dynamic>;
    return items
        .map((json) => VisitModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// PATCH /api/v1/staff/redemptions/:id
  /// Confirms a pending redemption.
  Future<Map<String, dynamic>> confirmRedemption(int id) async {
    final response = await dio.patch('/staff/redemptions/$id', data: {
      'status': 'confirmed',
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// PATCH /api/v1/staff/redemptions/:id
  /// Rejects a pending redemption (sets status to expired).
  Future<Map<String, dynamic>> rejectRedemption(int id) async {
    final response = await dio.patch('/staff/redemptions/$id', data: {
      'status': 'expired',
    });
    return Map<String, dynamic>.from(response.data as Map);
  }
}
