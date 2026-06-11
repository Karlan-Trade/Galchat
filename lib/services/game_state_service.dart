import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/ai_provider.dart';

/// Validates and merges AI-delivered state deltas into the canonical game state.
///
/// The app OWNS final state — never trust raw AI deltas blindly.
/// Invalid field values are logged and dropped during merge.
class GameStateService {
  final AppDatabase _db;

  GameStateService(this._db);

  /// Allowed mood values.
  static const _validMoods = [
    '平静',
    '开心',
    '害羞',
    '期待',
    '担心',
    '生气',
    '寂寞',
    '兴奋',
    '困惑',
    '感动',
  ];

  /// Allowed time slot values.
  static const _validTimeSlots = [
    '早晨',
    '午休',
    '放学后',
    '傍晚',
    '夜晚',
    '深夜',
  ];

  /// Merge a [StateDelta] from the AI into the conversation's game state.
  ///
  /// Returns the merged state map.
  Future<Map<String, dynamic>> mergeDelta({
    required int conversationId,
    required StateDelta? delta,
  }) async {
    final current = await _db.getGameState(conversationId);
    final currentFlags = _parseFlags(current?.flagsJson);

    final merged = <String, dynamic>{
      'affection': current?.affection ?? 0,
      'mood': current?.mood ?? '平静',
      'scene': current?.scene ?? '教室',
      'time_slot': current?.timeSlot ?? '放学后',
      'flags': Map<String, dynamic>.from(currentFlags),
    };

    if (delta == null) return merged;

    // affection: must be an int within reasonable bounds
    if (delta.affection != null) {
      final newVal = (merged['affection'] as int) + delta.affection!;
      merged['affection'] = newVal.clamp(-999, 999);
    }

    // mood: must be a recognized value
    if (delta.mood != null && _validMoods.contains(delta.mood)) {
      merged['mood'] = delta.mood;
    }

    // scene: free-form, but sanitize length
    if (delta.scene != null) {
      merged['scene'] = delta.scene!.length > 50 ? delta.scene!.substring(0, 50) : delta.scene!;
    }

    // time_slot: must be a recognized value
    if (delta.timeSlot != null && _validTimeSlots.contains(delta.timeSlot)) {
      merged['time_slot'] = delta.timeSlot;
    }

    // flags: merge (don't replace) — only top-level keys
    if (delta.flags != null) {
      final flags = Map<String, dynamic>.from(merged['flags'] as Map);
      for (final entry in delta.flags!.entries) {
        // Only accept bool values for flags
        if (entry.value is bool) {
          flags[entry.key] = entry.value;
        }
      }
      merged['flags'] = flags;
    }

    // Persist the merged state
    await _db.upsertGameState(GameStatesCompanion(
      conversationId: Value(conversationId),
      affection: Value(merged['affection'] as int),
      mood: Value(merged['mood'] as String),
      scene: Value(merged['scene'] as String),
      timeSlot: Value(merged['time_slot'] as String),
      flagsJson: Value(jsonEncode(merged['flags'])),
      updatedAt: Value(DateTime.now()),
    ));

    return merged;
  }

  /// Get the current game state for a conversation.
  Future<Map<String, dynamic>> getState(int conversationId) async {
    final existing = await _db.getGameState(conversationId);
    if (existing == null) {
      return {
        'affection': 0,
        'mood': '平静',
        'scene': '教室',
        'time_slot': '放学后',
        'flags': <String, dynamic>{},
      };
    }
    return {
      'affection': existing.affection,
      'mood': existing.mood,
      'scene': existing.scene,
      'time_slot': existing.timeSlot,
      'flags': _parseFlags(existing.flagsJson),
    };
  }

  /// Initialize default game state for a new conversation.
  Future<void> initState({
    required int conversationId,
    int affection = 0,
    String mood = '平静',
    String scene = '教室',
    String timeSlot = '放学后',
  }) async {
    await _db.upsertGameState(GameStatesCompanion(
      conversationId: Value(conversationId),
      affection: Value(affection),
      mood: Value(mood),
      scene: Value(scene),
      timeSlot: Value(timeSlot),
      flagsJson: const Value('{}'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Map<String, dynamic> _parseFlags(String? json) {
    if (json == null || json.isEmpty) return {};
    try {
      final parsed = jsonDecode(json);
      if (parsed is Map<String, dynamic>) return parsed;
      return {};
    } catch (_) {
      return {};
    }
  }
}

/// Riverpod provider for the game state service.
final gameStateServiceProvider = Provider<GameStateService>((ref) {
  final db = ref.watch(databaseProvider);
  return GameStateService(db);
});
