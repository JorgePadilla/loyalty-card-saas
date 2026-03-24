import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/providers/auth_provider.dart';
import '../../loyalty_card/data/loyalty_card_model.dart';
import '../../loyalty_card/data/point_transaction_model.dart';
import '../../loyalty_card/data/point_transaction_repository.dart';

// ---------------------------------------------------------------------------
// Providers used by this screen
// ---------------------------------------------------------------------------

/// Provides the [PointTransactionRepository].
final _pointTransactionRepoProvider =
    Provider<PointTransactionRepository>((ref) {
  return PointTransactionRepository(ref.watch(dioProvider));
});

/// Fetches the current user's loyalty card.
final _loyaltyCardProvider = FutureProvider<LoyaltyCardModel?>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/loyalty_card');
    final data = response.data as Map<String, dynamic>;
    return LoyaltyCardModel.fromJson(
      data['loyalty_card'] as Map<String, dynamic>,
    );
  } catch (_) {
    return null;
  }
});

/// Fetches the last 20 point transactions.
final _transactionsProvider =
    FutureProvider<List<PointTransactionModel>>((ref) async {
  final repo = ref.watch(_pointTransactionRepoProvider);
  return repo.getTransactions(page: 1);
});

// ---------------------------------------------------------------------------
// Tier progression thresholds (total points)
// ---------------------------------------------------------------------------

const _tierThresholds = <String, int>{
  'bronze': 0,
  'silver': 500,
  'gold': 1500,
  'platinum': 5000,
};

const _tierOrder = ['bronze', 'silver', 'gold', 'platinum'];

// ---------------------------------------------------------------------------
// Profile screen
// ---------------------------------------------------------------------------

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final cardAsync = ref.watch(_loyaltyCardProvider);
    final transactionsAsync = ref.watch(_transactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text('Profile', style: AppTypography.titleMedium),
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: AppColors.matte,
        onRefresh: () async {
          ref.invalidate(_loyaltyCardProvider);
          ref.invalidate(_transactionsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // -----------------------------------------------------------------
            // User info card
            // -----------------------------------------------------------------
            _UserInfoCard(user: user),
            const SizedBox(height: 20),

            // -----------------------------------------------------------------
            // Tier & progress
            // -----------------------------------------------------------------
            cardAsync.when(
              data: (card) =>
                  card != null ? _TierProgressCard(card: card) : const SizedBox.shrink(),
              loading: () => const _ShimmerPlaceholder(height: 120),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // -----------------------------------------------------------------
            // Points history header
            // -----------------------------------------------------------------
            Text(
              'Points History',
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),

            // -----------------------------------------------------------------
            // Transaction list
            // -----------------------------------------------------------------
            transactionsAsync.when(
              data: (transactions) => transactions.isEmpty
                  ? _buildEmptyTransactions()
                  : Column(
                      children: transactions
                          .map((t) => _TransactionRow(transaction: t))
                          .toList(),
                    ),
              loading: () => const _ShimmerPlaceholder(height: 200),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Could not load history.',
                  textAlign: TextAlign.center,
                  style:
                      AppTypography.bodySmall.copyWith(color: AppColors.error),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // -----------------------------------------------------------------
            // Sign out
            // -----------------------------------------------------------------
            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () => ref.read(authProvider.notifier).signOut(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.matte,
                  side: const BorderSide(color: AppColors.matte),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Sign Out', style: AppTypography.labelLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 40, color: AppColors.secondary),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// User info card
// ---------------------------------------------------------------------------

class _UserInfoCard extends StatelessWidget {
  final dynamic user;

  const _UserInfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName ?? 'Customer';
    final email = user?.email ?? '';
    final first = user?.firstName as String?;
    final last = user?.lastName as String?;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.matte,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                _initials(first, last),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.titleSmall),
                const SizedBox(height: 2),
                Text(email, style: AppTypography.bodySmall),
                const SizedBox(height: 4),
                Text(
                  'Member since ${DateFormat('MMMM yyyy').format(DateTime.now())}',
                  style: AppTypography.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String? first, String? last) {
    final f = (first != null && first.isNotEmpty) ? first[0].toUpperCase() : '';
    final l = (last != null && last.isNotEmpty) ? last[0].toUpperCase() : '';
    return '$f$l'.isNotEmpty ? '$f$l' : '?';
  }
}

// ---------------------------------------------------------------------------
// Tier progress card
// ---------------------------------------------------------------------------

class _TierProgressCard extends StatelessWidget {
  final LoyaltyCardModel card;

  const _TierProgressCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final currentIndex = _tierOrder.indexOf(card.tier);
    final isMaxTier = currentIndex >= _tierOrder.length - 1;

    final nextTier = isMaxTier ? card.tier : _tierOrder[currentIndex + 1];
    final currentThreshold = _tierThresholds[card.tier] ?? 0;
    final nextThreshold = _tierThresholds[nextTier] ?? currentThreshold;

    final progress = isMaxTier
        ? 1.0
        : (nextThreshold - currentThreshold) > 0
            ? ((card.totalPoints - currentThreshold) /
                    (nextThreshold - currentThreshold))
                .clamp(0.0, 1.0)
            : 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tier badge + points
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: card.tierColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: card.tierColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  card.tierLabel,
                  style: AppTypography.labelLarge.copyWith(
                    color: card.tierColor == const Color(0xFFE5E4E1)
                        ? AppColors.matte
                        : card.tierColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${card.currentPoints}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.matte,
                ),
              ),
              const SizedBox(width: 4),
              Text('pts', style: AppTypography.labelSmall),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          if (!isMaxTier) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor:
                    AlwaysStoppedAnimation<Color>(card.tierColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(nextThreshold - card.totalPoints).clamp(0, nextThreshold)} pts to ${nextTier[0].toUpperCase()}${nextTier.substring(1)}',
              style: AppTypography.labelSmall,
            ),
          ] else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 1.0,
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor:
                    AlwaysStoppedAnimation<Color>(card.tierColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Highest tier reached',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction row
// ---------------------------------------------------------------------------

class _TransactionRow extends StatelessWidget {
  final PointTransactionModel transaction;

  const _TransactionRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.isPositive;
    final dateFormatted =
        DateFormat('MMM d, yyyy').format(transaction.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isPositive
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPositive ? Icons.add : Icons.remove,
              size: 18,
              color: isPositive ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 12),

          // Description + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: AppTypography.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(dateFormatted, style: AppTypography.labelSmall),
              ],
            ),
          ),

          // Points
          Text(
            transaction.pointsDisplay,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isPositive ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer placeholder for loading states
// ---------------------------------------------------------------------------

class _ShimmerPlaceholder extends StatelessWidget {
  final double height;

  const _ShimmerPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.matte,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
