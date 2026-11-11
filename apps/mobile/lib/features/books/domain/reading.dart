int furthestPage(Iterable<int?> pages) {
  var furthest = 0;
  for (final page in pages) {
    if (page != null && page > furthest) furthest = page;
  }
  return furthest;
}

bool bookIsComplete({
  required int? totalPages,
  required int furthest,
  required bool marked,
}) {
  if (marked) return true;
  if (totalPages == null || totalPages <= 0) return false;
  return furthest >= totalPages;
}

int secondsCountedToday({
  required String? storedDay,
  required String today,
  required int storedSeconds,
}) {
  if (storedDay != today) return 0;
  return storedSeconds < 0 ? 0 : storedSeconds;
}

bool readingGoalMet({required int seconds, required int goalMinutes}) {
  if (goalMinutes <= 0) return false;
  return seconds >= goalMinutes * 60;
}

String readingDay(DateTime now) =>
    '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
