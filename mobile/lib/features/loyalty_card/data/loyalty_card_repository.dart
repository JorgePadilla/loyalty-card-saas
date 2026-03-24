import 'package:dio/dio.dart';

import 'loyalty_card_model.dart';

class LoyaltyCardRepository {
  final Dio dio;

  LoyaltyCardRepository(this.dio);

  /// GET /api/v1/loyalty_card
  /// Returns the current customer's loyalty card.
  Future<LoyaltyCardModel> getLoyaltyCard() async {
    final response = await dio.get('/loyalty_card');
    final data = response.data as Map<String, dynamic>;
    return LoyaltyCardModel.fromJson(
      data['loyalty_card'] as Map<String, dynamic>,
    );
  }
}
