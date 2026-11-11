class CardProgress {
  const CardProgress({
    required this.ease,
    required this.intervalDays,
    required this.repetitions,
  });

  final double ease;
  final int intervalDays;
  final int repetitions;

  static const fresh = CardProgress(ease: 2.5, intervalDays: 0, repetitions: 0);
}

class ScheduledReview {
  const ScheduledReview({required this.progress, required this.due});

  final CardProgress progress;
  final DateTime due;
}

abstract class Scheduler {
  ScheduledReview review(CardProgress current, int quality, DateTime now);

  int previewDays(CardProgress current, int quality);
}

/// SM-2. Quality is 0–5. Again is 1, Hard is 3, Good is 4, Easy is 5.
class Sm2Scheduler implements Scheduler {
  const Sm2Scheduler();

  @override
  ScheduledReview review(CardProgress current, int quality, DateTime now) {
    final q = quality.clamp(0, 5);
    var ease = current.ease + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    if (ease < 1.3) ease = 1.3;
    var reps = current.repetitions;
    var interval = current.intervalDays;
    if (q < 3) {
      reps = 0;
      interval = 1;
    } else {
      if (reps <= 0) {
        interval = 1;
      } else if (reps == 1) {
        interval = 6;
      } else {
        interval = (interval * ease).round().clamp(1, 3650);
      }
      reps += 1;
    }
    final progress = CardProgress(ease: ease, intervalDays: interval, repetitions: reps);
    return ScheduledReview(progress: progress, due: now.add(Duration(days: interval)));
  }

  @override
  int previewDays(CardProgress current, int quality) {
    return review(current, quality, DateTime.utc(2020)).progress.intervalDays;
  }
}

class StudyCard {
  const StudyCard({
    required this.id,
    required this.kind,
    required this.prompt,
    required this.answer,
    required this.progress,
    required this.dueAt,
    this.wordId,
    this.itemId,
  });

  final String id;
  final String kind;
  final String prompt;
  final String answer;
  final CardProgress progress;
  final DateTime dueAt;
  final String? wordId;
  final String? itemId;
}

List<StudyCard> reviewQueue(
  List<StudyCard> cards,
  DateTime now, {
  required int reviewLimit,
  required int newLimit,
}) {
  final due = cards.where((card) => card.progress.repetitions > 0 && !card.dueAt.isAfter(now)).toList()
    ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
  final fresh = cards.where((card) => card.progress.repetitions == 0).toList()
    ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
  return [...due.take(reviewLimit), ...fresh.take(newLimit)];
}

int reviewStreak(Iterable<DateTime> reviewedAt, DateTime today) {
  final days = reviewedAt.map((time) => DateTime(time.year, time.month, time.day)).toSet();
  var cursor = DateTime(today.year, today.month, today.day);
  if (!days.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
  }
  var streak = 0;
  while (days.contains(cursor)) {
    streak += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
