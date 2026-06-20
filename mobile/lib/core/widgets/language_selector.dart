import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../l10n/app_localizations.dart';

/// A "Language" section with English/Spanish options. Reflects the active
/// locale and persists the choice via [localeProvider].
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(localeProvider)?.languageCode ?? 'en';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.language,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _option(
                ref,
                code: 'en',
                label: l10n.languageEnglish,
                selected: current == 'en',
              ),
              Divider(height: 1, color: AppColors.border),
              _option(
                ref,
                code: 'es',
                label: l10n.languageSpanish,
                selected: current == 'es',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _option(
    WidgetRef ref, {
    required String code,
    required String label,
    required bool selected,
  }) {
    return ListTile(
      leading: const Icon(Icons.language_rounded, color: AppColors.matte, size: 22),
      title: Text(label, style: AppTypography.bodyMedium),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.matte, size: 22)
          : null,
      onTap: () => ref.read(localeProvider.notifier).setLocale(code),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
