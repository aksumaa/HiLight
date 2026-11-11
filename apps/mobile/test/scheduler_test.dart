import 'package:flutter_test/flutter_test.dart';
import 'package:hilight/features/study/domain/scheduler.dart';

void main() {
  const scheduler = Sm2Scheduler();
  final now = DateTime.utc(2026, 1, 1);

  test('a first successful review is due tomorrow', () {
    final result = scheduler.review(CardProgress.fresh, 4, now);
    expect(result.progress.intervalDays, 1);
    expect(result.progress.repetitions, 1);
    expect(result.due, now.add(const Duration(days: 1)));
  });

  test('the second successful review waits six days', () {
    final first = scheduler.review(CardProgress.fresh, 4, now);
    final second = scheduler.review(first.progress, 4, now);
    expect(second.progress.intervalDays, 6);
    expect(second.progress.repetitions, 2);
  });

  test('later reviews multiply the interval by ease', () {
    final first = scheduler.review(CardProgress.fresh, 4, now);
    final second = scheduler.review(first.progress, 4, now);
    final third = scheduler.review(second.progress, 5, now);
    expect(third.progress.intervalDays, greaterThan(6));
    expect(third.progress.repetitions, 3);
  });

  test('a failed review resets repetitions and is due tomorrow', () {
    final learned = scheduler.review(
      const CardProgress(ease: 2.5, intervalDays: 12, repetitions: 4),
      1,
      now,
    );
    expect(learned.progress.repetitions, 0);
    expect(learned.progress.intervalDays, 1);
  });

  test('ease does not fall below 1.3', () {
    final result = scheduler.review(
      const CardProgress(ease: 1.3, intervalDays: 6, repetitions: 3),
      0,
      now,
    );
    expect(result.progress.ease, greaterThanOrEqualTo(1.3));
  });

  test('previewed intervals grow from again to easy', () {
    const current = CardProgress(ease: 2.5, intervalDays: 6, repetitions: 3);
    final again = scheduler.previewDays(current, 1);
    final hard = scheduler.previewDays(current, 3);
    final good = scheduler.previewDays(current, 4);
    final easy = scheduler.previewDays(current, 5);
    expect(again, 1);
    expect(hard, lessThan(good));
    expect(good, lessThan(easy));
  });

  test('the queue respects daily review and new limits', () {
    final cards = [
      for (var i = 0; i < 4; i++)
        StudyCard(
          id: 'due-$i',
          kind: 'quote',
          prompt: 'p',
          answer: 'a',
          progress: const CardProgress(ease: 2.5, intervalDays: 1, repetitions: 2),
          dueAt: now.subtract(Duration(days: i + 1)),
        ),
      for (var i = 0; i < 4; i++)
        StudyCard(
          id: 'new-$i',
          kind: 'word',
          prompt: 'p',
          answer: 'a',
          progress: CardProgress.fresh,
          dueAt: now.add(Duration(minutes: i)),
        ),
    ];
    final queue = reviewQueue(cards, now, reviewLimit: 2, newLimit: 1);
    expect(queue.map((card) => card.id).toList(), ['due-3', 'due-2', 'new-0']);
  });

  test('a streak counts consecutive days and survives a gap only through yesterday', () {
    expect(
      reviewStreak([
        DateTime.utc(2026, 1, 1, 8),
        DateTime.utc(2026, 1, 2, 9),
        DateTime.utc(2026, 1, 3, 10),
      ], DateTime.utc(2026, 1, 3, 12)),
      3,
    );
    expect(
      reviewStreak([DateTime.utc(2026, 1, 1)], DateTime.utc(2026, 1, 3)),
      0,
    );
  });
}
