import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_providers.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/hilight_colors.dart';
import '../../../data/remote/api_client.dart';
import '../../profile/application/settings_controller.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _registering = false;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final api = ref.read(apiClientProvider);
      if (_registering) {
        await api.register(email: _email.text.trim(), password: _password.text);
      } else {
        await api.login(email: _email.text.trim(), password: _password.text);
      }
      await ref.read(syncServiceProvider).run();
      await ref.read(settingsProvider.notifier).markEntered();
      if (mounted) context.go('/');
    } on ApiException {
      if (mounted) setState(() => _error = l10n.loginFailed);
    } on Object {
      if (mounted) setState(() => _error = l10n.loginFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _logout() async {
    await ref.read(apiClientProvider).logout();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.hilight;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            _registering ? l10n.registerTitle : l10n.loginTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: InputDecoration(labelText: l10n.emailLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(labelText: l10n.passwordLabel),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: colors.primary, fontSize: 14)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: Text(_registering ? l10n.registerAction : l10n.loginAction),
          ),
          TextButton(
            onPressed: _busy ? null : () => setState(() => _registering = !_registering),
            child: Text(_registering ? l10n.switchToLogin : l10n.switchToRegister),
          ),
          TextButton(onPressed: _busy ? null : _logout, child: Text(l10n.logOut)),
          TextButton(
            onPressed: _busy
                ? null
                : () async {
                    await ref.read(settingsProvider.notifier).markEntered();
                    if (context.mounted) context.go('/');
                  },
            child: Text(l10n.continueOffline),
          ),
        ],
      ),
    );
  }
}
