import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../profile/application/settings_controller.dart';
import '../application/study_providers.dart';
import '../domain/scheduler.dart';
import 'review_reminder.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  var _index = 0;
  var _revealed = false;
  var _reviewed = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final settings = ref.watch(settingsProvider);
    final cards = ref.watch(studyCardsProvider).value ?? const <StudyCard>[];
    final days = ref.watch(reviewDaysProvider).value ?? const <DateTime>[];
    final queue = reviewQueue(
      cards,
      DateTime.now(),
      reviewLimit: settings.dailyReviewLimit,
      newLimit: settings.dailyNewLimit,
    );
    final streak = reviewStreak(days, DateTime.now());
    if (_index >= queue.length) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.homeReviewDue)),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(queue.isEmpty && _reviewed == 0 ? l10n.reviewEmpty : l10n.reviewSummary),
              const SizedBox(height: 12),
              Text('${l10n.reviewStreak}: $streak', style: TextStyle(color: colors.secondary)),
              const SizedBox(height: 24),
              Text(l10n.reminderBody, style: TextStyle(color: colors.secondary, height: 1.4)),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => scheduleDailyReview(
                  hour: settings.reviewHour,
                  minute: settings.reviewMinute,
                  title: l10n.reminderTitle,
                  body: l10n.homeReviewDue,
                ),
                child: Text(l10n.reminderAllow),
              ),
            ],
          ),
        ),
      );
    }
    final card = queue[_index];
    const scheduler = Sm2Scheduler();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeReviewDue)),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.prompt, style: TextStyle(fontSize: 22, height: 1.35, color: colors.text)),
            const SizedBox(height: 16),
            if (_revealed)
              Text(card.answer, style: TextStyle(color: colors.secondary, height: 1.4))
            else
              OutlinedButton(onPressed: () => setState(() => _revealed = true), child: Text(l10n.reviewShow)),
            const Spacer(),
            if (_revealed)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final rating in const [(1, 'again'), (3, 'hard'), (4, 'good'), (5, 'easy')])
                    OutlinedButton(
                      onPressed: () => _rate(card, rating.$1),
                      child: Text(_label(l10n, rating.$2, scheduler.previewDays(card.progress, rating.$1))),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _label(AppLocalizations l10n, String key, int days) {
    final name = switch (key) {
      'again' => l10n.reviewAgain,
      'hard' => l10n.reviewHard,
      'easy' => l10n.reviewEasy,
      _ => l10n.reviewGood,
    };
    return '$name · ${days}d';
  }

  Future<void> _rate(StudyCard card, int quality) async {
    await ref.read(studyRepositoryProvider).applyReview(card, quality);
    if (!mounted) return;
    setState(() {
      _index += 1;
      _reviewed += 1;
      _revealed = false;
    });
  }
}
