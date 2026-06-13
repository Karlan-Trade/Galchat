import 'package:flutter_test/flutter_test.dart';
import 'package:galchat/database/database.dart';
import 'package:galchat/state/chat_state.dart';

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
}
