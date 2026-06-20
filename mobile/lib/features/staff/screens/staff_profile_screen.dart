import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/language_selector.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/staff_provider.dart';

class StaffProfileScreen extends ConsumerStatefulWidget {
  const StaffProfileScreen({super.key});

  @override
  ConsumerState<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends ConsumerState<StaffProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure visits are loaded so we can compute today's stats.
    Future.microtask(() => ref.read(visitsProvider.notifier).loadVisits());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final firstName = user?['first_name'] as String? ?? '';
    final lastName = user?['last_name'] as String? ?? '';
    final email = user?['email'] as String? ?? '';
    final role = user?['role'] as String? ?? 'staff';
    final fullName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;
    final visitsState = ref.watch(visitsProvider);

    // Compute today's stats from the visit list.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayVisits = visitsState.visits.where((v) {
      final vDate = DateTime(
        v.checkedInAt.year,
        v.checkedInAt.month,
        v.checkedInAt.day,
      );
      return vDate == today;
    }).toList();

    final todayVisitCount = todayVisits.length;
    final todayPointsAwarded =
        todayVisits.fold<int>(0, (sum, v) => sum + v.pointsEarned);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text(l10n.profileTitle, style: AppTypography.titleMedium),
        backgroundColor: AppColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // ---------------------------------------------------------------
          // User info card
          // ---------------------------------------------------------------
          Container(
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
                      _initials(firstName, lastName),
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Name, email, role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isNotEmpty ? fullName : l10n.profileStaff,
                        style: AppTypography.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: AppTypography.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _roleLabel(l10n, role),
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.matte,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ---------------------------------------------------------------
          // Today's stats
          // ---------------------------------------------------------------
          Text(
            l10n.profileTodaysActivity,
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: l10n.profileVisitsToday,
                  value: todayVisitCount.toString(),
                  icon: Icons.people_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: l10n.profilePointsAwarded,
                  value: todayPointsAwarded.toString(),
                  icon: Icons.star_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ---------------------------------------------------------------
          // Language section
          // ---------------------------------------------------------------
          const LanguageSelector(),
          const SizedBox(height: 40),

          // ---------------------------------------------------------------
          // Sign out button
          // ---------------------------------------------------------------
          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () => ref.read(authProvider.notifier).logout(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.matte,
                side: const BorderSide(color: AppColors.matte),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.profileSignOut, style: AppTypography.labelLarge),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final l = last.isNotEmpty ? last[0].toUpperCase() : '';
    return '$f$l'.isNotEmpty ? '$f$l' : '?';
  }

  String _roleLabel(AppLocalizations l10n, String role) {
    switch (role) {
      case 'owner':
        return l10n.profileRoleOwner;
      case 'manager':
        return l10n.profileRoleManager;
      case 'customer':
        return l10n.profileRoleCustomer;
      default:
        return l10n.profileRoleStaff;
    }
  }
}

// ---------------------------------------------------------------------------
// Stat card widget
// ---------------------------------------------------------------------------

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.secondary),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.matte,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}
