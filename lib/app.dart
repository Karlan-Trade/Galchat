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

class GalChatApp extends ConsumerWidget {
  const GalChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'GalChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B9D),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B9D),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (_) => const ConversationListPage(),
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
}
