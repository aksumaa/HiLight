import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../core/theme/hilight_theme.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.insightsTitle)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: DecoratedBox(
          decoration: colors.surface(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.insightsBody,
              style: TextStyle(
                fontFamily: HilightTheme.uiFont,
                height: 1.45,
                color: colors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
