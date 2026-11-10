import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hilight/features/profile/presentation/appearance_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/pump_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the live preview shows the sample sentence', (tester) async {
    await pumpScreen(tester, const AppearanceScreen());
    expect(find.byKey(const Key('appearance-preview')), findsOneWidget);
    expect(find.text('A sentence worth keeping.'), findsOneWidget);
  });

  testWidgets('dark theme and compact layout are saved', (tester) async {
    await pumpScreen(tester, const AppearanceScreen());
    await tester.tap(find.byKey(const Key('theme-dark')));
    await tester.pumpAndSettle();
    final context = tester.element(find.byKey(const Key('appearance-preview')));
    expect(Theme.of(context).brightness, Brightness.dark);

    await tester.tap(find.byKey(const Key('layout-compact')));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'dark');
    expect(prefs.getString('library_layout'), 'compact');
  });
}
