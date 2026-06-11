import 'package:drift/drift.dart';

/// Characters table — stores character card data.
///
/// MVP includes one built-in: 初雪. Schema supports custom character cards later.
class Characters extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get displayName => text().named('display_name')();
  TextColumn get systemPrompt => text().named('system_prompt')();
  TextColumn get greeting => text()();
  TextColumn get worldSetting => text().named('world_setting')();
  TextColumn get replyStyle => text().named('reply_style').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
}

/// Conversations table — each chat session with a character.
class Conversations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get characterId => integer().named('character_id').references(Characters, #id)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get archivedAt => dateTime().named('archived_at').nullable()();
}

/// Messages table — each individual message in a conversation.
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get conversationId => integer().named('conversation_id').references(Conversations, #id)();
  TextColumn get role => text()(); // user | assistant | system | error
  TextColumn get speaker => text().nullable()(); // character name for assistant messages
  TextColumn get content => text()();
  TextColumn get rawPayload => text().named('raw_payload').nullable()(); // raw AI JSON
  DateTimeColumn get createdAt => dateTime().named('created_at')();
}

/// Choices table — Galgame choices presented by the AI.
class Choices extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get conversationId => integer().named('conversation_id').references(Conversations, #id)();
  IntColumn get messageId => integer().named('message_id').references(Messages, #id)();
  TextColumn get choiceKey => text().named('choice_key')(); // A, B, C, D
  TextColumn get choiceText => text().named('choice_text')();
  DateTimeColumn get selectedAt => dateTime().named('selected_at').nullable()();
}

/// Game states table — per-conversation game state snapshot.
class GameStates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get conversationId => integer().named('conversation_id').references(Conversations, #id).unique()();
  IntColumn get affection => integer().withDefault(const Constant(0))();
  TextColumn get mood => text().withDefault(const Constant('平静'))();
  TextColumn get scene => text().withDefault(const Constant('教室'))();
  TextColumn get timeSlot => text().named('time_slot').withDefault(const Constant('放学后'))();
  TextColumn get flagsJson => text().named('flags_json').withDefault(const Constant('{}'))();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
}

/// AI settings table — non-secret provider configuration.
class AiSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get baseUrl => text().named('base_url')();
  TextColumn get model => text()();
  RealColumn get temperature => real().withDefault(const Constant(0.7))();
  IntColumn get maxTokens => integer().named('max_tokens').withDefault(const Constant(4096))(); // per-reply output cap
  IntColumn get contextWindow => integer().named('context_window').withDefault(const Constant(128000))(); // model's max context length
  TextColumn get truncateStrategy => text().named('truncate_strategy').withDefault(const Constant('compress'))(); // compress | truncate
  IntColumn get truncateLimit => integer().named('truncate_limit').withDefault(const Constant(20))(); // turns when truncate
  BoolColumn get markdownRender => boolean().named('markdown_render').withDefault(const Constant(false))(); // enable markdown rendering in chat bubbles
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
}
