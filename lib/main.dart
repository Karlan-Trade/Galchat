import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'database/database.dart';
import 'services/api_key_service.dart';
import 'services/narrative_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final apiKeyService = ApiKeyService();
  final narrativeService = NarrativeService();
  await narrativeService.init();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        apiKeyServiceProvider.overrideWithValue(apiKeyService),
        narrativeServiceProvider.overrideWithValue(narrativeService),
      ],
      child: const GalChatApp(),
    ),
  );
}
