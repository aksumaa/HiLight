import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hilight/data/models/library_item.dart';
import 'package:hilight/features/library/presentation/library_screen.dart';

import 'support/pump_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final quote = sampleItem(
    id: 'quote',
    type: ItemType.quote,
    text: 'The quiet sentence',
    tag: 'Poems',
  );
  final voice = sampleItem(
    id: 'voice',
    type: ItemType.voice,
    text: 'Spoken on the tram',
  );

  testWidgets('an empty library explains itself', (tester) async {
    await pumpScreen(tester, const LibraryScreen());
    expect(find.text('Your library is empty. Capture a sentence to begin.'), findsOneWidget);
  });

  testWidgets('the voice filter hides quotes', (tester) async {
    await pumpScreen(tester, const LibraryScreen(), items: [quote, voice]);
    await tester.tap(find.byKey(const Key('filter-voice')));
    await tester.pumpAndSettle();
    expect(find.text('Spoken on the tram'), findsOneWidget);
    expect(find.text('The quiet sentence'), findsNothing);
  });

  testWidgets('search matches a tag', (tester) async {
    await pumpScreen(tester, const LibraryScreen(), items: [quote, voice]);
    await tester.enterText(find.byKey(const Key('library-search')), 'Poems');
    await tester.pumpAndSettle();
    expect(find.text('The quiet sentence'), findsOneWidget);
    expect(find.text('Spoken on the tram'), findsNothing);
  });

  testWidgets('the saved cards layout is used', (tester) async {
    await pumpScreen(
      tester,
      const LibraryScreen(),
      items: [quote],
      prefs: {'library_layout': 'cards'},
    );
    expect(find.byKey(const Key('library-cards')), findsOneWidget);
  });
}
