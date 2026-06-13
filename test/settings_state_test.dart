import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galchat/database/database.dart';
import 'package:galchat/services/api_key_service.dart';
import 'package:galchat/state/settings_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _MockAppDatabase extends Mock implements AppDatabase {}

class _MockApiKeyService extends Mock implements ApiKeyService {}

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this.path);

  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('galchat_settings_test_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('startup settings load does not read API key storage', () async {
    final db = _MockAppDatabase();
    final apiKeyService = _MockApiKeyService();
    when(() => db.getAiSettings()).thenAnswer((_) async => null);
    when(() => apiKeyService.hasApiKey()).thenThrow(StateError('unavailable'));

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        apiKeyServiceProvider.overrideWithValue(apiKeyService),
      ],
    );
    addTearDown(container.dispose);

    await container.read(settingsLoadProvider.future);

    verify(() => db.getAiSettings()).called(1);
    verifyNever(() => apiKeyService.hasApiKey());
  });

  test('explicit API key status refresh keeps previous value if storage fails',
      () async {
    final db = _MockAppDatabase();
    final apiKeyService = _MockApiKeyService();
    when(() => db.getAiSettings()).thenAnswer((_) async => null);
    when(() => apiKeyService.hasApiKey()).thenThrow(StateError('unavailable'));

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        apiKeyServiceProvider.overrideWithValue(apiKeyService),
      ],
    );
    addTearDown(container.dispose);

    await container.read(settingsLoadProvider.future);
    await container.read(settingsProvider.notifier).refreshApiKeyStatus();

    expect(container.read(settingsProvider).hasApiKey, false);
    verify(() => apiKeyService.hasApiKey()).called(1);
  });
}
