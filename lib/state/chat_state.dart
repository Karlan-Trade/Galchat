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

typedef ChatAiProviderFactory = AiProvider Function({
  required String apiKey,
  required AiSettings settings,
});

const String emptyAiResponseFallbackText = '（本地兜底提示）AI 请求没有返回可显示正文喵...'
    '流式和非流式兜底都没有拿到有效内容。'
    '这通常是接口超时、网络中断、模型一直停留在思考阶段，'
    '或 API 返回为空导致的。可以点重试，或关闭思考模式/工具调用后再试。';

const String toolCallInProgressText = '（本地状态提示）初雪正在查阅文件喵...'
    'AI 正在执行工具调用并等待返回正文。'
    '如果长时间停留在这里，通常是模型还在持续思考、反复请求读写文件，'
    '或接口流尚未结束。可以继续等待，或点停止后重试。';

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
      streamingText:
          clearStreamingText ? '' : (streamingText ?? this.streamingText),
      streamingReasoning: clearStreamingReasoning
          ? ''
          : (streamingReasoning ?? this.streamingReasoning),
      lastReasoning:
          clearLastReasoning ? '' : (lastReasoning ?? this.lastReasoning),
    );
  }
}

class ChatNotifier extends ChangeNotifier {
  final AppDatabase _db;
  final ApiKeyService _apiKeyService;
  final AiSettings _aiSettings;
  final ChatAiProviderFactory _providerFactory;
  final Duration _streamIdleTimeout;
  final Duration _fallbackTimeout;

  ChatUiState? _state;
  Character? _character;
  StreamSubscription<AiStreamChunk>? _streamSubscription;
  Completer<void>? _streamCompleter;
  bool _isDisposed = false;
  bool _cancelled = false;
  String? _exampleDialogue;
  String? _openingPrompt;
  String _replyStylePrompt = '';
  bool _includeExampleDialogue = true;
  bool _aiFirstMessage = true;
  bool _thinkingEnabled = true;
  bool _toolsEnabled = true;
  NarrativeToolRunner? _toolRunner;

  ChatNotifier(
    this._db,
    this._apiKeyService,
    this._aiSettings, {
    ChatAiProviderFactory providerFactory = createAiProvider,
    Duration streamIdleTimeout = const Duration(seconds: 30),
    Duration fallbackTimeout = const Duration(seconds: 45),
  })  : _providerFactory = providerFactory,
        _streamIdleTimeout = streamIdleTimeout,
        _fallbackTimeout = fallbackTimeout;

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
    final totalChars =
        sp.length + nonSys.fold(0, (s, m) => s + m.content.length);
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
  void setThinkingEnabled(bool v) => _thinkingEnabled = v;

  /// Set whether tool calling (function calling) is enabled.
  void setToolsEnabled(bool v) => _toolsEnabled = v;

  /// Set the reply style prompt (loaded from file).
  void setReplyStylePrompt(String text) {
    _replyStylePrompt = text;
  }

  /// Cancel any ongoing stream subscription and reset streaming state.
  void _cancelStreamSubscription() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    if (_streamCompleter != null && !_streamCompleter!.isCompleted) {
      _streamCompleter!.complete();
    }
    _streamCompleter = null;
  }

  /// Cancel the ongoing AI generation. Saves any already-streamed text as a
  /// partial assistant message so the user doesn't lose generated content.
  Future<void> cancelGeneration() async {
    final current = _state;
    if (current == null || !current.isLoading) return;

    // Signal the stream loop to stop before we cancel — prevents
    // _streamTurnWithTools from also saving a message.
    _cancelled = true;
    _cancelStreamSubscription();

    await _savePartialGeneration(current, interruptedByDispose: false);
    notifyListeners();
  }

  Future<void> _savePartialGeneration(
    ChatUiState current, {
    required bool interruptedByDispose,
  }) async {
    final partialText = current.streamingText;
    final partialReasoning = current.streamingReasoning;

    try {
      if (partialText.isNotEmpty || partialReasoning.isNotEmpty) {
        final suffix = interruptedByDispose ? '（已在离开页面时保存喵~）' : '（已被主人打断喵~）';
        final savedContent = partialText.isNotEmpty
            ? '$partialText\n\n*$suffix*'
            : '（已保存思考过程喵...）';
        await _db.insertMessage(MessagesCompanion(
          conversationId: Value(current.conversationId),
          role: const Value('assistant'),
          speaker: const Value('初雪'),
          content: Value(savedContent),
          reasoningContent: partialReasoning.isNotEmpty
              ? Value(partialReasoning)
              : const Value.absent(),
          createdAt: Value(DateTime.now()),
        ));
        await _db.touchConversation(current.conversationId);
      }

      if (!_isDisposed) {
        final updatedMessages =
            await _db.getMessagesByConversation(current.conversationId);
        _state = _state!.copyWith(
          messages: updatedMessages,
          isLoading: false,
          clearStreamingText: true,
          clearStreamingReasoning: true,
          lastReasoning: partialReasoning,
        );
      }
    } catch (_) {
      if (!_isDisposed) {
        _state = _state!.copyWith(
          isLoading: false,
          clearStreamingText: true,
          clearStreamingReasoning: true,
          lastReasoning: partialReasoning,
        );
      }
    }
  }

  Future<void> loadConversation(int conversationId) async {
    // Cancel any ongoing AI request from a previous page session.
    _cancelStreamSubscription();
    // Reset loading state so stale operations don't corrupt the new session.
    if (_state?.isLoading == true) {
      _state = _state!.copyWith(
          isLoading: false,
          clearStreamingText: true,
          clearStreamingReasoning: true);
    }

    final conv = await _db.getConversationById(conversationId);
    if (conv == null) return;

    _character = await _db.getCharacterById(conv.characterId);
    final messages = await _db.getMessagesByConversation(conversationId);
    final choices = await _db.getChoicesByConversation(conversationId);
    final pendingChoices = choices.where((c) => c.selectedAt == null).toList();
    final reasonedMessages = messages.where((m) =>
        m.role == 'assistant' &&
        m.reasoningContent != null &&
        m.reasoningContent!.isNotEmpty);
    final lastReasoning = reasonedMessages.isNotEmpty
        ? reasonedMessages.last.reasoningContent!
        : '';

    _state = ChatUiState(
        conversationId: conversationId,
        characterId: conv.characterId,
        messages: messages,
        pendingChoices: pendingChoices,
        lastReasoning: lastReasoning);
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

    _cancelStreamSubscription();
    _state = current.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final apiKey = await _apiKeyService.getApiKey();
      final aiSettings = _aiSettings;

      if (apiKey == null || apiKey.isEmpty) {
        _state = _state!
            .copyWith(isLoading: false, errorMessage: '请先在设置中配置API Key喵~');
        notifyListeners();
        return;
      }

      _character ??= await _db.getCharacterById(current.characterId);

      final provider = _providerFactory(apiKey: apiKey, settings: aiSettings)
        ..setThinkingEnabled(_thinkingEnabled);
      // Sync tool calling to the tools toggle (same as a normal turn).
      if (_toolRunner != null && _toolsEnabled)
        provider.enableTools(_toolRunner!);

      // includeTools defaults to true; _buildSystemPrompt only injects tool
      // instructions when _toolsEnabled is also on, so this stays in sync.
      final systemPrompt = _buildSystemPrompt();

      // Opening message streams just like a normal turn, with the same
      // tool-call loop. History is empty; the opening prompt is the trigger.
      await _streamTurnWithTools(
        conversationId: current.conversationId,
        systemPrompt: systemPrompt,
        allHistory: const [],
        userMessage: _openingPrompt ?? '',
        provider: provider,
        emptyFallbackText: defaultCharacterGreeting,
      );
    } catch (e) {
      _state =
          _state!.copyWith(isLoading: false, errorMessage: '初雪还在准备喵... $e');
      notifyListeners();
    }
  }

  /// Stream one AI turn with a tool-call loop. Shared by the opening message
  /// and normal user turns. Streams text/reasoning deltas, detects tool calls,
  /// executes them via [_toolRunner], and re-streams up to 5 times. Falls back
  /// to a non-streaming call on timeout or empty output.
  ///
  /// Uses [Stream.listen] + [Completer] so that the subscription can be
  /// cancelled when the user exits the page or starts a new request.
  Future<void> _streamTurnWithTools({
    required int conversationId,
    required String systemPrompt,
    required List<Map<String, String>> allHistory,
    required String userMessage,
    required AiProvider provider,
    String emptyFallbackText = '',
  }) async {
    if (_isDisposed) return;

    _cancelled = false;

    final fullContent = StringBuffer();
    final reasoningContent = StringBuffer();
    final accumulatedReasoning = StringBuffer();
    bool streamingCompleted = false;
    bool hasStreamed = false;
    List<ToolCallRequest> pendingToolCalls = [];

    final baseRequest = AiTurnRequest(
      systemPrompt: systemPrompt,
      history: allHistory,
      userMessage: userMessage,
      currentState: {},
    );

    try {
      var loopHistory = List<Map<String, String>>.from(allHistory);
      var loopUserMessage = userMessage;
      final loopToolResults = <Map<String, dynamic>>[];
      var toolLoopCount = 0;

      while (true) {
        if (_isDisposed) return;
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
          toolResults: loopToolResults.isEmpty ? null : loopToolResults,
        );

        // Only update streamingText on second+ loop iteration
        if (toolLoopCount > 1 && !_isDisposed) {
          _state = _state!.copyWith(streamingText: toolCallInProgressText);
          notifyListeners();
        }

        final stream = provider.sendTurnStream(request);

        // Use listen() + Completer instead of await-for so the subscription
        // can be cancelled externally via _cancelStreamSubscription().
        final completer = Completer<void>();
        _streamCompleter = completer;

        _streamSubscription = stream.timeout(_streamIdleTimeout).listen(
          (chunk) {
            if (_isDisposed) {
              if (!completer.isCompleted) completer.complete();
              return;
            }
            if (chunk.isDone) {
              streamingCompleted = true;
              if (!completer.isCompleted) completer.complete();
              return;
            }
            if (chunk.toolCalls.isNotEmpty) {
              pendingToolCalls = chunk.toolCalls;
              return; // 'continue' in the old await-for: skip text/reasoning for this chunk
            }
            if (chunk.reasoningDelta.isNotEmpty) {
              reasoningContent.write(chunk.reasoningDelta);
              accumulatedReasoning.write(chunk.reasoningDelta);
              if (_state?.isLoading == true) {
                _state = _state!.copyWith(
                    streamingReasoning: accumulatedReasoning.toString());
                notifyListeners();
              }
            }
            if (chunk.textDelta.isNotEmpty) {
              hasStreamed = true;
              fullContent.write(chunk.textDelta);
              if (_state?.isLoading == true) {
                _state = _state!.copyWith(
                  streamingText: fullContent.toString(),
                  streamingReasoning: accumulatedReasoning.toString(),
                );
                notifyListeners();
              }
            }
          },
          onDone: () {
            if (!completer.isCompleted) completer.complete();
          },
          onError: (e) {
            // If disposed, suppress the error and resolve the completer so
            // we don't leave the await hanging.
            if (_isDisposed && !completer.isCompleted) {
              completer.complete();
            } else if (!completer.isCompleted) {
              completer.completeError(e);
            }
          },
          cancelOnError: false,
        );

        await completer.future;
        _streamSubscription = null;
        _streamCompleter = null;

        if (_isDisposed) return;
        if (_cancelled) return;
        if (!streamingCompleted) break; // timeout or error

        // If tool calls were detected, execute them all and loop
        if (pendingToolCalls.isNotEmpty && _toolRunner != null) {
          final toolResultMessages = <Map<String, dynamic>>[];

          toolResultMessages.add({
            'role': 'assistant',
            'content': null,
            'tool_calls': pendingToolCalls
                .map((tc) => {
                      'id': tc.id,
                      'type': 'function',
                      'function': {
                        'name': tc.name,
                        'arguments': json.encode(tc.arguments),
                      },
                    })
                .toList(),
          });

          for (final tc in pendingToolCalls) {
            final result = await _toolRunner!.run(tc.name, tc.arguments);
            toolResultMessages.add({
              'role': 'tool',
              'tool_call_id': tc.id,
              'content': result,
            });
          }

          loopHistory = List<Map<String, String>>.from(allHistory);
          loopUserMessage = userMessage;
          loopToolResults.addAll(toolResultMessages);
          continue; // re-loop with tool results
        }

        break; // no tool call → normal response
      }

      if (_isDisposed) return;
      if (_cancelled) return;

      if (hasStreamed && fullContent.isNotEmpty) {
        _state =
            _state!.copyWith(lastReasoning: accumulatedReasoning.toString());
        notifyListeners();
        await _processAiResponse(conversationId, fullContent.toString(),
            provider, baseRequest, accumulatedReasoning.toString());
      } else if (!hasStreamed && fullContent.isEmpty) {
        await _fallbackNonStreaming(
            conversationId, provider, baseRequest, emptyFallbackText);
      }
    } catch (e) {
      if (_isDisposed) return;
      if (_cancelled) return;
      _streamSubscription = null;
      if (!streamingCompleted) {
        await _fallbackNonStreaming(
            conversationId, provider, baseRequest, fullContent.toString());
      }
    }
  }

  Future<void> sendMessage(String text) async {
    final current = _state;
    if (current == null || current.isLoading) return;

    // Cancel any stale stream from a previous page session.
    _cancelStreamSubscription();

    _state = current.copyWith(
        isLoading: true,
        clearError: true,
        clearRawResponse: true,
        clearStreamingText: true,
        clearStreamingReasoning: true);
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
      final oldChoices =
          await _db.getChoicesByConversation(current.conversationId);
      for (final c in oldChoices.where((c) => c.selectedAt == null)) {
        await _db.markChoiceSelected(c.id);
      }

      // Build history
      final allMessages =
          await _db.getMessagesByConversation(current.conversationId);
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
        _state = _state!
            .copyWith(isLoading: false, errorMessage: '请先在设置中配置API Key喵~');
        notifyListeners();
        return;
      }

      if (_character == null)
        _character = await _db.getCharacterById(current.characterId);

      final provider = _providerFactory(apiKey: apiKey, settings: _aiSettings)
        ..setThinkingEnabled(_thinkingEnabled);
      // Enable file tools if runner is available and tools are enabled
      if (_toolRunner != null && _toolsEnabled)
        provider.enableTools(_toolRunner!);

      final systemPrompt = _buildSystemPrompt();

      // Refresh message list after user message
      final refreshedMessages =
          await _db.getMessagesByConversation(current.conversationId);
      _state = _state!.copyWith(messages: refreshedMessages);
      notifyListeners();

      // Build history for the AI call. Exclude the user message we just saved —
      // it's passed separately as userMessage.
      final allHistory = <Map<String, String>>[];
      for (final m in contextMessages) {
        allHistory.add({'role': m.role, 'content': m.content});
      }
      if (allHistory.isNotEmpty && allHistory.last['role'] == 'user') {
        allHistory.removeLast();
      }

      await _streamTurnWithTools(
        conversationId: current.conversationId,
        systemPrompt: systemPrompt,
        allHistory: allHistory,
        userMessage: text,
        provider: provider,
      );
    } on AiAuthException catch (e) {
      _state = _state!.copyWith(
        isLoading: false,
        errorMessage: e.message,
        clearStreamingText: true,
        clearStreamingReasoning: true,
      );
      notifyListeners();
    } catch (e) {
      _state = _state!.copyWith(
        isLoading: false,
        errorMessage: '发送失败喵... $e',
        clearStreamingText: true,
        clearStreamingReasoning: true,
      );
      notifyListeners();
    }
  }

  /// Save AI response, or fall back to non-streaming if empty.
  Future<void> _processAiResponse(
    int conversationId,
    String generatedText,
    AiProvider provider,
    AiTurnRequest request,
    String reasoningText,
  ) async {
    if (_cancelled)
      return; // User cancelled — cancelGeneration() handles saving
    if (generatedText.isEmpty) {
      await _fallbackNonStreaming(conversationId, provider, request, '');
      return;
    }

    await _db.insertMessage(MessagesCompanion(
      conversationId: Value(conversationId),
      role: const Value('assistant'),
      speaker: const Value('初雪'),
      content: Value(generatedText),
      reasoningContent: reasoningText.isNotEmpty
          ? Value(reasoningText)
          : const Value.absent(),
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
    if (_cancelled) return;
    try {
      final result = await provider.sendTurn(request).timeout(_fallbackTimeout);
      final responseText = result.messages.isNotEmpty
          ? result.messages.map((m) => m.text).join('\n')
          : result.rawText ?? streamedSoFar;

      final effectiveText =
          responseText.isNotEmpty ? responseText : emptyAiResponseFallbackText;

      await _db.insertMessage(MessagesCompanion(
        conversationId: Value(conversationId),
        role: const Value('assistant'),
        speaker: const Value('初雪'),
        content: Value(effectiveText),
        createdAt: Value(DateTime.now()),
      ));

      await _db.touchConversation(conversationId);

      final updatedMessages =
          await _db.getMessagesByConversation(conversationId);

      _state = _state!.copyWith(
        messages: updatedMessages,
        isLoading: false,
        clearStreamingText: true,
        clearStreamingReasoning: true,
      );
      notifyListeners();
    } catch (e) {
      if (e is AiAuthException) {
        _state = _state!.copyWith(
          isLoading: false,
          errorMessage: e.message,
          clearStreamingText: true,
          clearStreamingReasoning: true,
        );
      } else {
        _state = _state!.copyWith(
          isLoading: false,
          errorMessage: '发送失败喵... $e',
          clearStreamingText: true,
          clearStreamingReasoning: true,
        );
      }
      notifyListeners();
    }
  }

  Future<void> retry() async => await regenerate();

  /// Delete the last AI message and regenerate a new response for the last
  /// user message WITHOUT inserting a duplicate user message into the DB.
  Future<void> regenerate() async {
    final current = _state;
    if (current == null || current.isLoading) return;

    // Cancel any stale stream from a previous page session.
    _cancelStreamSubscription();

    final msgs = await _db.getMessagesByConversation(current.conversationId);
    final nonSys = msgs.where((m) => m.role != 'system').toList();
    if (nonSys.isEmpty) return;

    // Delete the last AI message so we can replace it.
    final lastAi = nonSys.lastWhere((m) => m.role == 'assistant',
        orElse: () => nonSys.first);
    if (lastAi.role == 'assistant') {
      await _db.deleteMessage(lastAi.id);
    }

    // Opening messages have no user prompt in history. Regenerate them by
    // re-running the opening flow after deleting the old assistant message.
    final userMessages = nonSys.where((m) => m.role == 'user').toList();
    if (userMessages.isEmpty) {
      final refreshedMessages =
          await _db.getMessagesByConversation(current.conversationId);
      _state = current.copyWith(
        clearError: true,
        clearRawResponse: true,
        clearStreamingText: true,
        clearStreamingReasoning: true,
        clearLastReasoning: true,
        messages: refreshedMessages,
      );
      notifyListeners();
      await _sendOpeningMessage();
      return;
    }

    // Find the last user message (what we're regenerating from).
    final lastUser = userMessages.last;

    // Reload messages from DB (now without the deleted AI message).
    final refreshedMessages =
        await _db.getMessagesByConversation(current.conversationId);
    final refreshedNonSys =
        refreshedMessages.where((m) => m.role != 'system').toList();

    _state = current.copyWith(
      isLoading: true,
      clearError: true,
      clearRawResponse: true,
      clearStreamingText: true,
      clearStreamingReasoning: true,
      messages: refreshedMessages,
    );
    notifyListeners();

    try {
      // Build history — exclude the last user message since it's passed
      // separately as userMessage (same convention as sendMessage).
      final allHistory = <Map<String, String>>[];
      for (final m in refreshedNonSys) {
        allHistory.add({'role': m.role, 'content': m.content});
      }
      if (allHistory.isNotEmpty && allHistory.last['role'] == 'user') {
        allHistory.removeLast();
      }

      final apiKey = await _apiKeyService.getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        _state = _state!
            .copyWith(isLoading: false, errorMessage: '请先在设置中配置API Key喵~');
        notifyListeners();
        return;
      }

      if (_character == null)
        _character = await _db.getCharacterById(current.characterId);

      final provider = _providerFactory(apiKey: apiKey, settings: _aiSettings)
        ..setThinkingEnabled(_thinkingEnabled);
      if (_toolRunner != null && _toolsEnabled)
        provider.enableTools(_toolRunner!);

      final systemPrompt = _buildSystemPrompt();

      await _streamTurnWithTools(
        conversationId: current.conversationId,
        systemPrompt: systemPrompt,
        allHistory: allHistory,
        userMessage: lastUser.content,
        provider: provider,
      );
    } on AiAuthException catch (e) {
      _state = _state!.copyWith(
          isLoading: false, errorMessage: e.message, clearStreamingText: true);
      notifyListeners();
    } catch (e) {
      _state = _state!.copyWith(
          isLoading: false,
          errorMessage: '重新生成失败喵... $e',
          clearStreamingText: true);
      notifyListeners();
    }
  }

  /// Edit a user message and resend from that point, deleting all later messages.
  Future<void> editAndResend(int messageId, String newText) async {
    final current = _state;
    if (current == null || current.isLoading) return;

    final msgs = await _db.getMessagesByConversation(current.conversationId);
    final sorted = msgs.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
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
        _state = _state!
            .copyWith(isCompressing: false, errorMessage: '请先配置API Key喵~');
        notifyListeners();
        return;
      }

      final allMessages =
          await _db.getMessagesByConversation(current.conversationId);
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

      if (_character == null)
        _character = await _db.getCharacterById(current.characterId);

      final provider = _providerFactory(apiKey: apiKey, settings: _aiSettings)
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
          createdAt: Value(
              toKeep.first.createdAt.subtract(const Duration(seconds: 1))),
        ));
      });

      // Reload
      await loadConversation(current.conversationId);
      _state = _state!.copyWith(isCompressing: false);
      notifyListeners();
    } catch (e) {
      _state =
          _state!.copyWith(isCompressing: false, errorMessage: '压缩失败喵: $e');
      notifyListeners();
    }
  }

  String _buildSystemPrompt({bool includeTools = true}) {
    final charPrompt = _character?.systemPrompt ?? '';
    final dialogue = (_includeExampleDialogue &&
            _exampleDialogue != null &&
            _exampleDialogue!.isNotEmpty)
        ? '\n## 示例对话（请严格遵循此格式）\n\n$_exampleDialogue\n'
        : '';
    final tools = (_toolsEnabled && includeTools) ? toolInstructions : '';
    return '''$charPrompt
$tools
$dialogue
$_replyStylePrompt''';
  }

  @override
  void dispose() {
    _isDisposed = true;
    final current = _state;
    if (current != null && current.isLoading) {
      unawaited(_savePartialGeneration(current, interruptedByDispose: true));
    }
    _cancelStreamSubscription();
    super.dispose();
  }
}
