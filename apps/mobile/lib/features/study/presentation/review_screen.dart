import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeReviewDue)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(l10n.todayReviewEmpty),
      ),
    );
  }
}
