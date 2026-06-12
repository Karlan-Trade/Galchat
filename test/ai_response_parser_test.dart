import 'package:flutter_test/flutter_test.dart';
import 'package:galchat/providers/ai_provider.dart';

void main() {
  group('AiTurnResult.parse', () {
    // The per-turn JSON contract ({messages, choices, state_delta}) is
    // deprecated. parse() now wraps the model's native output verbatim and
    // renders it as a single message — no JSON extraction, no choices, no
    // state delta.

    test('wraps plain text as a single message', () {
      const raw = '初雪: 啊哈哈，今天也挺好的呢~';

      final result = AiTurnResult.parse(raw);

      expect(result.isValidJson, isFalse);
      expect(result.messages.length, 1);
      expect(result.messages.first.text, raw);
      expect(result.messages.first.speaker, '初雪');
      expect(result.choices, isEmpty);
      expect(result.stateDelta, isNull);
      expect(result.rawText, raw);
    });

    test('does NOT extract JSON — renders it verbatim', () {
      const raw =
          '{"messages": [{"speaker": "初雪", "text": "好的喵~"}], "state_delta": {"affection": 1}}';

      final result = AiTurnResult.parse(raw);

      // The whole string is shown as-is; we no longer parse the contract.
      expect(result.messages.length, 1);
      expect(result.messages.first.text, raw);
      expect(result.choices, isEmpty);
      expect(result.stateDelta, isNull);
    });

    test('empty string returns empty message', () {
      final result = AiTurnResult.parse('');

      expect(result.isValidJson, isFalse);
      expect(result.messages.first.text, '');
    });
  });
}
