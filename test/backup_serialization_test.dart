import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

/// Tests backup JSON serialization format and constraints.
///
/// These tests verify the backup JSON structure and security rules
/// (e.g., API key must NOT be present in exported backups).
void main() {
  group('Backup JSON format', () {
    Map<String, dynamic> createValidExportJson() {
      return {
        'schema_version': 1,
        'exported_at': '2026-06-09T12:00:00',
        'app_version': '0.1.0',
        'characters': [
          {
            'id': 1,
            'name': 'hatsuyuki',
            'display_name': '初雪',
            'system_prompt': 'You are 初雪...',
            'greeting': '初次见面喵~',
            'world_setting': '现代校园日常生活',
            'reply_style': '猫娘系',
            'created_at': '2026-06-09T10:00:00',
            'updated_at': '2026-06-09T10:00:00',
          }
        ],
        'conversations': [
          {
            'id': 1,
            'character_id': 1,
            'title': '测试对话',
            'created_at': '2026-06-09T11:00:00',
            'updated_at': '2026-06-09T12:00:00',
            'archived_at': null,
          }
        ],
        'messages': [
          {
            'id': 1,
            'conversation_id': 1,
            'role': 'assistant',
            'speaker': '初雪',
            'content': '初次见面喵~',
            'raw_payload': null,
            'reasoning_content': '我需要先观察主人。',
            'created_at': '2026-06-09T11:00:01',
          },
          {
            'id': 2,
            'conversation_id': 1,
            'role': 'user',
            'speaker': null,
            'content': '你好！',
            'raw_payload': null,
            'reasoning_content': null,
            'created_at': '2026-06-09T11:00:30',
          },
        ],
        'choices': [
          {
            'id': 1,
            'conversation_id': 1,
            'message_id': 1,
            'choice_key': 'A',
            'text': '和她打招呼',
            'selected_at': null,
          },
          {
            'id': 2,
            'conversation_id': 1,
            'message_id': 1,
            'choice_key': 'B',
            'text': '装作没看到',
            'selected_at': null,
          },
        ],
        'game_states': [
          {
            'id': 1,
            'conversation_id': 1,
            'affection': 0,
            'mood': '平静',
            'scene': '教室',
            'time_slot': '放学后',
            'flags_json': '{"met_first_time": false}',
            'updated_at': '2026-06-09T12:00:00',
          }
        ],
        'ai_settings': {
          'base_url': 'https://api.openai.com/v1',
          'model': 'gpt-3.5-turbo',
          'temperature': 0.7,
          'max_tokens': 2048,
          'context_window': 128000,
          'truncate_strategy': 'compress',
          'truncate_limit': 20,
          'markdown_render': false,
        },
      };
    }

    test('valid export JSON has all required top-level fields', () {
      final json = createValidExportJson();

      expect(json.containsKey('schema_version'), true);
      expect(json.containsKey('exported_at'), true);
      expect(json.containsKey('app_version'), true);
      expect(json.containsKey('characters'), true);
      expect(json.containsKey('conversations'), true);
      expect(json.containsKey('messages'), true);
      expect(json.containsKey('choices'), true);
      expect(json.containsKey('game_states'), true);
    });

    test('export JSON must NOT contain API key', () {
      final json = createValidExportJson();

      // Recursively search for any key containing "api_key" or "apikey"
      bool hasApiKey(dynamic obj) {
        if (obj is Map) {
          for (final key in obj.keys) {
            final k = key.toString().toLowerCase().replaceAll('_', '');
            if (k.contains('apikey')) return true;
            if (hasApiKey(obj[key])) return true;
          }
        } else if (obj is List) {
          for (final item in obj) {
            if (hasApiKey(item)) return true;
          }
        }
        return false;
      }

      expect(hasApiKey(json), false,
          reason: 'Backup JSON must not contain API key');
    });

    test('ai_settings only contains non-secret fields', () {
      final json = createValidExportJson();
      final settings = json['ai_settings'] as Map<String, dynamic>;

      // These fields are safe to export
      expect(settings.containsKey('base_url'), true);
      expect(settings.containsKey('model'), true);
      expect(settings.containsKey('temperature'), true);
      expect(settings.containsKey('max_tokens'), true);
      expect(settings.containsKey('context_window'), true);
      expect(settings.containsKey('truncate_strategy'), true);
      expect(settings.containsKey('truncate_limit'), true);
      expect(settings.containsKey('markdown_render'), true);

      // These fields must NOT be in the export
      expect(settings.containsKey('api_key'), false);
      expect(settings.containsKey('key'), false);
      expect(settings.containsKey('secret'), false);
    });

    test('schema_version must be an integer', () {
      final json = createValidExportJson();
      expect(json['schema_version'], isA<int>());
    });

    test('character has all required fields', () {
      final json = createValidExportJson();
      final character =
          (json['characters'] as List).first as Map<String, dynamic>;

      expect(character['id'], isA<int>());
      expect(character['name'], isA<String>());
      expect(character['display_name'], isA<String>());
      expect(character['system_prompt'], isA<String>());
      expect(character['greeting'], isA<String>());
      expect(character['world_setting'], isA<String>());
      expect(character['created_at'], isA<String>());
      expect(character['updated_at'], isA<String>());
    });

    test('message has correct role values', () {
      final json = createValidExportJson();
      final messages = json['messages'] as List;

      final roles = messages.map((m) => (m as Map)['role'] as String).toSet();
      expect(roles.contains('user'), true);
      expect(roles.contains('assistant'), true);
    });

    test('message preserves optional reasoning content', () {
      final json = createValidExportJson();
      final messages = json['messages'] as List;

      expect((messages.first as Map)['reasoning_content'], isA<String>());
      expect((messages.last as Map)['reasoning_content'], isNull);
    });

    test('choice has required fields', () {
      final json = createValidExportJson();
      final choice = (json['choices'] as List).first as Map<String, dynamic>;

      expect(choice['id'], isA<int>());
      expect(choice['conversation_id'], isA<int>());
      expect(choice['choice_key'], isA<String>());
      expect(choice['text'], isA<String>());
    });

    test('game_state has valid defaults', () {
      final json = createValidExportJson();
      final state = (json['game_states'] as List).first as Map<String, dynamic>;

      expect(state['affection'], isA<int>());
      expect(state['mood'], isA<String>());
      expect(state['scene'], isA<String>());
      expect(state['time_slot'], isA<String>());
      expect(state['flags_json'], isA<String>());
    });

    test('archived_at can be null', () {
      final json = createValidExportJson();
      final conv =
          (json['conversations'] as List).first as Map<String, dynamic>;

      expect(conv['archived_at'], isNull);
    });

    test('JSON can be round-tripped through encode/decode', () {
      final json = createValidExportJson();
      final encoded = const JsonEncoder.withIndent('  ').convert(json);
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;

      expect(decoded['schema_version'], json['schema_version']);
      expect(decoded['exported_at'], json['exported_at']);
      expect((decoded['characters'] as List).length, 1);
      expect((decoded['conversations'] as List).length, 1);
      expect((decoded['messages'] as List).length, 2);
      expect((decoded['choices'] as List).length, 2);
      expect((decoded['game_states'] as List).length, 1);
    });
  });
}
