import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tables.dart';

part 'database.g.dart';

/// Riverpod provider for the database singleton.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Override this provider in main()');
});

@DriftDatabase(tables: [
  Characters,
  Conversations,
  Messages,
  Choices,
  GameStates,
  AiSettings
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await seedDefaultCharacter();
        },
        onUpgrade: (m, from, to) async {
          if (from < 6) {
            // v3→v4: truncate columns added; v4→v5: context_window added; v5→v6: markdown_render added.
            // Drop and recreate — ai_settings is a single-row config table.
            await customStatement('DROP TABLE IF EXISTS ai_settings');
            await m.create(aiSettings);
          }
          if (from < 7) {
            await customStatement(
              'ALTER TABLE messages ADD COLUMN reasoning_content TEXT',
            );
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'galchat.db');
  }

  /// Seed the default character (初雪) into the database.
  Future<void> seedDefaultCharacter() async {
    await into(characters).insert(CharactersCompanion(
      name: const Value('hatsuyuki'),
      displayName: const Value('初雪'),
      systemPrompt: const Value(_defaultSystemPrompt),
      greeting: const Value(defaultCharacterGreeting),
      worldSetting: const Value('现代校园日常生活'),
      replyStyle: const Value('猫娘系粘人/小傲娇'),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // ============================================================
  // Characters queries
  // ============================================================

  Future<Character> getDefaultCharacter() {
    return (select(characters)..where((c) => c.name.equals('hatsuyuki')))
        .getSingle();
  }

  Future<List<Character>> allCharacters() {
    return select(characters).get();
  }

  Future<Character?> getCharacterById(int id) {
    return (select(characters)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updateCharacter({
    required int characterId,
    required String displayName,
    required String systemPrompt,
    required String greeting,
    required String worldSetting,
    required String replyStyle,
  }) {
    return (update(characters)..where((c) => c.id.equals(characterId))).write(
      CharactersCompanion(
        displayName: Value(displayName),
        systemPrompt: Value(systemPrompt),
        greeting: Value(greeting),
        worldSetting: Value(worldSetting),
        replyStyle: Value(replyStyle),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> resetCharacterToDefault(int characterId) async {
    await (update(characters)..where((c) => c.id.equals(characterId))).write(
      CharactersCompanion(
        systemPrompt: const Value(_defaultSystemPrompt),
        greeting: const Value(defaultCharacterGreeting),
        worldSetting: const Value('现代校园日常生活'),
        replyStyle: const Value('猫娘系粘人/小傲娇'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================
  // Conversations queries
  // ============================================================

  Future<List<Conversation>> allConversations() {
    return (select(conversations)
          ..where((c) => c.archivedAt.isNull())
          ..orderBy([(c) => OrderingTerm.desc(c.updatedAt)]))
        .get();
  }

  Future<Conversation?> getConversationById(int id) {
    return (select(conversations)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> createConversation(int characterId, String title) {
    final now = DateTime.now();
    return into(conversations).insert(ConversationsCompanion(
      characterId: Value(characterId),
      title: Value(title),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  Future<void> updateConversationTitle(int id, String title) {
    return (update(conversations)..where((c) => c.id.equals(id))).write(
      ConversationsCompanion(
          title: Value(title), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> archiveConversation(int id) {
    return (update(conversations)..where((c) => c.id.equals(id))).write(
      ConversationsCompanion(
          archivedAt: Value(DateTime.now()), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> deleteConversation(int id) async {
    await transaction(() async {
      await (delete(choices)..where((c) => c.conversationId.equals(id))).go();
      await (delete(messages)..where((m) => m.conversationId.equals(id))).go();
      await (delete(gameStates)..where((g) => g.conversationId.equals(id)))
          .go();
      await (delete(conversations)..where((c) => c.id.equals(id))).go();
    });
  }

  Future<void> touchConversation(int id) {
    return (update(conversations)..where((c) => c.id.equals(id))).write(
      ConversationsCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  // ============================================================
  // Messages queries
  // ============================================================

  Future<List<Message>> getMessagesByConversation(int conversationId) {
    return (select(messages)
          ..where((m) => m.conversationId.equals(conversationId))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .get();
  }

  Future<int> insertMessage(MessagesCompanion entry) {
    return into(messages).insert(entry);
  }

  Future<void> deleteMessage(int id) {
    return (delete(messages)..where((m) => m.id.equals(id))).go();
  }

  // ============================================================
  // Choices queries
  // ============================================================

  Future<List<Choice>> getChoicesByConversation(int conversationId) {
    return (select(choices)
          ..where((c) => c.conversationId.equals(conversationId))
          ..orderBy([(c) => OrderingTerm.asc(c.id)]))
        .get();
  }

  Future<void> insertChoices(List<ChoicesCompanion> choiceEntries) async {
    for (final entry in choiceEntries) {
      await into(choices).insert(entry);
    }
  }

  Future<void> markChoiceSelected(int choiceId) {
    return (update(choices)..where((c) => c.id.equals(choiceId))).write(
      ChoicesCompanion(selectedAt: Value(DateTime.now())),
    );
  }

  // ============================================================
  // Game state queries
  // ============================================================

  Future<GameState?> getGameState(int conversationId) {
    return (select(gameStates)
          ..where((g) => g.conversationId.equals(conversationId)))
        .getSingleOrNull();
  }

  Future<void> upsertGameState(GameStatesCompanion entry) async {
    final existing = await getGameState(entry.conversationId.value);
    if (existing != null) {
      await (update(gameStates)
            ..where((g) => g.conversationId.equals(entry.conversationId.value)))
          .write(entry);
    } else {
      await into(gameStates).insert(entry);
    }
  }

  // ============================================================
  // AI settings queries
  // ============================================================

  Future<AiSetting?> getAiSettings() {
    return (select(aiSettings)..limit(1)).getSingleOrNull();
  }

  Future<void> saveAiSettings(AiSettingsCompanion entry) async {
    final existing = await getAiSettings();
    if (existing != null) {
      await (update(aiSettings)..where((a) => a.id.equals(existing.id)))
          .write(entry);
    } else {
      await into(aiSettings).insert(entry);
    }
  }

  // ============================================================
  // Backup helpers
  // ============================================================

  /// Export all data for backup (excludes API key by design).
  Future<BackupData> exportAll() async {
    final chars = await select(characters).get();
    final convs = await select(conversations).get();
    final msgs = await select(messages).get();
    final chs = await select(choices).get();
    final states = await select(gameStates).get();
    final settings = await getAiSettings();

    return BackupData(
      schemaVersion: schemaVersion,
      characters: chars,
      conversations: convs,
      messages: msgs,
      choices: chs,
      gameStates: states,
      aiSetting: settings,
    );
  }

  /// Import data from a backup file transactionally.
  Future<void> importAll(BackupData data) async {
    await transaction(() async {
      for (final c in data.characters) {
        await into(characters).insertOnConflictUpdate(c);
      }
      for (final c in data.conversations) {
        await into(conversations).insertOnConflictUpdate(c);
      }
      for (final m in data.messages) {
        await into(messages).insertOnConflictUpdate(m);
      }
      for (final c in data.choices) {
        await into(choices).insertOnConflictUpdate(c);
      }
      for (final g in data.gameStates) {
        await into(gameStates).insertOnConflictUpdate(g);
      }
      if (data.aiSetting != null) {
        await saveAiSettings(AiSettingsCompanion(
          baseUrl: Value(data.aiSetting!.baseUrl),
          model: Value(data.aiSetting!.model),
          temperature: Value(data.aiSetting!.temperature),
          maxTokens: Value(data.aiSetting!.maxTokens),
          contextWindow: Value(data.aiSetting!.contextWindow),
          truncateStrategy: Value(data.aiSetting!.truncateStrategy),
          truncateLimit: Value(data.aiSetting!.truncateLimit),
          markdownRender: Value(data.aiSetting!.markdownRender),
          updatedAt: Value(DateTime.now()),
        ));
      }
    });
  }
}

/// Data class for backup export/import.
class BackupData {
  final int schemaVersion;
  final List<Character> characters;
  final List<Conversation> conversations;
  final List<Message> messages;
  final List<Choice> choices;
  final List<GameState> gameStates;
  final AiSetting? aiSetting;

  const BackupData({
    required this.schemaVersion,
    required this.characters,
    required this.conversations,
    required this.messages,
    required this.choices,
    required this.gameStates,
    this.aiSetting,
  });
}

/// Default system prompt for 初雪 — empty by default, user fills in their own.
const String _defaultSystemPrompt = '';

const String defaultCharacterGreeting = '（本地兜底提示）AI 开场生成没有返回可显示正文喵...'
    '这通常是接口超时、网络中断、模型一直停留在思考阶段，'
    '或 API 返回为空导致的。可以点重试，或关闭思考模式/工具调用后再试。';
