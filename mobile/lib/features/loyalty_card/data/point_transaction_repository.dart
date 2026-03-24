import 'package:dio/dio.dart';

import 'point_transaction_model.dart';

class PointTransactionRepository {
  final Dio dio;

  PointTransactionRepository(this.dio);

  /// GET /api/v1/point_transactions
  /// Returns a paginated list of point transactions.
  Future<List<PointTransactionModel>> getTransactions({int page = 1}) async {
    final response = await dio.get(
      '/point_transactions',
      queryParameters: {'page': page},
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['point_transactions'] as List<dynamic>;
    return items
        .map((json) => PointTransactionModel.fromJson(
              json as Map<String, dynamic>,
            ))
        .toList();
  }
}
