import 'package:flutter_test/flutter_test.dart';
import 'package:hilight/features/books/domain/reading.dart';

void main() {
  test('a book is finished at the last page or when the reader says so', () {
    expect(bookIsComplete(totalPages: 100, furthest: 100, marked: false), isTrue);
    expect(bookIsComplete(totalPages: 100, furthest: 40, marked: false), isFalse);
    expect(bookIsComplete(totalPages: null, furthest: 0, marked: true), isTrue);
    expect(furthestPage([null, 4, 12, 3]), 12);
  });

  test('yesterday\'s minutes do not count toward today', () {
    expect(secondsCountedToday(storedDay: '2026-01-01', today: '2026-01-02', storedSeconds: 600), 0);
    expect(secondsCountedToday(storedDay: '2026-01-02', today: '2026-01-02', storedSeconds: 600), 600);
    expect(readingGoalMet(seconds: 900, goalMinutes: 15), isTrue);
    expect(readingGoalMet(seconds: 899, goalMinutes: 15), isFalse);
  });
}
