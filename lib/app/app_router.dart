import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/app_localizations.dart';
import '../features/account/presentation/account_screen.dart';
import '../features/capture/domain/capture_pipeline.dart';
import '../features/capture/presentation/edit_capture_screen.dart';
import '../features/capture/presentation/record_screen.dart';
import '../features/capture/presentation/scan_screen.dart';
import '../features/library/presentation/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/account', builder: (context, state) => const AccountScreen()),
      GoRoute(path: '/scan', builder: (context, state) => const ScanScreen()),
      GoRoute(path: '/record', builder: (context, state) => const RecordScreen()),
      GoRoute(
        path: '/capture/edit',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! ProcessedCapture) return const _MissingCapture();
          return EditCaptureScreen(processed: extra);
        },
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

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
