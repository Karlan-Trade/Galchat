import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the API key in platform secure storage.
///
/// The API key is NEVER stored in the database or exported in backups.
class ApiKeyService {
  static const _keyApiKey = 'galchat_api_key';

  final FlutterSecureStorage _storage;

  ApiKeyService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  /// Read the stored API key, or null if not set.
  Future<String?> getApiKey() async {
    return _storage.read(key: _keyApiKey);
  }

  /// Save or update the API key.
  Future<void> setApiKey(String key) async {
    await _storage.write(key: _keyApiKey, value: key);
  }

  /// Remove the API key (e.g., on logout or reset).
  Future<void> deleteApiKey() async {
    await _storage.delete(key: _keyApiKey);
  }

  /// Whether an API key has been configured.
  Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }
}

/// Riverpod provider for the API key service singleton.
final apiKeyServiceProvider = Provider<ApiKeyService>((ref) {
  throw UnimplementedError('Override this provider in main()');
});
