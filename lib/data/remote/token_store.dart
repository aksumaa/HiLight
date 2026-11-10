import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenPair {
  const TokenPair({required this.access, required this.refresh});

  final String access;
  final String refresh;
}

abstract class TokenStore {
  Future<void> write(TokenPair tokens);

  Future<String?> readAccess();

  Future<String?> readRefresh();

  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _access = 'hilight_access_token';
  static const _refresh = 'hilight_refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<void> write(TokenPair tokens) async {
    await _storage.write(key: _access, value: tokens.access);
    await _storage.write(key: _refresh, value: tokens.refresh);
  }

  @override
  Future<String?> readAccess() => _storage.read(key: _access);

  @override
  Future<String?> readRefresh() => _storage.read(key: _refresh);

  @override
  Future<void> clear() async {
    await _storage.delete(key: _access);
    await _storage.delete(key: _refresh);
  }
}
