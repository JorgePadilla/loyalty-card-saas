import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../loyalty_card/providers/loyalty_card_provider.dart';
import '../data/reward_model.dart';
import '../providers/rewards_provider.dart';

/// Detail view for a single reward. Shows full description, points cost,
/// and a redeem button with a confirmation dialog.
class RewardDetailScreen extends ConsumerStatefulWidget {
  final int rewardId;

  const RewardDetailScreen({super.key, required this.rewardId});

  @override
  ConsumerState<RewardDetailScreen> createState() => _RewardDetailScreenState();
}

class _RewardDetailScreenState extends ConsumerState<RewardDetailScreen> {
  bool _redeemed = false;

  @override
  Widget build(BuildContext context) {
    final rewardState = ref.watch(rewardDetailProvider(widget.rewardId));
    final cardState = ref.watch(loyaltyCardProvider);
    final redeemState = ref.watch(redeemProvider);
    final currentPoints = cardState.valueOrNull?.currentPoints ?? 0;
    final currentTier = cardState.valueOrNull?.tier ?? 'bronze';

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
        title: Text('Reward Details', style: AppTypography.titleMedium),
        centerTitle: true,
      ),
      body: rewardState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.matte),
        ),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.secondary),
              const SizedBox(height: 12),
              Text('Could not load reward.', style: AppTypography.bodyMedium),
            ],
          ),
        ),
        data: (reward) {
          final canAfford = currentPoints >= reward.pointsCost;
          final isTierLocked = _isTierLocked(reward, currentTier);
          final isRedeeming = redeemState is AsyncLoading;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Success state banner
                      if (_redeemed) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.success.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Reward Redeemed!',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Show this to staff to claim your reward.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.success,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Reward detail card
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
                            // Reward type label
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.matte.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _rewardTypeLabel(reward.rewardType),
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.matte,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Name
                            Text(
                              reward.name,
                              style: AppTypography.headlineSmall,
                            ),
                            const SizedBox(height: 20),

                            // Points cost — prominent
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${reward.pointsCost}',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.matte,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'points',
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),

                            if (reward.hasTierRequirement) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isTierLocked
                                      ? AppColors.secondary.withOpacity(0.08)
                                      : AppColors.success.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isTierLocked
                                          ? Icons.lock_rounded
                                          : Icons.check_rounded,
                                      size: 14,
                                      color: isTierLocked
                                          ? AppColors.secondary
                                          : AppColors.success,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Requires ${reward.tierRequiredLabel} tier',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: isTierLocked
                                            ? AppColors.secondary
                                            : AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Divider
                            Container(
                              height: 1,
                              color: AppColors.border,
                            ),
                            const SizedBox(height: 20),

                            // Full description
                            Text(
                              reward.description,
                              style: AppTypography.bodyLarge,
                            ),
                          ],
                        ),
                      ),

                      // Your balance context
                      if (!_redeemed) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Your balance',
                                style: AppTypography.bodyMedium,
                              ),
                              Text(
                                '$currentPoints pts',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: canAfford
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom redeem button
              if (!_redeemed)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Tooltip(
                        message: !canAfford
                            ? 'You need ${reward.pointsCost - currentPoints} more points'
                            : isTierLocked
                                ? 'Requires ${reward.tierRequiredLabel} tier'
                                : '',
                        child: ElevatedButton(
                          onPressed:
                              canAfford && !isTierLocked && !isRedeeming
                                  ? () => _confirmRedeem(context, reward)
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
                                  canAfford && !isTierLocked
                                      ? 'Redeem for ${reward.pointsCost} points'
                                      : isTierLocked
                                          ? '${reward.tierRequiredLabel} Tier Required'
                                          : 'Not enough points',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  bool _isTierLocked(RewardModel reward, String currentTier) {
    if (!reward.hasTierRequirement) return false;
    const tierOrder = ['bronze', 'silver', 'gold', 'platinum'];
    final requiredIdx = tierOrder.indexOf(reward.tierRequired!);
    final currentIdx = tierOrder.indexOf(currentTier);
    return currentIdx < requiredIdx;
  }

  String _rewardTypeLabel(String type) {
    switch (type) {
      case 'discount':
        return 'Discount';
      case 'free_item':
        return 'Free Item';
      case 'service':
        return 'Service';
      case 'merchandise':
        return 'Merchandise';
      default:
        return type[0].toUpperCase() + type.substring(1);
    }
  }

  void _confirmRedeem(BuildContext context, RewardModel reward) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Redeem Reward', style: AppTypography.titleMedium),
        content: RichText(
          text: TextSpan(
            style: AppTypography.bodyMedium,
            children: [
              const TextSpan(text: 'Spend '),
              TextSpan(
                text: '${reward.pointsCost} points',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.matte,
                ),
              ),
              TextSpan(text: ' to redeem "${reward.name}"?'),
            ],
          ),
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
              final success = await ref
                  .read(redeemProvider.notifier)
                  .redeem(reward.id);
              if (mounted) {
                if (success) {
                  setState(() => _redeemed = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Reward redeemed successfully!'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          'Could not redeem reward. Please try again.'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
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
