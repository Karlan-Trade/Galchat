import 'package:flutter_test/flutter_test.dart';
import 'package:galchat/providers/ai_provider.dart';

void main() {
  group('AiTurnResult.parse', () {
    test('parse valid JSON with messages, choices, state_delta', () {
      const raw = '''
      {
        "messages": [
          {"speaker": "初雪", "text": "主人，今天天气真好喵~"}
        ],
        "choices": [
          {"id": "A", "text": "和初雪一起去公园"},
          {"id": "B", "text": "还是留在教室里聊天吧"}
        ],
        "state_delta": {
          "affection": 2,
          "mood": "开心"
        }
      }
      ''';

      final result = AiTurnResult.parse(raw);

      expect(result.isValidJson, isTrue);
      expect(result.messages.length, 1);
      expect(result.messages.first.speaker, '初雪');
      expect(result.messages.first.text, '主人，今天天气真好喵~');
      expect(result.choices.length, 2);
      expect(result.choices[0].id, 'A');
      expect(result.choices[1].id, 'B');
      expect(result.stateDelta, isNotNull);
      expect(result.stateDelta!.affection, 2);
      expect(result.stateDelta!.mood, '开心');
    });

    test('parse JSON without choices', () {
      const raw = '''
      {
        "messages": [
          {"speaker": "初雪", "text": "嗯，知道了喵~"}
        ]
      }
      ''';

      final result = AiTurnResult.parse(raw);

      expect(result.isValidJson, isTrue);
      expect(result.messages.length, 1);
      expect(result.choices, isEmpty);
      expect(result.stateDelta, isNull);
    });

    test('parse JSON with empty state_delta', () {
      const raw = '''
      {
        "messages": [
          {"speaker": "初雪", "text": "喵？"}
        ],
        "state_delta": {}
      }
      ''';

      final result = AiTurnResult.parse(raw);

      expect(result.isValidJson, isTrue);
      expect(result.stateDelta, isNotNull);
      expect(result.stateDelta!.affection, isNull);
      expect(result.stateDelta!.mood, isNull);
    });

    test('fall back to raw text on invalid JSON', () {
      const raw = '初雪: 啊哈哈，今天也挺好的呢~';

      final result = AiTurnResult.parse(raw);

      expect(result.isValidJson, isFalse);
      expect(result.messages.length, 1);
      expect(result.messages.first.text, raw);
      expect(result.messages.first.speaker, '初雪'); // Default speaker
      expect(result.choices, isEmpty);
      expect(result.stateDelta, isNull);
      expect(result.rawText, raw);
    });

    test('extract JSON from markdown code block', () {
      const raw = '''
Here is my response:
```json
{
  "messages": [
    {"speaker": "初雪", "text": "好的喵~"}
  ],
  "state_delta": {
    "affection": 1
  }
}
```
      ''';

      final result = AiTurnResult.parse(raw);

      expect(result.isValidJson, isTrue);
      expect(result.messages.first.text, '好的喵~');
      expect(result.stateDelta!.affection, 1);
    });

    test('extract JSON object from within other text', () {
      const raw = '''
Let me think about that...

{"messages": [{"speaker": "初雪", "text": "很有趣的想法呢喵!"}], "state_delta": {"mood": "兴奋"}}

How does that look?
      ''';

      final result = AiTurnResult.parse(raw);

      expect(result.isValidJson, isTrue);
      expect(result.messages.first.text, '很有趣的想法呢喵!');
      expect(result.stateDelta!.mood, '兴奋');
    });

    test('parse JSON with flags in state_delta', () {
      const raw = '''
      {
        "messages": [
          {"speaker": "初雪", "text": "主人...其实我一直想告诉你一件事喵..."}
        ],
        "state_delta": {
          "affection": 5,
          "mood": "害羞",
          "flags": {
            "confession_started": true,
            "deep_trust": true
          }
        }
      }
      ''';

      final result = AiTurnResult.parse(raw);

      expect(result.isValidJson, isTrue);
      expect(result.stateDelta!.flags, isNotNull);
      expect(result.stateDelta!.flags!['confession_started'], true);
      expect(result.stateDelta!.flags!['deep_trust'], true);
    });

    test('empty string returns raw text', () {
      final result = AiTurnResult.parse('');

      expect(result.isValidJson, isFalse);
      expect(result.messages.first.text, '');
    });
  });
}
