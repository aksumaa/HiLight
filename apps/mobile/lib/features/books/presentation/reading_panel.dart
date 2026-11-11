import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../data/models/library_item.dart';
import '../../profile/application/settings_controller.dart';
import '../domain/reading.dart';
import '../domain/shelf_book.dart';

class ReadingLog {
  ReadingLog(this.preferences);

  final SharedPreferences preferences;
  static const dayKey = 'reading_day';
  static const secondsKey = 'reading_seconds';
  static const finishedKey = 'finished_books';

  int todaySeconds(DateTime now) {
    return secondsCountedToday(
      storedDay: preferences.getString(dayKey),
      today: readingDay(now),
      storedSeconds: preferences.getInt(secondsKey) ?? 0,
    );
  }

  Future<void> add(int seconds, DateTime now) async {
    final total = todaySeconds(now) + seconds;
    await preferences.setString(dayKey, readingDay(now));
    await preferences.setInt(secondsKey, total);
  }

  bool marked(String id) => preferences.getStringList(finishedKey)?.contains(id) ?? false;

  Future<void> markFinished(String id) async {
    final current = preferences.getStringList(finishedKey) ?? const <String>[];
    if (current.contains(id)) return;
    await preferences.setStringList(finishedKey, [...current, id]);
  }
}

final readingLogProvider = Provider<ReadingLog>((ref) {
  return ReadingLog(ref.watch(sharedPreferencesProvider));
});

class ReadingPanel extends ConsumerStatefulWidget {
  const ReadingPanel({required this.book, required this.highlights, super.key});

  final ShelfBook book;
  final List<LibraryItem> highlights;

  @override
  ConsumerState<ReadingPanel> createState() => _ReadingPanelState();
}

class _ReadingPanelState extends ConsumerState<ReadingPanel> {
  DateTime? _started;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    final goal = ref.watch(settingsProvider).dailyReadingMinutes;
    final log = ref.watch(readingLogProvider);
    final stored = log.todaySeconds(DateTime.now());
    final elapsed = _started == null ? 0 : DateTime.now().difference(_started!).inSeconds;
    final seconds = stored + elapsed;
    final furthest = furthestPage(widget.highlights.map((item) => item.page));
    final complete = bookIsComplete(
      totalPages: widget.book.totalPages,
      furthest: furthest,
      marked: log.marked(widget.book.id),
    );
    final minutes = seconds ~/ 60;
    return DecoratedBox(
      decoration: colors.surface(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              complete ? l10n.readingDone : l10n.readingToday(minutes, goal),
              style: TextStyle(color: colors.text, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _started == null ? _start : _stop,
                  child: Text(_started == null ? l10n.readingStart : l10n.readingStop),
                ),
                if (!complete)
                  TextButton(
                    onPressed: () async {
                      await log.markFinished(widget.book.id);
                      setState(() {});
                    },
                    child: Text(l10n.readingMarkDone),
                  ),
                TextButton(
                  onPressed: () {
                    final next = switch (goal) {
                      15 => 20,
                      20 => 30,
                      30 => 45,
                      _ => 15,
                    };
                    ref.read(settingsProvider.notifier).setReadingGoal(next);
                  },
                  child: Text(l10n.readingGoal(goal)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _start() {
    setState(() => _started = DateTime.now());
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _stop() async {
    final started = _started;
    _ticker?.cancel();
    if (started != null) {
      final seconds = DateTime.now().difference(started).inSeconds;
      if (seconds > 0) await ref.read(readingLogProvider).add(seconds, DateTime.now());
    }
    if (mounted) setState(() => _started = null);
  }
}
