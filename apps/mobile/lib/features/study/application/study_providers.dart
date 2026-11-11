import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Filled in by the review and vocab features. Home reads these now.
final reviewDueCountProvider = Provider<int>((ref) => 0);

final wordOfDayProvider = Provider<String?>((ref) => null);
