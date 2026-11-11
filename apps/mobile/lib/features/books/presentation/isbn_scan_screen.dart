import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/l10n/app_localizations.dart';

class IsbnScanScreen extends StatelessWidget {
  const IsbnScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanIsbn)),
      body: MobileScanner(
        onDetect: (capture) {
          for (final code in capture.barcodes) {
            final value = code.rawValue;
            if (value == null) continue;
            final digits = value.replaceAll(RegExp(r'[^0-9Xx]'), '');
            if (digits.length == 10 || digits.length == 13) {
              context.pop(digits);
              return;
            }
          }
        },
      ),
    );
  }
}
