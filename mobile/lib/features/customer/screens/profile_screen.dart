import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/language_selector.dart';
import '../../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final firstName = user?['first_name'] as String? ?? '';
    final lastName = user?['last_name'] as String? ?? '';
    final email = user?['email'] as String? ?? '';
    final role = user?['role'] as String? ?? 'customer';
    final fullName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;

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
          // -----------------------------------------------------------------
          // User info card
          // -----------------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isNotEmpty ? fullName : l10n.profileMember,
                        style: AppTypography.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(email, style: AppTypography.bodySmall),
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
          const SizedBox(height: 24),

          // -----------------------------------------------------------------
          // Language section
          // -----------------------------------------------------------------
          const LanguageSelector(),
          const SizedBox(height: 24),

          // -----------------------------------------------------------------
          // Settings section
          // -----------------------------------------------------------------
          Text(
            l10n.profileSettings,
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: l10n.profileNotifications,
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            label: l10n.profileHelpSupport,
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            label: l10n.profileAbout,
            onTap: () {},
          ),
          const SizedBox(height: 32),

          // -----------------------------------------------------------------
          // Sign out button
          // -----------------------------------------------------------------
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
      case 'staff':
        return l10n.profileRoleStaff;
      default:
        return l10n.profileRoleCustomer;
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.matte, size: 22),
        title: Text(label, style: AppTypography.bodyMedium),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.secondary.withValues(alpha: 0.5),
          size: 22,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
