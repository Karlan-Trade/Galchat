import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

/// Tests the game state delta merge logic.
///
/// Note: These test the core merge algorithm in isolation.
/// The GameStateService depends on AppDatabase, so we test the merge
/// rules directly rather than through the service class.
void main() {
  group('State delta merge logic', () {
    Map<String, dynamic> createDefaultState() {
      return {
        'affection': 0,
        'mood': '平静',
        'scene': '教室',
        'time_slot': '放学后',
        'flags': <String, dynamic>{},
      };
    }

    Map<String, dynamic> mergeState(
      Map<String, dynamic> current,
      Map<String, dynamic>? delta,
    ) {
      if (delta == null) return current;

      final merged = Map<String, dynamic>.from(current);

      // affection: accumulate
      if (delta['affection'] != null) {
        merged['affection'] =
            ((merged['affection'] as int) + (delta['affection'] as int)).clamp(-999, 999);
      }

      // mood: replace if valid
      const validMoods = [
        '平静', '开心', '害羞', '期待', '担心', '生气', '寂寞', '兴奋', '困惑', '感动',
      ];
      if (delta['mood'] != null && validMoods.contains(delta['mood'])) {
        merged['mood'] = delta['mood'];
      }

      // scene: replace with length cap
      if (delta['scene'] != null) {
        final s = delta['scene'] as String;
        merged['scene'] = s.length > 50 ? s.substring(0, 50) : s;
      }

      // time_slot: replace if valid
      const validTimeSlots = ['早晨', '午休', '放学后', '傍晚', '夜晚', '深夜'];
      if (delta['time_slot'] != null && validTimeSlots.contains(delta['time_slot'])) {
        merged['time_slot'] = delta['time_slot'];
      }

      // flags: merge top-level keys
      if (delta['flags'] != null) {
        final flags = Map<String, dynamic>.from(merged['flags'] as Map);
        for (final entry in (delta['flags'] as Map<String, dynamic>).entries) {
          if (entry.value is bool) {
            flags[entry.key] = entry.value;
          }
        }
        merged['flags'] = flags;
      }

      return merged;
    }

    test('null delta leaves state unchanged', () {
      final state = createDefaultState();
      final result = mergeState(state, null);

      expect(result['affection'], 0);
      expect(result['mood'], '平静');
      expect(result['scene'], '教室');
      expect(result['time_slot'], '放学后');
    });

    test('affection accumulates', () {
      final state = createDefaultState();
      state['affection'] = 10;

      final result = mergeState(state, {'affection': 3});

      expect(result['affection'], 13);
    });

    test('affection clamped to bounds', () {
      var state = createDefaultState();
      state['affection'] = 998;

      final result = mergeState(state, {'affection': 5});

      expect(result['affection'], 999); // clamped

      state['affection'] = -998;
      final result2 = mergeState(state, {'affection': -5});
      expect(result2['affection'], -999); // clamped
    });

    test('mood only updated with valid values', () {
      final state = createDefaultState();

      // Valid mood
      var result = mergeState(state, {'mood': '开心'});
      expect(result['mood'], '开心');

      // Invalid mood — ignored
      result = mergeState(result, {'mood': 'invalid_mood'});
      expect(result['mood'], '开心'); // unchanged
    });

    test('scene length capped at 50 chars', () {
      final state = createDefaultState();
      final longScene = 'A' * 60;

      final result = mergeState(state, {'scene': longScene});

      expect((result['scene'] as String).length, 50);
    });

    test('time_slot only updated with valid values', () {
      final state = createDefaultState();

      // Valid time slot
      var result = mergeState(state, {'time_slot': '夜晚'});
      expect(result['time_slot'], '夜晚');

      // Invalid time slot — ignored
      result = mergeState(result, {'time_slot': 'invalid_time'});
      expect(result['time_slot'], '夜晚'); // unchanged
    });

    test('flags merge without overwriting unrelated keys', () {
      final state = createDefaultState();
      (state['flags'] as Map)['existing_flag'] = true;

      final result = mergeState(state, {
        'flags': {'new_flag': true}
      });

      final flags = result['flags'] as Map<String, dynamic>;
      expect(flags['existing_flag'], true); // preserved
      expect(flags['new_flag'], true); // added
    });

    test('flags only accept bool values', () {
      final state = createDefaultState();

      final result = mergeState(state, {
        'flags': {
          'valid_bool': true,
          'invalid_string': 'should be ignored',
          'invalid_number': 42,
        }
      });

      final flags = result['flags'] as Map<String, dynamic>;
      expect(flags['valid_bool'], true);
      expect(flags.containsKey('invalid_string'), false);
      expect(flags.containsKey('invalid_number'), false);
    });

    test('multiple fields update together', () {
      final state = createDefaultState();
      state['affection'] = 5;

      final result = mergeState(state, {
        'affection': 3,
        'mood': '感动',
        'scene': '屋顶',
        'time_slot': '傍晚',
        'flags': {'shared_secret': true},
      });

      expect(result['affection'], 8);
      expect(result['mood'], '感动');
      expect(result['scene'], '屋顶');
      expect(result['time_slot'], '傍晚');
      expect((result['flags'] as Map)['shared_secret'], true);
    });

    test('empty delta does not change state', () {
      final state = createDefaultState();
      state['affection'] = 5;
      state['mood'] = '困惑';

      final result = mergeState(state, {});

      expect(result['affection'], 5);
      expect(result['mood'], '困惑');
    });
  });
}
