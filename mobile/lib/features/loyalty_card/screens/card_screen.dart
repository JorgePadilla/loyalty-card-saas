import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/app_localizations.dart';
import '../data/loyalty_card_model.dart';
import '../data/point_transaction_model.dart';
import '../providers/loyalty_card_provider.dart';
import '../widgets/gold_loyalty_card.dart';

/// The home screen for customers. Displays the premium loyalty card prominently,
/// a stats row below, and a "Recent Activity" list.
class CardScreen extends ConsumerWidget {
  const CardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cardState = ref.watch(loyaltyCardProvider);
    final transactionsState = ref.watch(recentTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(l10n.cardTitle, style: AppTypography.headlineSmall),
      ),
      body: RefreshIndicator(
        color: AppColors.matte,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          await ref.read(loyaltyCardProvider.notifier).refresh();
          ref.invalidate(recentTransactionsProvider);
        },
        child: cardState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.matte),
          ),
          error: (error, _) => _ErrorBody(
            message: l10n.cardLoadError,
            onRetry: () => ref.read(loyaltyCardProvider.notifier).fetch(),
          ),
          data: (card) => _CardContent(
            card: card,
            transactionsState: transactionsState,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main scrollable content
// ---------------------------------------------------------------------------

class _CardContent extends StatelessWidget {
  final LoyaltyCardModel card;
  final AsyncValue<List<PointTransactionModel>> transactionsState;

  const _CardContent({
    required this.card,
    required this.transactionsState,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        // --- Hero loyalty card with entrance animation ---
        GoldLoyaltyCard(
          card: card,
          businessName: l10n.cardBusinessName, // Will be replaced with tenant name
          memberName: l10n.cardMemberName,     // Will be replaced with user name
        )
            .animate()
            .slideY(
              begin: 0.15,
              end: 0,
              duration: 600.ms,
              curve: Curves.easeOutCubic,
            )
            .fadeIn(duration: 500.ms),

        const SizedBox(height: 28),

        // --- Stats row ---
        _StatsRow(card: card)
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms),

        const SizedBox(height: 28),

        // --- Recent Activity ---
        Text(l10n.cardRecentActivity, style: AppTypography.titleMedium)
            .animate()
            .fadeIn(delay: 300.ms, duration: 400.ms),

        const SizedBox(height: 12),

        transactionsState.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.matte),
            ),
          ),
          error: (_, __) => _EmptyActivity(
            message: l10n.cardActivityLoadError,
          ),
          data: (transactions) {
            if (transactions.isEmpty) {
              return _EmptyActivity(
                message: l10n.cardNoActivity,
              );
            }
            // Show at most 5 recent transactions
            final recent = transactions.take(5).toList();
            return Column(
              children: recent
                  .asMap()
                  .entries
                  .map((entry) => _TransactionTile(transaction: entry.value)
                      .animate()
                      .fadeIn(
                        delay: (350 + entry.key * 80).ms,
                        duration: 350.ms,
                      ))
                  .toList(),
            );
          },
        ),

        // Bottom padding for safe area
        const SizedBox(height: 32),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Stats row — Total Points, Visits, Member Since
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  final LoyaltyCardModel card;

  const _StatsRow({required this.card});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pointsFormatted = NumberFormat('#,###').format(card.totalPoints);
    final memberSince = card.lastVisitAt != null
        ? DateFormat('MMM yyyy').format(card.lastVisitAt!)
        : '--';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: l10n.cardStatTotalPoints,
              value: pointsFormatted,
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.border,
          ),
          Expanded(
            child: _StatItem(
              label: l10n.cardStatVisits,
              value: card.visitsCount.toString(),
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.border,
          ),
          Expanded(
            child: _StatItem(
              label: l10n.cardStatMemberSince,
              value: memberSince,
              useMono: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool useMono;

  const _StatItem({
    required this.label,
    required this.value,
    this.useMono = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: useMono
              ? GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.matte,
                )
              : AppTypography.labelLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Transaction tile
// ---------------------------------------------------------------------------

class _TransactionTile extends StatelessWidget {
  final PointTransactionModel transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.isPositive;
    final pointsColor = isPositive ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          // Kind icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: pointsColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPositive ? Icons.add_rounded : Icons.remove_rounded,
              size: 20,
              color: pointsColor,
            ),
          ),

          const SizedBox(width: 12),

          // Description + kind label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: AppTypography.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction.kindLabel}  ·  ${_formatDate(context, transaction.createdAt)}',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Points change
          Text(
            transaction.pointsDisplay,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: pointsColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime dt) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      return l10n.cardTimeMinutesAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return l10n.cardTimeHoursAgo(diff.inHours);
    } else if (diff.inDays < 7) {
      return l10n.cardTimeDaysAgo(diff.inDays);
    }
    return DateFormat('MMM d').format(dt);
  }
}

// ---------------------------------------------------------------------------
// Empty / Error states
// ---------------------------------------------------------------------------

class _EmptyActivity extends StatelessWidget {
  final String message;

  const _EmptyActivity({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Center(
        child: Text(
          message,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.secondary),
          textAlign: TextAlign.center,
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
            child: Text(AppLocalizations.of(context).commonRetry),
          ),
        ],
      ),
    );
  }
}
