import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:galchat/constants/prompt_constants.dart';
import 'package:galchat/database/database.dart';
import 'package:galchat/providers/ai_provider.dart';
import 'package:galchat/services/narrative_service.dart';
import 'package:galchat/services/narrative_tool_runner.dart';
import 'package:galchat/state/chat_state.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

void main() {
  test('local fallback greeting explains why it appears', () {
    expect(defaultCharacterGreeting, contains('本地兜底提示'));
    expect(defaultCharacterGreeting, contains('AI 开场生成没有返回可显示正文'));
    expect(defaultCharacterGreeting, isNot(contains('初次见面')));
  });

  test('empty AI response fallback is explicit error text', () {
    expect(emptyAiResponseFallbackText, contains('本地兜底提示'));
    expect(emptyAiResponseFallbackText, contains('没有返回可显示正文'));
    expect(emptyAiResponseFallbackText, isNot(contains('打了个盹')));
  });

  test('tool call placeholder is explicit local status text', () {
    expect(toolCallInProgressText, contains('本地状态提示'));
    expect(toolCallInProgressText, contains('工具调用'));
    expect(toolCallInProgressText, contains('正在查阅文件'));
  });

  test('tool instructions include long-term memory file', () {
    expect(toolInstructions, contains('memory.md'));
    expect(toolInstructions, contains('长期记忆'));
  });

  test('tool runner routes memory file through conversation memory', () async {
    final tempDir =
        await Directory.systemTemp.createTemp('galchat_memory_test_');
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempDir.path);
    final service = NarrativeService();
    await service.init();
    final runner = NarrativeToolRunner(service, conversationId: 42);

    await runner.run('write_file', {
      'filename': 'memory.md',
      'content': '只属于当前对话',
    });
    final content = await runner.run('read_file', {'filename': 'memory.md'});

    expect(content, '只属于当前对话');
    expect(await service.readConversationMemory(42), '只属于当前对话');
    expect(await service.readConversationMemory(7), '');

    await tempDir.delete(recursive: true);
  });

  test('compressed context summary is included in system prompt', () {
    final now = DateTime(2026, 6, 14, 16);
    final payload = buildContextPayload(
      systemPrompt: '角色卡',
      settings: const AiSettings(
        baseUrl: 'https://example.test',
        model: 'test-model',
        truncateStrategy: 'compress',
      ),
      messages: [
        _message(
          id: 1,
          role: 'system',
          content: '$compressedContextMarker\n主人和初雪已经约定放学后去天台。',
          createdAt: now,
        ),
        _message(
          id: 2,
          role: 'assistant',
          content: '那就说好了喵。',
          createdAt: now.add(const Duration(seconds: 1)),
        ),
      ],
    );

    expect(payload.systemPrompt, contains('角色卡'));
    expect(payload.systemPrompt, contains('已压缩的对话上下文'));
    expect(payload.systemPrompt, contains('天台'));
    expect(payload.history, [
      {'role': 'assistant', 'content': '那就说好了喵。'},
    ]);
  });

  test('truncate strategy keeps compressed summary while trimming chat history',
      () {
    final now = DateTime(2026, 6, 14, 16);
    final payload = buildContextPayload(
      systemPrompt: '角色卡',
      settings: const AiSettings(
        baseUrl: 'https://example.test',
        model: 'test-model',
        truncateStrategy: 'truncate',
        truncateLimit: 1,
      ),
      messages: [
        _message(
          id: 1,
          role: 'system',
          content: '$compressedContextMarker\n旧剧情摘要',
          createdAt: now,
        ),
        _message(
          id: 2,
          role: 'user',
          content: '旧用户消息',
          createdAt: now.add(const Duration(seconds: 1)),
        ),
        _message(
          id: 3,
          role: 'assistant',
          content: '旧助手消息',
          createdAt: now.add(const Duration(seconds: 2)),
        ),
        _message(
          id: 4,
          role: 'user',
          content: '最新用户消息',
          createdAt: now.add(const Duration(seconds: 3)),
        ),
        _message(
          id: 5,
          role: 'assistant',
          content: '最新助手消息',
          createdAt: now.add(const Duration(seconds: 4)),
        ),
      ],
    );

    expect(payload.systemPrompt, contains('旧剧情摘要'));
    expect(payload.history, [
      {'role': 'user', 'content': '最新用户消息'},
      {'role': 'assistant', 'content': '最新助手消息'},
    ]);
  });

  test('system prompt preview payload excludes normal user conversation', () {
    final now = DateTime(2026, 6, 14, 16);
    final payload = buildContextPayload(
      systemPrompt: '角色卡',
      settings: const AiSettings(
        baseUrl: 'https://example.test',
        model: 'test-model',
        truncateStrategy: 'compress',
      ),
      messages: [
        _message(
          id: 1,
          role: 'system',
          content: '$compressedContextMarker\n压缩后的剧情事实',
          createdAt: now,
        ),
        _message(
          id: 2,
          role: 'user',
          content: '这是一条普通用户对话',
          createdAt: now.add(const Duration(seconds: 1)),
        ),
      ],
    );

    expect(payload.systemPrompt, contains('压缩后的剧情事实'));
    expect(payload.systemPrompt, isNot(contains('这是一条普通用户对话')));
  });
}

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this.path);

  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

Message _message({
  required int id,
  required String role,
  required String content,
  required DateTime createdAt,
}) {
  return Message(
    id: id,
    conversationId: 1,
    role: role,
    speaker: role == 'assistant' ? '初雪' : null,
    content: content,
    rawPayload: null,
    reasoningContent: null,
    createdAt: createdAt,
  );
}
