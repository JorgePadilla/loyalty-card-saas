import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/auth_provider.dart';
import '../data/loyalty_card_model.dart';
import '../data/loyalty_card_repository.dart';
import '../data/point_transaction_model.dart';
import '../data/point_transaction_repository.dart';

// ---------------------------------------------------------------------------
// Repository providers
// ---------------------------------------------------------------------------

final loyaltyCardRepositoryProvider = Provider<LoyaltyCardRepository>((ref) {
  return LoyaltyCardRepository(ref.watch(apiClientProvider).dio);
});

final pointTransactionRepositoryProvider =
    Provider<PointTransactionRepository>((ref) {
  return PointTransactionRepository(ref.watch(apiClientProvider).dio);
});

// ---------------------------------------------------------------------------
// Loyalty Card state
// ---------------------------------------------------------------------------

class LoyaltyCardNotifier extends StateNotifier<AsyncValue<LoyaltyCardModel>> {
  final LoyaltyCardRepository _repository;

  LoyaltyCardNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final card = await _repository.getLoyaltyCard();
      state = AsyncValue.data(card);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Pull-to-refresh: re-fetch without showing a loading spinner.
  Future<void> refresh() async {
    try {
      final card = await _repository.getLoyaltyCard();
      state = AsyncValue.data(card);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final loyaltyCardProvider =
    StateNotifierProvider<LoyaltyCardNotifier, AsyncValue<LoyaltyCardModel>>(
  (ref) => LoyaltyCardNotifier(ref.watch(loyaltyCardRepositoryProvider)),
);

// ---------------------------------------------------------------------------
// Recent transactions (last 5) for the card screen
// ---------------------------------------------------------------------------

final recentTransactionsProvider =
    FutureProvider<List<PointTransactionModel>>((ref) async {
  final repo = ref.watch(pointTransactionRepositoryProvider);
  return repo.getTransactions(page: 1);
});
