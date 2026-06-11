import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../database/database.dart';
import '../providers/ai_provider.dart';
import '../providers/provider_factory.dart';
import '../services/api_key_service.dart';
import '../constants/prompt_constants.dart';
import '../services/narrative_tool_runner.dart';

/// Holds the UI state for a single chat conversation.
class ChatUiState {
  final int conversationId;
  final int characterId;
  final List<Message> messages;
  final List<Choice> pendingChoices;
  final bool isLoading;
  final bool isCompressing;
  final String? errorMessage;
  final String? rawResponse;
  final String streamingText;
  final String streamingReasoning;
  /// Last completed reasoning content (saved for review).
  final String lastReasoning;

  const ChatUiState({
    required this.conversationId,
    required this.characterId,
    this.messages = const [],
    this.pendingChoices = const [],
    this.isLoading = false,
    this.isCompressing = false,
    this.errorMessage,
    this.rawResponse,
    this.streamingText = '',
    this.streamingReasoning = '',
    this.lastReasoning = '',
  });

  ChatUiState copyWith({
    int? conversationId,
    int? characterId,
    List<Message>? messages,
    List<Choice>? pendingChoices,
    bool? isLoading,
    bool? isCompressing,
    String? errorMessage,
    String? rawResponse,
    bool clearError = false,
    bool clearRawResponse = false,
    String? streamingText,
    String? streamingReasoning,
    String? lastReasoning,
    bool clearStreamingText = false,
    bool clearStreamingReasoning = false,
    bool clearLastReasoning = false,
  }) {
    return ChatUiState(
      conversationId: conversationId ?? this.conversationId,
      characterId: characterId ?? this.characterId,
      messages: messages ?? this.messages,
      pendingChoices: pendingChoices ?? this.pendingChoices,
      isLoading: isLoading ?? this.isLoading,
      isCompressing: isCompressing ?? this.isCompressing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      rawResponse: clearRawResponse ? null : (rawResponse ?? this.rawResponse),
      streamingText: clearStreamingText ? '' : (streamingText ?? this.streamingText),
      streamingReasoning: clearStreamingReasoning ? '' : (streamingReasoning ?? this.streamingReasoning),
      lastReasoning: clearLastReasoning ? '' : (lastReasoning ?? this.lastReasoning),
    );
  }
}

class ChatNotifier extends ChangeNotifier {
  final AppDatabase _db;
  final ApiKeyService _apiKeyService;
  final AiSettings _aiSettings;

  ChatUiState? _state;
  Character? _character;
  StreamSubscription<AiStreamChunk>? _streamSubscription;
  String? _exampleDialogue;
  String? _openingPrompt;
  String _replyStylePrompt = '请以初雪的身份自然地回复主人的消息喵~';
  bool _includeExampleDialogue = true;
  bool _aiFirstMessage = true;
  bool _thinkingEnabled = true;
  bool _toolsEnabled = true;
  NarrativeToolRunner? _toolRunner;

  ChatNotifier(this._db, this._apiKeyService, this._aiSettings);

  /// Enable AI tool calling for narrative file read/write.
  void enableFileTools(NarrativeToolRunner runner) => _toolRunner = runner;

  ChatUiState? get state => _state;
  String get systemPrompt => _state != null ? _buildSystemPrompt() : '';

  /// Build the full prompt that will be sent to the AI (system + history).
  Future<String> buildFullPrompt() async {
    final current = _state;
    if (current == null) return '(加载中...)';

    final sp = _buildSystemPrompt();
    final msgs = await _db.getMessagesByConversation(current.conversationId);
    final nonSys = msgs.where((m) => m.role != 'system').toList();

    final buf = StringBuffer();
    buf.writeln('══════ SYSTEM PROMPT ══════');
    buf.writeln(sp);
    buf.writeln();

    if (nonSys.isNotEmpty) {
      buf.writeln('══════ 对话历史 (${nonSys.length}条) ══════');
      for (final m in nonSys) {
        buf.writeln('[${m.role}] ${m.content}');
        buf.writeln();
      }
    }

    buf.writeln('══════ 总计 ══════');
    final totalChars = sp.length + nonSys.fold(0, (s, m) => s + m.content.length);
    buf.writeln('System Prompt: ${sp.length} 字符');
    buf.writeln('对话历史: ${nonSys.length} 条');
    buf.writeln('总字符数: $totalChars');
    buf.writeln('预计 Tokens: ~${(totalChars * 0.5).round()} (中英文混合估算)');

    return buf.toString();
  }

  /// Set the example dialogue text (loaded from file by the caller).
  void setExampleDialogue(String text) => _exampleDialogue = text;

  /// Set the opening message prompt (loaded from file by the caller).
  void setOpeningPrompt(String text) => _openingPrompt = text;

  /// Toggle example dialogue inclusion.
  void setIncludeExampleDialogue(bool v) {
    _includeExampleDialogue = v;
  }

  /// Set whether AI should send the first message, or user types first.
  void setAiFirstMessage(bool v) => _aiFirstMessage = v;

  /// Set whether the provider uses thinking mode.
  void setThinkingEnabled(bool v) {
    // Applied on next sendMessage
  }

  /// Set whether tool calling (function calling) is enabled.
  void setToolsEnabled(bool v) => _toolsEnabled = v;

  /// Set the reply style prompt (loaded from file).
  void setReplyStylePrompt(String text) {
    _replyStylePrompt = text;
  }

  Future<void> loadConversation(int conversationId) async {
    final conv = await _db.getConversationById(conversationId);
    if (conv == null) return;

    _character = await _db.getCharacterById(conv.characterId);
    final messages = await _db.getMessagesByConversation(conversationId);
    final choices = await _db.getChoicesByConversation(conversationId);
    final pendingChoices = choices.where((c) => c.selectedAt == null).toList();

    _state = ChatUiState(conversationId: conversationId, characterId: conv.characterId, messages: messages, pendingChoices: pendingChoices);
    notifyListeners();

    // Trigger AI to send the first message if conversation is empty and toggle is on
    if (messages.isEmpty && _aiFirstMessage) {
      await _sendOpeningMessage();
    }
  }

  /// Ask the AI to generate the opening scene and first message.
  Future<void> _sendOpeningMessage() async {
    final current = _state;
    if (current == null) return;

    _state = current.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final apiKey = await _apiKeyService.getApiKey();
      final aiSettings = _aiSettings;

      if (apiKey == null || apiKey.isEmpty) {
        _state = _state!.copyWith(isLoading: false, errorMessage: '请先在设置中配置API Key喵~');
        notifyListeners();
        return;
      }

      if (_character == null) _character = await _db.getCharacterById(current.characterId);

      final provider = createAiProvider(apiKey: apiKey, settings: aiSettings)
        ..setThinkingEnabled(_thinkingEnabled);
      final systemPrompt = _buildSystemPrompt();

      final request = AiTurnRequest(
        systemPrompt: systemPrompt,
        history: [],
        userMessage: (_openingPrompt != null && _openingPrompt!.isNotEmpty)
            ? _openingPrompt!
            : '请开始我们的故事吧喵~（作为初雪，主动发送第一条消息。包括完整的场景描写、人物动作、对话，以及A/B/C/D四个选项）',
        currentState: {},
      );

      final result = await provider.sendTurn(request);
      final text = result.messages.map((m) => m.text).join('\n');
      final effectiveText = text.isNotEmpty ? text : result.rawText ?? '喵~ 初次见面，请多关照！';

      await _db.insertMessage(MessagesCompanion(
        conversationId: Value(current.conversationId),
        role: const Value('assistant'),
        speaker: const Value('初雪'),
        content: Value(effectiveText),
        createdAt: Value(DateTime.now()),
      ));

      await _db.touchConversation(current.conversationId);
      final updatedMessages = await _db.getMessagesByConversation(current.conversationId);

      _state = _state!.copyWith(messages: updatedMessages, isLoading: false);
      notifyListeners();
    } catch (e) {
      _state = _state!.copyWith(isLoading: false, errorMessage: '初雪还在准备喵... $e');
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    final current = _state;
    if (current == null || current.isLoading) return;

    _state = current.copyWith(isLoading: true, clearError: true, clearRawResponse: true, clearStreamingText: true, clearStreamingReasoning: true);
    notifyListeners();

    try {
      // Save user message
      final now = DateTime.now();
      await _db.insertMessage(MessagesCompanion(
        conversationId: Value(current.conversationId),
        role: const Value('user'),
        content: Value(text),
        createdAt: Value(now),
      ));
      await _db.touchConversation(current.conversationId);

      // Expire old choices
      final oldChoices = await _db.getChoicesByConversation(current.conversationId);
      for (final c in oldChoices.where((c) => c.selectedAt == null)) {
        await _db.markChoiceSelected(c.id);
      }

      // Build history
      final allMessages = await _db.getMessagesByConversation(current.conversationId);
      final nonSystem = allMessages.where((m) => m.role != 'system').toList();

      // Apply truncation strategy
      List<Message> contextMessages;
      if (_aiSettings.truncateStrategy == 'truncate') {
        final maxTurns = _aiSettings.truncateLimit;
        final maxMessages = maxTurns * 2; // user + assistant per turn
        contextMessages = nonSystem.length > maxMessages
            ? nonSystem.sublist(nonSystem.length - maxMessages)
            : nonSystem;
      } else {
        contextMessages = nonSystem;
      }

      final history = <Map<String, String>>[];
      for (final m in contextMessages) {
        history.add({'role': m.role, 'content': m.content});
      }

      final apiKey = await _apiKeyService.getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        _state = _state!.copyWith(isLoading: false, errorMessage: '请先在设置中配置API Key喵~');
        notifyListeners();
        return;
      }

      if (_character == null) _character = await _db.getCharacterById(current.characterId);

      final provider = createAiProvider(apiKey: apiKey, settings: _aiSettings)
        ..setThinkingEnabled(_thinkingEnabled);
      // Enable file tools if runner is available and tools are enabled
      if (_toolRunner != null && _toolsEnabled) provider.enableTools(_toolRunner!);

      final systemPrompt = _buildSystemPrompt();

      // Refresh message list after user message
      final refreshedMessages = await _db.getMessagesByConversation(current.conversationId);
      _state = _state!.copyWith(messages: refreshedMessages);
      notifyListeners();

      // ===== TOOL-CALL-AWARE STREAMING =====
      final allHistory = <Map<String, String>>[];
      for (final m in contextMessages) {
        allHistory.add({'role': m.role, 'content': m.content});
      }
      // Remove the last entry (user message we just saved — will re-add below)
      if (allHistory.isNotEmpty && allHistory.last['role'] == 'user') {
        allHistory.removeLast();
      }

      // Tool call loop: stream → detect tool calls → execute → re-stream
      final fullContent = StringBuffer();
      final reasoningContent = StringBuffer();
      bool streamingCompleted = false;
      bool hasStreamed = false;
      List<ToolCallRequest> pendingToolCalls = [];

      try {
        // Snapshot history for tool call loop
        var loopHistory = List<Map<String, String>>.from(allHistory);
        var loopUserMessage = text;
        List<Map<String, dynamic>>? loopToolResults;
        const maxToolLoops = 5;
        var toolLoopCount = 0;

        while (toolLoopCount < maxToolLoops) {
          toolLoopCount++;
          streamingCompleted = false;
          fullContent.clear();
          reasoningContent.clear();
          hasStreamed = false;
          pendingToolCalls = [];

          final request = AiTurnRequest(
            systemPrompt: systemPrompt,
            history: loopHistory,
            userMessage: loopUserMessage,
            currentState: {},
            toolResults: loopToolResults,
          );

          // Only update streamingText on first loop iteration
          if (toolLoopCount > 1) {
            _state = _state!.copyWith(streamingText: '（初雪正在查阅文件喵...）');
            notifyListeners();
          }

          final stream = provider.sendTurnStream(request);
          await for (final chunk in stream.timeout(const Duration(seconds: 30))) {
            if (chunk.isDone) {
              streamingCompleted = true;
              break;
            }
            if (chunk.toolCalls.isNotEmpty) {
              pendingToolCalls = chunk.toolCalls;
              continue;
            }
            if (chunk.reasoningDelta.isNotEmpty) {
              reasoningContent.write(chunk.reasoningDelta);
              if (_state!.isLoading) {
                _state = _state!.copyWith(streamingReasoning: reasoningContent.toString());
                notifyListeners();
              }
            }
            if (chunk.textDelta.isNotEmpty) {
              hasStreamed = true;
              fullContent.write(chunk.textDelta);
              if (_state!.isLoading) {
                _state = _state!.copyWith(
                  streamingText: fullContent.toString(),
                  streamingReasoning: reasoningContent.toString(),
                );
                notifyListeners();
              }
            }
          }

          if (!streamingCompleted) break; // timeout

          // If tool calls were detected, execute them all and loop
          if (pendingToolCalls.isNotEmpty && _toolRunner != null) {
            // Execute each tool call and build result messages
            final toolResultMessages = <Map<String, dynamic>>[];

            // Assistant message with all tool call requests
            toolResultMessages.add({
              'role': 'assistant',
              'content': null,
              'tool_calls': pendingToolCalls.map((tc) => {
                'id': tc.id,
                'type': 'function',
                'function': {
                  'name': tc.name,
                  'arguments': json.encode(tc.arguments),
                },
              }).toList(),
            });

            // Tool result messages (one per call)
            for (final tc in pendingToolCalls) {
              final result = await _toolRunner!.run(tc.name, tc.arguments);
              toolResultMessages.add({
                'role': 'tool',
                'tool_call_id': tc.id,
                'content': result,
              });
            }

            loopHistory = List<Map<String, String>>.from(allHistory);
            loopUserMessage = text;
            loopToolResults = toolResultMessages;
            continue; // re-loop with tool results
          }

          // No tool call → normal response, break out
          break;
        }

        if (hasStreamed && fullContent.isNotEmpty) {
          _state = _state!.copyWith(lastReasoning: reasoningContent.toString());
          notifyListeners();
          await _processAiResponse(
              current.conversationId, fullContent.toString(), provider,
              AiTurnRequest(systemPrompt: systemPrompt, history: allHistory, userMessage: text, currentState: {}));
        } else if (!hasStreamed && fullContent.isEmpty) {
          await _fallbackNonStreaming(current.conversationId, provider,
              AiTurnRequest(systemPrompt: systemPrompt, history: allHistory, userMessage: text, currentState: {}), '');
        }
      } catch (e) {
        _streamSubscription = null;
        if (!streamingCompleted) {
          await _fallbackNonStreaming(current.conversationId, provider,
              AiTurnRequest(systemPrompt: systemPrompt, history: allHistory, userMessage: text, currentState: {}), fullContent.toString());
        }
      }
    } on AiAuthException catch (e) {
      _state = _state!.copyWith(isLoading: false, errorMessage: e.message, clearStreamingText: true);
      notifyListeners();
    } catch (e) {
      _state = _state!.copyWith(isLoading: false, errorMessage: '发送失败喵... $e', clearStreamingText: true);
      notifyListeners();
    }
  }

  /// Save AI response, or fall back to non-streaming if empty.
  Future<void> _processAiResponse(
    int conversationId,
    String generatedText,
    AiProvider provider,
    AiTurnRequest request,
  ) async {
    if (generatedText.isEmpty) {
      await _fallbackNonStreaming(conversationId, provider, request, '');
      return;
    }

    await _db.insertMessage(MessagesCompanion(
      conversationId: Value(conversationId),
      role: const Value('assistant'),
      speaker: const Value('初雪'),
      content: Value(generatedText),
      createdAt: Value(DateTime.now()),
    ));

    await _db.touchConversation(conversationId);

    final updatedMessages = await _db.getMessagesByConversation(conversationId);

    _state = _state!.copyWith(
      messages: updatedMessages,
      isLoading: false,
      clearStreamingText: true,
      clearStreamingReasoning: true,
    );
    notifyListeners();
  }

  /// Fallback: call the non-streaming API endpoint when streaming fails.
  Future<void> _fallbackNonStreaming(
    int conversationId,
    AiProvider provider,
    AiTurnRequest request,
    String streamedSoFar,
  ) async {
    try {
      final result = await provider.sendTurn(request);
      final responseText = result.messages.isNotEmpty
          ? result.messages.map((m) => m.text).join('\n')
          : result.rawText ?? streamedSoFar;

      final effectiveText = responseText.isNotEmpty ? responseText : '（初雪打了个盹喵...）';

      await _db.insertMessage(MessagesCompanion(
        conversationId: Value(conversationId),
        role: const Value('assistant'),
        speaker: const Value('初雪'),
        content: Value(effectiveText),
        createdAt: Value(DateTime.now()),
      ));

      await _db.touchConversation(conversationId);

      final updatedMessages = await _db.getMessagesByConversation(conversationId);

      _state = _state!.copyWith(
        messages: updatedMessages,
        isLoading: false,
        clearStreamingText: true,
      );
      notifyListeners();
    } catch (e) {
      if (e is AiAuthException) {
        _state = _state!.copyWith(isLoading: false, errorMessage: e.message, clearStreamingText: true);
      } else {
        _state = _state!.copyWith(isLoading: false, errorMessage: '发送失败喵... $e', clearStreamingText: true);
      }
      notifyListeners();
    }
  }

  Future<void> retry() async => await regenerate();

  /// Delete the last AI message and resend the last user message.
  Future<void> regenerate() async {
    final current = _state;
    if (current == null || current.isLoading) return;

    final msgs = await _db.getMessagesByConversation(current.conversationId);
    final nonSys = msgs.where((m) => m.role != 'system').toList();
    if (nonSys.isEmpty) return;

    final lastUser = nonSys.lastWhere((m) => m.role == 'user', orElse: () => nonSys.first);
    final lastAi = nonSys.lastWhere((m) => m.role == 'assistant', orElse: () => nonSys.first);
    if (lastAi.role == 'assistant') await _db.deleteMessage(lastAi.id);

    await loadConversation(current.conversationId);
    await sendMessage(lastUser.content);
  }

  /// Edit a user message and resend from that point, deleting all later messages.
  Future<void> editAndResend(int messageId, String newText) async {
    final current = _state;
    if (current == null || current.isLoading) return;

    final msgs = await _db.getMessagesByConversation(current.conversationId);
    final sorted = msgs.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final idx = sorted.indexWhere((m) => m.id == messageId);
    if (idx < 0) return;

    for (int i = idx; i < sorted.length; i++) {
      await _db.deleteMessage(sorted[i].id);
    }

    await loadConversation(current.conversationId);
    await sendMessage(newText);
  }

  /// Compress the conversation history via a side-channel AI call.
  ///
  /// Keeps the last 3 turns (≈6 messages) unsummarized and sends
  /// everything older to the compressor. The resulting summary is
  /// stored as a system message and old messages are deleted.
  Future<void> compressContext() async {
    final current = _state;
    if (current == null || current.isCompressing || current.isLoading) return;

    _state = current.copyWith(isCompressing: true, clearError: true);
    notifyListeners();

    try {
      final apiKey = await _apiKeyService.getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        _state = _state!.copyWith(isCompressing: false, errorMessage: '请先配置API Key喵~');
        notifyListeners();
        return;
      }

      final allMessages = await _db.getMessagesByConversation(current.conversationId);
      final nonSystem = allMessages.where((m) => m.role != 'system').toList();

      // Need at least 4 turns (8 messages) for compression to be worthwhile
      if (nonSystem.length < 8) {
        _state = _state!.copyWith(isCompressing: false);
        notifyListeners();
        return;
      }

      // Keep last 3 turns (6 messages), compress the rest
      const keepCount = 6;
      final toCompress = nonSystem.sublist(0, nonSystem.length - keepCount);
      final toKeep = nonSystem.sublist(nonSystem.length - keepCount);

      final oldHistory = toCompress
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      if (_character == null) _character = await _db.getCharacterById(current.characterId);

      final provider = createAiProvider(apiKey: apiKey, settings: _aiSettings)
        ..setThinkingEnabled(_thinkingEnabled);
      final summary = await provider.compressHistory(
        systemPrompt: _character?.systemPrompt ?? '',
        oldMessages: oldHistory,
      );

      if (summary.isEmpty) {
        _state = _state!.copyWith(isCompressing: false);
        notifyListeners();
        return;
      }

      // Delete summarized messages from DB
      await _db.transaction(() async {
        for (final m in toCompress) {
          await _db.deleteMessage(m.id);
        }
        // Insert compressed summary as a system message at the start
        await _db.insertMessage(MessagesCompanion(
          conversationId: Value(current.conversationId),
          role: const Value('system'),
          speaker: const Value(''),
          content: Value('[上下文摘要]\n$summary'),
          createdAt: Value(toKeep.first.createdAt.subtract(const Duration(seconds: 1))),
        ));
      });

      // Reload
      await loadConversation(current.conversationId);
      _state = _state!.copyWith(isCompressing: false);
      notifyListeners();
    } catch (e) {
      _state = _state!.copyWith(isCompressing: false, errorMessage: '压缩失败喵: $e');
      notifyListeners();
    }
  }

  String _buildSystemPrompt() {
    final charPrompt = _character?.systemPrompt ?? '';
    final dialogue = (_includeExampleDialogue && _exampleDialogue != null && _exampleDialogue!.isNotEmpty)
        ? '\n## 示例对话（请严格遵循此格式）\n\n$_exampleDialogue\n'
        : '';
    final tools = _toolsEnabled ? toolInstructions : '';
    return '''$charPrompt
$tools
$dialogue
$_replyStylePrompt''';
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
