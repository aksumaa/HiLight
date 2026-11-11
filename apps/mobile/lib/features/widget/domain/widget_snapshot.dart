import '../../../data/models/library_item.dart';

/// The sentence the home-screen widget shows for this calendar day.
String? quoteOfDay(List<LibraryItem> items, DateTime now) {
  final quotes = [for (final item in items) if (item.text.trim().isNotEmpty) item];
  if (quotes.isEmpty) return null;
  final day = DateTime(now.year, now.month, now.day).difference(DateTime(2026)).inDays;
  return quotes[day.abs() % quotes.length].text.trim();
}
