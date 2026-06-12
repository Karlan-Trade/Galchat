import '../models/api_provider_preset.dart';

/// The result of a single AI turn.
class AiTurnResult {
  /// Character messages to render as chat bubbles.
  final List<AiMessage> messages;

  /// Galgame choices (2-4), if the AI returned any.
  final List<AiChoice> choices;

  /// State delta to merge into current game state.
  final StateDelta? stateDelta;

  /// Whether the AI response was valid JSON.
  final bool isValidJson;

  /// Raw AI output text (used as fallback for invalid JSON).
  final String? rawText;

  /// If non-empty, the AI requested tool calls instead of text.
  final List<ToolCallRequest> toolCalls;

  const AiTurnResult({
    required this.messages,
    this.choices = const [],
    this.stateDelta,
    this.isValidJson = true,
    this.rawText,
    this.toolCalls = const [],
  });

  factory AiTurnResult.toolCalls(List<ToolCallRequest> tcs) => AiTurnResult(
        messages: const [],
        toolCalls: tcs,
        isValidJson: true,
      );

  factory AiTurnResult.fromRawText(String text) {
    return AiTurnResult(
      messages: [AiMessage(speaker: '初雪', text: text)],
      isValidJson: false,
      rawText: text,
    );
  }

  /// Wrap the AI's native output for display.
  ///
  /// The per-turn JSON contract (`{messages, choices, state_delta}`) has been
  /// deprecated — we no longer ask the model to emit structured turns, and we
  /// render its raw output as-is. This method now simply wraps the raw text.
  static AiTurnResult parse(String raw) => AiTurnResult.fromRawText(raw);
}

/// A single message from the AI character.
class AiMessage {
  final String speaker;
  final String text;

  const AiMessage({required this.speaker, required this.text});
}

/// A Galgame-style choice.
class AiChoice {
  final String id; // A, B, C, D
  final String text;

  const AiChoice({required this.id, required this.text});
}

/// Partial game state update from the AI.
class StateDelta {
  final int? affection;
  final String? mood;
  final String? scene;
  final String? timeSlot;
  final Map<String, dynamic>? flags;

  const StateDelta({
    this.affection,
    this.mood,
    this.scene,
    this.timeSlot,
    this.flags,
  });

  factory StateDelta.fromJson(Map<String, dynamic> json) {
    return StateDelta(
      affection: json['affection'] as int?,
      mood: json['mood'] as String?,
      scene: json['scene'] as String?,
      timeSlot: json['time_slot'] as String?,
      flags: json['flags'] as Map<String, dynamic>?,
    );
  }
}

/// Represents a single AI request containing conversation context and user input.
class AiTurnRequest {
  /// Full system prompt including character card and format instructions.
  final String systemPrompt;

  /// Recent conversation history as alternating speaker/text pairs.
  final List<Map<String, String>> history;

  /// The user's current message or selected choice.
  final String userMessage;

  /// Current game state for context.
  final Map<String, dynamic> currentState;

  /// Tool call results to append after the user message (for tool call loops).
  final List<Map<String, dynamic>>? toolResults;

  const AiTurnRequest({
    required this.systemPrompt,
    required this.history,
    required this.userMessage,
    required this.currentState,
    this.toolResults,
  });
}

/// Connection test result.
class ConnectionTestResult {
  final bool success;
  final String message;

  const ConnectionTestResult({required this.success, required this.message});
}

/// Configuration for the AI provider.
class AiSettings {
  final String baseUrl;
  final String model;
  final double temperature;
  final int maxTokens;
  final int contextWindow;
  final String truncateStrategy;
  final int truncateLimit;
  final bool markdownRender;

  /// Which wire protocol to speak. Decides the concrete [AiProvider]
  /// implementation (OpenAI Chat Completions vs Anthropic Messages).
  final ApiProtocol protocol;

  const AiSettings({
    required this.baseUrl,
    required this.model,
    this.temperature = 0.7,
    this.maxTokens = 4096,
    this.contextWindow = 128000,
    this.truncateStrategy = 'compress',
    this.truncateLimit = 20,
    this.markdownRender = false,
    this.protocol = ApiProtocol.openAiCompatible,
  });

  AiSettings copyWith({
    String? baseUrl,
    String? model,
    double? temperature,
    int? maxTokens,
    int? contextWindow,
    String? truncateStrategy,
    int? truncateLimit,
    bool? markdownRender,
    ApiProtocol? protocol,
  }) {
    return AiSettings(
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      contextWindow: contextWindow ?? this.contextWindow,
      truncateStrategy: truncateStrategy ?? this.truncateStrategy,
      truncateLimit: truncateLimit ?? this.truncateLimit,
      markdownRender: markdownRender ?? this.markdownRender,
      protocol: protocol ?? this.protocol,
    );
  }
}

/// Represents a model available at the provider's endpoint.
class AiModel {
  final String id;
  final String? ownedBy;

  const AiModel({required this.id, this.ownedBy});

  factory AiModel.fromJson(Map<String, dynamic> json) {
    return AiModel(
      id: json['id'] as String,
      ownedBy: json['owned_by'] as String?,
    );
  }
}

/// AI asked us to run a tool.
class ToolCallRequest {
  final String id;
  final String name;
  final Map<String, dynamic> arguments;
  const ToolCallRequest({required this.id, required this.name, required this.arguments});
}

/// Implemented by hosts that can execute tool calls.
abstract class ToolRunner {
  Future<String> run(String name, Map<String, dynamic> args);
}

/// Chunk of streaming AI output — may be text or tool call info.
class AiStreamChunk {
  final String textDelta;
  final String reasoningDelta;
  final bool isDone;
  final List<ToolCallRequest> toolCalls;

  const AiStreamChunk({
    this.textDelta = '',
    this.reasoningDelta = '',
    this.isDone = false,
    this.toolCalls = const [],
  });
}

/// Abstract interface for AI providers.
abstract class AiProvider {
  /// Send a chat turn to the AI and return the parsed result.
  Future<AiTurnResult> sendTurn(AiTurnRequest request);

  /// Stream AI response chunks via SSE.
  Stream<AiStreamChunk> sendTurnStream(AiTurnRequest request);

  /// Test whether the configured endpoint is reachable and working.
  Future<ConnectionTestResult> testConnection(AiSettings settings);

  /// Fetch available models from the provider's /models endpoint.
  Future<List<AiModel>> fetchModels({
    required String baseUrl,
    required String apiKey,
  });

  /// Compress old conversation history into a short summary.
  Future<String> compressHistory({
    required String systemPrompt,
    required List<Map<String, String>> oldMessages,
  });

  /// Enable tool calling for subsequent requests.
  void enableTools(ToolRunner runner);

  /// Disable tool calling.
  void disableTools();

  /// Enable / disable thinking mode (DeepSeek reasoning_content, or
  /// Anthropic extended thinking).
  void setThinkingEnabled(bool v);
}

/// Authentication failure from the AI backend.
class AiAuthException implements Exception {
  final String message;
  const AiAuthException(this.message);
  @override
  String toString() => message;
}

/// Network-level failure when reaching the AI backend.
class AiNetworkException implements Exception {
  final String message;
  const AiNetworkException(this.message);
  @override
  String toString() => message;
}

/// Create the right [AiProvider] implementation based on [AiSettings.protocol].
