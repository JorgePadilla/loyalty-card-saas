import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../loyalty_card/providers/loyalty_card_provider.dart';
import '../data/reward_model.dart';
import '../providers/rewards_provider.dart';

/// Rewards catalog screen. Displays available rewards as a list of cards,
/// each showing name, points cost, description, and tier requirements.
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsState = ref.watch(rewardsProvider);
    final cardState = ref.watch(loyaltyCardProvider);

    final currentPoints = cardState.valueOrNull?.currentPoints ?? 0;
    final currentTier = cardState.valueOrNull?.tier ?? 'bronze';

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text('Rewards', style: AppTypography.headlineSmall),
      ),
      body: RefreshIndicator(
        color: AppColors.matte,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          await ref.read(rewardsProvider.notifier).refresh();
          await ref.read(loyaltyCardProvider.notifier).refresh();
        },
        child: rewardsState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.matte),
          ),
          error: (error, _) => _ErrorBody(
            message: 'Could not load rewards.',
            onRetry: () => ref.read(rewardsProvider.notifier).fetch(),
          ),
          data: (rewards) {
            if (rewards.isEmpty) {
              return _EmptyRewards();
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: rewards.length + 1, // +1 for bottom padding
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == rewards.length) {
                  return const SizedBox(height: 24);
                }
                return _RewardCard(
                  reward: rewards[index],
                  currentPoints: currentPoints,
                  currentTier: currentTier,
                  onTap: () => _navigateToDetail(context, rewards[index].id),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, int rewardId) {
    // Navigate using GoRouter or Navigator.push. Using Navigator.push here
    // for self-contained operation; swap to GoRouter route if wired up.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _RewardDetailRouteProxy(rewardId: rewardId),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reward Card
// ---------------------------------------------------------------------------

class _RewardCard extends StatelessWidget {
  final RewardModel reward;
  final int currentPoints;
  final String currentTier;
  final VoidCallback onTap;

  const _RewardCard({
    required this.reward,
    required this.currentPoints,
    required this.currentTier,
    required this.onTap,
  });

  bool get _canAfford => currentPoints >= reward.pointsCost;

  bool get _isTierLocked {
    if (!reward.hasTierRequirement) return false;
    const tierOrder = ['bronze', 'silver', 'gold', 'platinum'];
    final requiredIdx = tierOrder.indexOf(reward.tierRequired!);
    final currentIdx = tierOrder.indexOf(currentTier);
    return currentIdx < requiredIdx;
  }

  @override
  Widget build(BuildContext context) {
    final locked = _isTierLocked;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            // Reward info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          reward.name,
                          style: AppTypography.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (locked) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.lock_rounded,
                                size: 12,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                reward.tierRequiredLabel,
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reward.description,
                    style: AppTypography.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Points cost + visual indicator
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${reward.pointsCost}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _canAfford && !locked
                        ? AppColors.matte
                        : AppColors.secondary,
                  ),
                ),
                Text(
                  'pts',
                  style: AppTypography.labelSmall.copyWith(fontSize: 10),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondary.withOpacity(0.5),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Proxy to import RewardDetailScreen lazily so this file stays self-contained
// during development. Replace with GoRouter when routing is wired up.
// ---------------------------------------------------------------------------

class _RewardDetailRouteProxy extends StatelessWidget {
  final int rewardId;
  const _RewardDetailRouteProxy({required this.rewardId});

  @override
  Widget build(BuildContext context) {
    // Lazy import to avoid circular dependency issues during scaffolding.
    // This simply delegates to the detail screen.
    return _LazyRewardDetail(rewardId: rewardId);
  }
}

class _LazyRewardDetail extends ConsumerWidget {
  final int rewardId;
  const _LazyRewardDetail({required this.rewardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Import inline; will be replaced with GoRouter navigation.
    return RewardDetailScreenInline(rewardId: rewardId);
  }
}

/// Inline detail screen used as navigation target from this file.
/// The canonical version is in reward_detail_screen.dart but this avoids
/// import cycles during the scaffolding phase.
class RewardDetailScreenInline extends ConsumerWidget {
  final int rewardId;
  const RewardDetailScreenInline({super.key, required this.rewardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardState = ref.watch(rewardDetailProvider(rewardId));
    final cardState = ref.watch(loyaltyCardProvider);
    final redeemState = ref.watch(redeemProvider);
    final currentPoints = cardState.valueOrNull?.currentPoints ?? 0;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.matte),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: rewardState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.matte),
        ),
        error: (_, __) => const Center(child: Text('Could not load reward.')),
        data: (reward) {
          final canAfford = currentPoints >= reward.pointsCost;
          final isRedeeming = redeemState is AsyncLoading;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reward card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reward.name, style: AppTypography.headlineSmall),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            '${reward.pointsCost}',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: AppColors.matte,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('points', style: AppTypography.bodyMedium),
                        ],
                      ),
                      if (reward.hasTierRequirement) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Requires ${reward.tierRequiredLabel} tier',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(reward.description, style: AppTypography.bodyLarge),
                    ],
                  ),
                ),

                const Spacer(),

                // Redeem button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: canAfford && !isRedeeming
                        ? () => _confirmRedeem(context, ref, reward)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.matte,
                      disabledBackgroundColor: AppColors.border,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: AppColors.secondary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isRedeeming
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            canAfford
                                ? 'Redeem for ${reward.pointsCost} points'
                                : 'Not enough points (${currentPoints}/${reward.pointsCost})',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmRedeem(
    BuildContext context,
    WidgetRef ref,
    RewardModel reward,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Redeem Reward', style: AppTypography.titleMedium),
        content: Text(
          'Spend ${reward.pointsCost} points to redeem "${reward.name}"?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success =
                  await ref.read(redeemProvider.notifier).redeem(reward.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Reward redeemed successfully!'
                          : 'Could not redeem reward. Please try again.',
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
                if (success) {
                  Navigator.of(context).pop();
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.matte),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty / Error states
// ---------------------------------------------------------------------------

class _EmptyRewards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.card_giftcard_rounded,
              size: 48,
              color: AppColors.secondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No rewards available yet.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: AppColors.secondary),
          const SizedBox(height: 12),
          Text(message, style: AppTypography.bodyMedium),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: AppColors.matte),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
