import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:galchat/constants/prompt_constants.dart';
import 'package:galchat/database/database.dart';
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
}

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this.path);

  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}
