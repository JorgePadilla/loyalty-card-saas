import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../data/reward_model.dart';
import '../data/rewards_repository.dart';
import '../../loyalty_card/providers/loyalty_card_provider.dart';

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

final rewardsRepositoryProvider = Provider<RewardsRepository>((ref) {
  return RewardsRepository(ref.watch(apiClientProvider).dio);
});

// ---------------------------------------------------------------------------
// Rewards list
// ---------------------------------------------------------------------------

class RewardsNotifier extends StateNotifier<AsyncValue<List<RewardModel>>> {
  final RewardsRepository _repository;

  RewardsNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final rewards = await _repository.getRewards();
      state = AsyncValue.data(rewards);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    try {
      final rewards = await _repository.getRewards();
      state = AsyncValue.data(rewards);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final rewardsProvider =
    StateNotifierProvider<RewardsNotifier, AsyncValue<List<RewardModel>>>(
  (ref) => RewardsNotifier(ref.watch(rewardsRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Single reward detail
// ---------------------------------------------------------------------------

final rewardDetailProvider =
    FutureProvider.family<RewardModel, int>((ref, id) async {
  final repo = ref.watch(rewardsRepositoryProvider);
  return repo.getReward(id);
});

// ---------------------------------------------------------------------------
// Redeem action
// ---------------------------------------------------------------------------

class RedeemNotifier extends StateNotifier<AsyncValue<void>> {
  final RewardsRepository _repository;
  final Ref _ref;

  RedeemNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  Future<bool> redeem(int rewardId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.redeemReward(rewardId);
      state = const AsyncValue.data(null);

      // Refresh the loyalty card (points changed) and rewards list.
      _ref.read(loyaltyCardProvider.notifier).refresh();
      _ref.read(rewardsProvider.notifier).refresh();
      _ref.invalidate(recentTransactionsProvider);

      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }
}

final redeemProvider =
    StateNotifierProvider<RedeemNotifier, AsyncValue<void>>((ref) {
  return RedeemNotifier(ref.watch(rewardsRepositoryProvider), ref);
});
