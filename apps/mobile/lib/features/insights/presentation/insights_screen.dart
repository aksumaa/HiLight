import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../study/application/study_providers.dart';
import '../../study/domain/scheduler.dart';
import '../../study/domain/vocab_word.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final words = ref.watch(vocabProvider).value ?? const <VocabWord>[];
    final days = ref.watch(reviewDaysProvider).value ?? const <DateTime>[];
    final items = ref.watch(libraryItemsProvider).value ?? const [];
    final books = ref.watch(booksProvider).value ?? const [];
    final learned = words.where((word) => word.mastery == WordMastery.known).length;
    final streak = reviewStreak(days, DateTime.now());
    final counts = <String, int>{};
    for (final item in items) {
      if (item.bookId == null) continue;
      counts[item.bookId!] = (counts[item.bookId!] ?? 0) + 1;
    }
    final week = _weekCounts(items.map((item) => item.createdAt));
    final empty = words.isEmpty && items.isEmpty && days.isEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.insightsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          if (empty) Text(l10n.insightsEmpty, style: TextStyle(color: colors.secondary, height: 1.4)),
          _Stat(label: l10n.reviewStreak, value: '$streak'),
          _Stat(label: l10n.insightsWords, value: '$learned'),
          const SizedBox(height: 16),
          Text(l10n.insightsWeek, style: TextStyle(color: colors.secondary, fontSize: 13)),
          const SizedBox(height: 8),
          SizedBox(height: 80, child: _WeekChart(counts: week)),
          const SizedBox(height: 16),
          Text(l10n.insightsPerBook, style: TextStyle(color: colors.secondary, fontSize: 13)),
          const SizedBox(height: 8),
          if (counts.isEmpty)
            Text(l10n.bookNoHighlights, style: TextStyle(color: colors.secondary))
          else
            for (final entry in counts.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${books.where((book) => book.id == entry.key).firstOrNull?.title ?? entry.key}: ${entry.value}',
                ),
              ),
        ],
      ),
    );
  }

  List<int> _weekCounts(Iterable<DateTime> times) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 6));
    final counts = List<int>.filled(7, 0);
    for (final time in times) {
      final day = DateTime(time.year, time.month, time.day);
      final index = day.difference(start).inDays;
      if (index >= 0 && index < 7) counts[index] += 1;
    }
    return counts;
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.hilight;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: colors.surface(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 28, color: colors.text, fontWeight: FontWeight.w500)),
              Text(label, style: TextStyle(color: colors.secondary, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.counts});

  final List<int> counts;

  @override
  Widget build(BuildContext context) {
    final colors = context.hilight;
    final maxCount = counts.fold<int>(1, (max, value) => value > max ? value : max);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final count in counts)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 8 + 64 * (count / maxCount),
                  decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
