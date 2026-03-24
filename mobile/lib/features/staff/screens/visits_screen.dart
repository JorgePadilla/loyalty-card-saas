import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../data/visit_model.dart';
import '../providers/staff_provider.dart';

class VisitsScreen extends ConsumerStatefulWidget {
  const VisitsScreen({super.key});

  @override
  ConsumerState<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends ConsumerState<VisitsScreen> {
  @override
  void initState() {
    super.initState();
    // Load visits on first build.
    Future.microtask(() => ref.read(visitsProvider.notifier).loadVisits());
  }

  Future<void> _onRefresh() async {
    await ref.read(visitsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visitsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text('Recent Visits', style: AppTypography.titleMedium),
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: state.isLoading && state.visits.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.matte),
            )
          : state.error != null && state.visits.isEmpty
              ? _buildError(state.error!)
              : state.visits.isEmpty
                  ? _buildEmpty()
                  : _buildList(state.visits),
    );
  }

  // -----------------------------------------------------------------------
  // Visit list grouped by date
  // -----------------------------------------------------------------------
  Widget _buildList(List<VisitModel> visits) {
    final grouped = _groupByDate(visits);
    final dateKeys = grouped.keys.toList();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.matte,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: dateKeys.length,
        itemBuilder: (context, index) {
          final dateLabel = dateKeys[index];
          final dayVisits = grouped[dateLabel]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index > 0) const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  dateLabel,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ...dayVisits.map((visit) => _VisitCard(visit: visit)),
            ],
          );
        },
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Empty state
  // -----------------------------------------------------------------------
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.history,
                size: 36,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 20),
            Text('No visits yet', style: AppTypography.titleSmall),
            const SizedBox(height: 8),
            Text(
              'Check-in visits will appear here.\nScan a customer QR code to get started.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Error state
  // -----------------------------------------------------------------------
  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => ref.read(visitsProvider.notifier).loadVisits(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.matte,
                side: const BorderSide(color: AppColors.matte),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Group visits by display date
  // -----------------------------------------------------------------------
  Map<String, List<VisitModel>> _groupByDate(List<VisitModel> visits) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final grouped = <String, List<VisitModel>>{};

    for (final visit in visits) {
      final visitDate = DateTime(
        visit.checkedInAt.year,
        visit.checkedInAt.month,
        visit.checkedInAt.day,
      );

      String label;
      if (visitDate == today) {
        label = 'Today';
      } else if (visitDate == yesterday) {
        label = 'Yesterday';
      } else {
        label = DateFormat('MMMM d, yyyy').format(visit.checkedInAt);
      }

      grouped.putIfAbsent(label, () => []).add(visit);
    }

    return grouped;
  }
}

// ---------------------------------------------------------------------------
// Single visit card
// ---------------------------------------------------------------------------

class _VisitCard extends StatelessWidget {
  final VisitModel visit;

  const _VisitCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    final timeFormatted = DateFormat('h:mm a').format(visit.checkedInAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Left: service + customer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.serviceName,
                  style: AppTypography.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  visit.userName ?? 'Customer',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  timeFormatted,
                  style: AppTypography.labelSmall,
                ),
              ],
            ),
          ),

          // Right: amount + points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                visit.formattedAmount,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.matte,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${visit.pointsEarned} pts',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
