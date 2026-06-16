import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../database/database.dart';

/// Handles JSON backup export/import.
///
/// - Export includes: characters, conversations, messages, choices, game states, AI settings
/// - Export EXCLUDES: API key (it lives in secure storage)
/// - Import is transactional — no partial overwrites on failure
class BackupService {
  final AppDatabase _db;

  BackupService(this._db);

  static const int _currentSchemaVersion = 1;

  /// Build the export JSON payload (shared by all export methods).
  Future<String> buildExportJson() async {
    final data = await _db.exportAll();

    final exportJson = {
      'schema_version': _currentSchemaVersion,
      'exported_at': DateTime.now().toIso8601String(),
      'app_version': '0.8.6',
      'characters': data.characters.map(_characterToJson).toList(),
      'conversations': data.conversations.map(_conversationToJson).toList(),
      'messages': data.messages.map(_messageToJson).toList(),
      'choices': data.choices.map(_choiceToJson).toList(),
      'game_states': data.gameStates.map(_gameStateToJson).toList(),
    };

    if (data.aiSetting != null) {
      exportJson['ai_settings'] = {
        'base_url': data.aiSetting!.baseUrl,
        'model': data.aiSetting!.model,
        'temperature': data.aiSetting!.temperature,
        'max_tokens': data.aiSetting!.maxTokens,
        'context_window': data.aiSetting!.contextWindow,
        'truncate_strategy': data.aiSetting!.truncateStrategy,
        'truncate_limit': data.aiSetting!.truncateLimit,
        'markdown_render': data.aiSetting!.markdownRender,
      };
    }

    return const JsonEncoder.withIndent('  ').convert(exportJson);
  }

  /// Export all data to the app documents directory and return the file path.
  Future<String> exportToFile() async {
    final json = await buildExportJson();
    final dir = await getApplicationDocumentsDirectory();
    final timestamp =
        DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final filePath = '${dir.path}/galchat_backup_$timestamp.json';
    final file = File(filePath);
    await file.writeAsString(json);
    return filePath;
  }

  /// Export all data to a user-chosen [targetPath].
  Future<void> exportToPath(String targetPath) async {
    final json = await buildExportJson();
    final file = File(targetPath);
    await file.writeAsString(json);
  }

  /// Import data from a JSON file at the given [filePath].
  ///
  /// Returns the number of imported conversations.
  Future<int> importFromFile(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw BackupException('文件不存在喵: $filePath');
    }

    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;

    // Validate schema version
    final schemaVersion = json['schema_version'] as int?;
    if (schemaVersion == null || schemaVersion > _currentSchemaVersion) {
      throw BackupException(
        '备份文件版本($schemaVersion)高于当前支持版本($_currentSchemaVersion)，无法导入喵~',
      );
    }

    // Parse characters
    final characters = <Character>[];
    final rawCharacters = json['characters'] as List<dynamic>? ?? [];
    for (final c in rawCharacters) {
      characters.add(_characterFromJson(c as Map<String, dynamic>));
    }

    // Parse conversations
    final conversations = <Conversation>[];
    final rawConvs = json['conversations'] as List<dynamic>? ?? [];
    for (final c in rawConvs) {
      conversations.add(_conversationFromJson(c as Map<String, dynamic>));
    }

    // Parse messages
    final messages = <Message>[];
    final rawMessages = json['messages'] as List<dynamic>? ?? [];
    for (final m in rawMessages) {
      messages.add(_messageFromJson(m as Map<String, dynamic>));
    }

    // Parse choices
    final choices = <Choice>[];
    final rawChoices = json['choices'] as List<dynamic>? ?? [];
    for (final c in rawChoices) {
      choices.add(_choiceFromJson(c as Map<String, dynamic>));
    }

    // Parse game states
    final gameStates = <GameState>[];
    final rawStates = json['game_states'] as List<dynamic>? ?? [];
    for (final g in rawStates) {
      gameStates.add(_gameStateFromJson(g as Map<String, dynamic>));
    }

    // Parse AI settings (optional, non-secret only)
    AiSetting? aiSetting;
    if (json['ai_settings'] != null) {
      final s = json['ai_settings'] as Map<String, dynamic>;
      aiSetting = AiSetting(
        id: 1,
        baseUrl: s['base_url'] as String? ?? '',
        model: s['model'] as String? ?? '',
        temperature: (s['temperature'] as num?)?.toDouble() ?? 0.7,
        maxTokens: s['max_tokens'] as int? ?? 4096,
        contextWindow: s['context_window'] as int? ?? 128000,
        truncateStrategy: s['truncate_strategy'] as String? ?? 'compress',
        truncateLimit: s['truncate_limit'] as int? ?? 20,
        markdownRender: s['markdown_render'] as bool? ?? false,
        updatedAt: DateTime.now(),
      );
    }

    await _db.importAll(BackupData(
      schemaVersion: schemaVersion,
      characters: characters,
      conversations: conversations,
      messages: messages,
      choices: choices,
      gameStates: gameStates,
      aiSetting: aiSetting,
    ));

    return conversations.length;
  }

  // ============================================================
  // Serialization helpers
  // ============================================================

  Map<String, dynamic> _characterToJson(Character c) => {
        'id': c.id,
        'name': c.name,
        'display_name': c.displayName,
        'system_prompt': c.systemPrompt,
        'greeting': c.greeting,
        'world_setting': c.worldSetting,
        'reply_style': c.replyStyle,
        'created_at': c.createdAt.toIso8601String(),
        'updated_at': c.updatedAt.toIso8601String(),
      };

  Character _characterFromJson(Map<String, dynamic> j) => Character(
        id: j['id'] as int,
        name: j['name'] as String,
        displayName: j['display_name'] as String,
        systemPrompt: j['system_prompt'] as String,
        greeting: j['greeting'] as String,
        worldSetting: j['world_setting'] as String,
        replyStyle: j['reply_style'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
        updatedAt: DateTime.parse(j['updated_at'] as String),
      );

  Map<String, dynamic> _conversationToJson(Conversation c) => {
        'id': c.id,
        'character_id': c.characterId,
        'title': c.title,
        'created_at': c.createdAt.toIso8601String(),
        'updated_at': c.updatedAt.toIso8601String(),
        'archived_at': c.archivedAt?.toIso8601String(),
      };

  Conversation _conversationFromJson(Map<String, dynamic> j) => Conversation(
        id: j['id'] as int,
        characterId: j['character_id'] as int,
        title: j['title'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
        updatedAt: DateTime.parse(j['updated_at'] as String),
        archivedAt: j['archived_at'] != null
            ? DateTime.parse(j['archived_at'] as String)
            : null,
      );

  Map<String, dynamic> _messageToJson(Message m) => {
        'id': m.id,
        'conversation_id': m.conversationId,
        'role': m.role,
        'speaker': m.speaker,
        'content': m.content,
        'raw_payload': m.rawPayload,
        'reasoning_content': m.reasoningContent,
        'created_at': m.createdAt.toIso8601String(),
      };

  Message _messageFromJson(Map<String, dynamic> j) => Message(
        id: j['id'] as int,
        conversationId: j['conversation_id'] as int,
        role: j['role'] as String,
        speaker: j['speaker'] as String?,
        content: j['content'] as String,
        rawPayload: j['raw_payload'] as String?,
        reasoningContent: j['reasoning_content'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Map<String, dynamic> _choiceToJson(Choice c) => {
        'id': c.id,
        'conversation_id': c.conversationId,
        'message_id': c.messageId,
        'choice_key': c.choiceKey,
        'text': c.choiceText,
        'selected_at': c.selectedAt?.toIso8601String(),
      };

  Choice _choiceFromJson(Map<String, dynamic> j) => Choice(
        id: j['id'] as int,
        conversationId: j['conversation_id'] as int,
        messageId: j['message_id'] as int,
        choiceKey: j['choice_key'] as String,
        choiceText: j['text'] as String,
        selectedAt: j['selected_at'] != null
            ? DateTime.parse(j['selected_at'] as String)
            : null,
      );

  Map<String, dynamic> _gameStateToJson(GameState g) => {
        'id': g.id,
        'conversation_id': g.conversationId,
        'affection': g.affection,
        'mood': g.mood,
        'scene': g.scene,
        'time_slot': g.timeSlot,
        'flags_json': g.flagsJson,
        'updated_at': g.updatedAt.toIso8601String(),
      };

  GameState _gameStateFromJson(Map<String, dynamic> j) => GameState(
        id: j['id'] as int,
        conversationId: j['conversation_id'] as int,
        affection: j['affection'] as int,
        mood: j['mood'] as String,
        scene: j['scene'] as String,
        timeSlot: j['time_slot'] as String,
        flagsJson: j['flags_json'] as String,
        updatedAt: DateTime.parse(j['updated_at'] as String),
      );
}

/// Thrown when backup import/export fails.
class BackupException implements Exception {
  final String message;

  const BackupException(this.message);

  @override
  String toString() => message;
}

/// Riverpod provider for the backup service.
final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  return BackupService(db);
});
