import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/api_settings_page.dart';
import 'screens/behavior_settings_page.dart';
import 'screens/chat_page.dart';
import 'screens/character_card_page.dart';
import 'screens/conversation_list_page.dart';
import 'screens/file_editor_page.dart';
import 'screens/narrative_editor_page.dart';
import 'screens/prompt_preview_page.dart';
import 'screens/prompt_settings_page.dart';
import 'screens/settings_page.dart';
import 'screens/story_setup_page.dart';
import 'state/settings_state.dart';

class GalChatApp extends ConsumerWidget {
  const GalChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'GalChat',
      debugShowCheckedModeBanner: false,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (_) => const _SettingsBootstrap(child: ConversationListPage()),
        '/chat': (_) => const ChatPage(),
        '/settings': (_) => const SettingsPage(),
        '/api-settings': (_) => const ApiSettingsPage(),
        '/behavior-settings': (_) => const BehaviorSettingsPage(),
        '/prompt-settings': (_) => const PromptSettingsPage(),
        '/character-card': (_) => const CharacterCardPage(),
        '/narrative': (_) => const NarrativeEditorPage(),
        '/story-setup': (_) => const StorySetupPage(),
        '/file-editor': (_) => const FileEditorPage(),
        '/prompt-preview': (_) => const PromptPreviewPage(),
      },
    );
  }

  ThemeData _lightTheme() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B9D),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      );

  ThemeData _darkTheme() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B9D),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      );
}

class _SettingsBootstrap extends ConsumerWidget {
  final Widget child;

  const _SettingsBootstrap({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsLoad = ref.watch(settingsLoadProvider);

    if (settingsLoad.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (settingsLoad.hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                const Text('设置加载失败喵...'),
                const SizedBox(height: 8),
                Text(
                  '${settingsLoad.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(settingsLoadProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return child;
  }
}
