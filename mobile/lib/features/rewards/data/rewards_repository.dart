import 'package:dio/dio.dart';

import 'reward_model.dart';

class RewardsRepository {
  final Dio dio;

  RewardsRepository(this.dio);

  /// GET /api/v1/rewards
  /// Returns all active rewards for the current tenant.
  Future<List<RewardModel>> getRewards() async {
    final response = await dio.get('/rewards');
    final data = response.data as Map<String, dynamic>;
    final items = data['rewards'] as List<dynamic>;
    return items
        .map((json) => RewardModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/v1/rewards/:id
  /// Returns a single reward by id.
  Future<RewardModel> getReward(int id) async {
    final response = await dio.get('/rewards/$id');
    final data = response.data as Map<String, dynamic>;
    return RewardModel.fromJson(data['reward'] as Map<String, dynamic>);
  }

  /// POST /api/v1/redemptions
  /// Creates a redemption for the given reward.
  /// Returns the redemption response map.
  Future<Map<String, dynamic>> redeemReward(int rewardId) async {
    final response = await dio.post('/redemptions', data: {
      'reward_id': rewardId,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }
}
