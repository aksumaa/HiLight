import 'package:flutter_test/flutter_test.dart';
import 'package:hilight/features/study/domain/pronunciation.dart';

void main() {
  test('an exact transcript scores 100 and a miss scores lower', () {
    expect(pronunciationScore('habitat', 'habitat'), 100);
    expect(pronunciationScore('habitat', 'habit'), greaterThan(50));
    expect(pronunciationScore('habitat', 'tram'), lessThan(40));
    expect(pronunciationScore('habitat', ''), 0);
  });
}
