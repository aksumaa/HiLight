import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_providers.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/hilight_colors.dart';
import '../../core/theme/hilight_theme.dart';

class LanguageChips extends ConsumerWidget {
  const LanguageChips({this.value, this.onChanged, super.key});

  final String? value;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = value ?? ref.watch(captureLanguageProvider);
    final colors = context.hilight;
    const codes = ['en', 'ru', 'uz'];
    final labels = {
      'en': l10n.languageEnglish,
      'ru': l10n.languageRussian,
      'uz': l10n.languageUzbek,
    };
    return Wrap(
      spacing: 8,
      children: [
        for (final code in codes)
          ChoiceChip(
            label: Text(labels[code]!),
            selected: selected == code,
            selectedColor: colors.primary,
            labelStyle: TextStyle(
              fontFamily: HilightTheme.uiFont,
              color: selected == code ? colors.card : colors.text,
            ),
            backgroundColor: colors.card,
            side: BorderSide(color: colors.secondary.withValues(alpha: 0.35)),
            onSelected: (_) async {
              if (onChanged != null) {
                onChanged!(code);
              } else {
                await ref.read(captureLanguageProvider.notifier).select(code);
              }
            },
          ),
      ],
    );
  }
}
