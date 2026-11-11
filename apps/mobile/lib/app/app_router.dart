import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/app_localizations.dart';
import '../data/models/library_item.dart';
import '../features/account/presentation/account_screen.dart';
import '../features/ai/presentation/ai_chat_screen.dart';
import '../features/capture/domain/capture_event.dart';
import '../features/capture/presentation/edit_capture_screen.dart';
import '../features/capture/presentation/record_screen.dart';
import '../features/capture/presentation/scan_screen.dart';
import '../features/books/presentation/add_book_screen.dart';
import '../features/books/presentation/book_detail_screen.dart';
import '../features/books/presentation/isbn_scan_screen.dart';
import '../features/capture/presentation/write_note_screen.dart';
import '../features/device/presentation/device_screen.dart';
import '../features/export/presentation/export_screen.dart';
import '../features/insights/presentation/insights_screen.dart';
import '../features/library/presentation/home_screen.dart';
import '../features/library/presentation/item_detail_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/profile/application/settings_controller.dart';
import '../features/profile/presentation/appearance_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/shell/presentation/app_shell.dart';
import '../features/ielts/presentation/ielts_screen.dart';
import '../features/import/presentation/import_screen.dart';
import '../features/study/presentation/quiz_screen.dart';
import '../features/study/presentation/review_screen.dart';
import '../features/study/presentation/vocab_screen.dart';
import '../features/shell/presentation/onboarding_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _SettingsRefresh();
  ref.listen(settingsProvider, (_, _) => refresh.notify());
  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final settings = ref.read(settingsProvider);
      final loc = state.matchedLocation;
      if (!settings.onboardingComplete) {
        return loc == '/onboarding' ? null : '/onboarding';
      }
      if (!settings.gatePassed) {
        return loc == '/account' ? null : '/account';
      }
      if (loc == '/onboarding') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/account', builder: (context, state) => const AccountScreen()),
      GoRoute(path: '/scan', builder: (context, state) => const ScanScreen()),
      GoRoute(path: '/record', builder: (context, state) => const RecordScreen()),
      GoRoute(path: '/write', builder: (context, state) => const WriteNoteScreen()),
      GoRoute(
        path: '/capture/edit',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! ProcessedCapture) return const _MissingCapture();
          return EditCaptureScreen(processed: extra);
        },
      ),
      GoRoute(
        path: '/item/:id',
        builder: (context, state) => ItemDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/ai',
        builder: (context, state) {
          final extra = state.extra;
          return AiChatScreen(focus: extra is LibraryItem ? extra : null);
        },
      ),
      GoRoute(path: '/appearance', builder: (context, state) => const AppearanceScreen()),
      GoRoute(path: '/books/add', builder: (context, state) => const AddBookScreen()),
      GoRoute(path: '/books/scan', builder: (context, state) => const IsbnScanScreen()),
      GoRoute(
        path: '/books/:id',
        builder: (context, state) => BookDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(path: '/review', builder: (context, state) => const ReviewScreen()),
      GoRoute(path: '/ielts', builder: (context, state) => const IeltsScreen()),
      GoRoute(path: '/quiz', builder: (context, state) => const QuizScreen()),
      GoRoute(path: '/import', builder: (context, state) => const ImportScreen()),
      GoRoute(path: '/export', builder: (context, state) => const ExportScreen()),
      GoRoute(path: '/vocab', builder: (context, state) => const VocabScreen()),
      GoRoute(path: '/device', builder: (context, state) => const DeviceScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/library', builder: (context, state) => const LibraryScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/insights', builder: (context, state) => const InsightsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

class _SettingsRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}

class _MissingCapture extends StatelessWidget {
  const _MissingCapture();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(AppLocalizations.of(context).editMissing),
      ),
    );
  }
}
