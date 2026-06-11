import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_provider.dart';

/// Anthropic Messages API provider — native protocol.
///
/// Differences from OpenAI-compatible:
/// - POST /v1/messages (not /chat/completions)
/// - `x-api-key` header + `anthropic-version: 2023-06-01` (not `Authorization: Bearer`)
/// - `system` is a **top-level field**, not a message role
/// - Messages use content-block arrays: `[{"type":"text","text":"..."}]`
/// - `max_tokens` is **required** in every request
/// - Tool definitions use `input_schema` (not `parameters`)
/// - Tool results go in a user-message content block (not a `role:"tool"` message)
/// - Streaming uses different SSE event types (text_delta, input_json_delta,
///   thinking_delta, etc.)
class AnthropicProvider implements AiProvider {
  final String apiKey;
  final AiSettings _settings;
  final http.Client _httpClient;
  bool _includeTools = false;
  ToolRunner? _toolRunner;
  bool _thinkingEnabled = true;

  static const _apiVersion = '2023-06-01';

  AnthropicProvider({
    required this.apiKey,
    required AiSettings settings,
    http.Client? httpClient,
  })  : _settings = settings,
        _httpClient = httpClient ?? http.Client();

  @override
  void setThinkingEnabled(bool v) => _thinkingEnabled = v;

  @override
  void enableTools(ToolRunner runner) {
    _includeTools = true;
    _toolRunner = runner;
  }

  @override
  void disableTools() {
    _includeTools = false;
    _toolRunner = null;
  }

  // ── Helpers ──

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': _apiVersion,
      };

  Uri get _base => Uri.parse(_settings.baseUrl);

  // ── Tool schema (Anthropic format) ──

  static const _anthropicTools = [
    {
      'name': 'read_file',
      'description': '读取故事叙述文件的当前内容。可用文件名: galgame-settings.md(世界观设定), galgame-npcs.md(NPC阵容), galgame-plot-outline.md(剧情大纲), galgame-progress.md(进度追踪)。可一次读取单个或多个文件',
      'input_schema': {
        'type': 'object',
        'properties': {
          'filename': {
            'type': 'string',
            'description': '单个文件名，如 galgame-settings.md',
            'enum': [
              'galgame-settings.md',
              'galgame-npcs.md',
              'galgame-plot-outline.md',
              'galgame-progress.md'
            ],
          },
          'filenames': {
            'type': 'array',
            'description': '文件名列表，一次读取多个文件',
            'items': {
              'type': 'string',
              'enum': [
                'galgame-settings.md',
                'galgame-npcs.md',
                'galgame-plot-outline.md',
                'galgame-progress.md'
              ],
            },
          },
        },
      },
    },
    {
      'name': 'write_file',
      'description': '写入或更新故事叙述文件的内容',
      'input_schema': {
        'type': 'object',
        'properties': {
          'filename': {
            'type': 'string',
            'description': '文件名',
            'enum': [
              'galgame-settings.md',
              'galgame-npcs.md',
              'galgame-plot-outline.md',
              'galgame-progress.md'
            ],
          },
          'content': {
            'type': 'string',
            'description': 'Markdown格式的新内容',
          },
        },
        'required': ['filename', 'content'],
      },
    },
  ];

  // ── Message building (Anthropic format) ──

  /// Convert app-level history entries into Anthropic content-block messages.
  List<Map<String, dynamic>> _buildMessages(
    AiTurnRequest request, {
    List<Map<String, dynamic>>? toolResults,
  }) {
    final messages = <Map<String, dynamic>>[];

    for (final entry in request.history) {
      final role = entry['role'] as String;
      final content = entry['content'] ?? '';
      if (role == 'system') continue; // system is top-level, not a message
      messages.add({
        'role': role,
        'content': [
          {'type': 'text', 'text': content}
        ],
      });
    }

    // User turn
    messages.add({
      'role': 'user',
      'content': [
        {'type': 'text', 'text': request.userMessage}
      ],
    });

    // Append tool results if any (Anthropic format: user message with
    // tool_result blocks)
    if (toolResults != null) {
      // The tool-results list from the chat loop is in OpenAI format:
      // [{role: "assistant", content: null, tool_calls: [...]},
      //  {role: "tool", tool_call_id: ..., content: ...}, ...]
      //
      // We need to convert this to Anthropic format:
      // 1. Assistant tool_use blocks
      // 2. User tool_result blocks
      final assistantBlocks = <Map<String, dynamic>>[];
      final resultBlocks = <Map<String, dynamic>>[];

      for (final tr in toolResults) {
        final role = tr['role'] as String?;
        if (role == 'assistant') {
          // tool_calls → tool_use content blocks
          final tcs = tr['tool_calls'] as List<dynamic>? ?? [];
          for (final tc in tcs) {
            final tcMap = tc as Map<String, dynamic>;
            final fn = tcMap['function'] as Map<String, dynamic>;
            assistantBlocks.add({
              'type': 'tool_use',
              'id': tcMap['id'],
              'name': fn['name'],
              'input': jsonDecode(fn['arguments'] as String? ?? '{}'),
            });
          }
        } else if (role == 'tool') {
          resultBlocks.add({
            'type': 'tool_result',
            'tool_use_id': tr['tool_call_id'],
            'content': tr['content'] ?? '',
          });
        }
      }

      if (assistantBlocks.isNotEmpty) {
        messages.add({'role': 'assistant', 'content': assistantBlocks});
      }
      if (resultBlocks.isNotEmpty) {
        messages.add({'role': 'user', 'content': resultBlocks});
      }
    }

    return messages;
  }

  Map<String, dynamic> _buildBody(
    List<Map<String, dynamic>> messages, {
    required bool stream,
    String? systemPrompt,
  }) {
    final body = <String, dynamic>{
      'model': _settings.model,
      'messages': messages,
      'max_tokens': _settings.maxTokens > 0 ? _settings.maxTokens : 4096,
      'stream': stream,
    };

    // system is a top-level field in Anthropic API, not a message
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      body['system'] = systemPrompt;
    }

    if (_includeTools && _toolRunner != null) {
      body['tools'] = _anthropicTools;
      body['tool_choice'] = {'type': 'auto'};
    }

    // Extended thinking for Claude 4.6+ models
    if (_thinkingEnabled) {
      body['thinking'] = {'type': 'adaptive'};
    }

    return body;
  }

  // ── Non-streaming ──

  @override
  Future<AiTurnResult> sendTurn(AiTurnRequest request) async {
    final url = _base.resolve('/v1/messages');
    final messages = _buildMessages(request, toolResults: request.toolResults);
    final body = _buildBody(messages, stream: false,
        systemPrompt: request.systemPrompt);

    try {
      final response =
          await _httpClient.post(url, headers: _headers(), body: jsonEncode(body));
      if (response.statusCode == 200) {
        final data =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return _parseMessage(data);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw AiAuthException(
            'API Key验证失败 (HTTP ${response.statusCode})');
      } else {
        throw AiNetworkException(
            '请求失败 (HTTP ${response.statusCode}): ${response.body}');
      }
    } on AiAuthException {
      rethrow;
    } on AiNetworkException {
      rethrow;
    } catch (e) {
      throw AiNetworkException('网络错误: $e');
    }
  }

  /// Extract tool_use blocks from a non-streaming Anthropic response.
  List<ToolCallRequest> _extractToolCalls(List<dynamic> content) {
    final toolCalls = <ToolCallRequest>[];
    for (final block in content) {
      if (block is Map<String, dynamic> && block['type'] == 'tool_use') {
        toolCalls.add(ToolCallRequest(
          id: block['id'] as String,
          name: block['name'] as String,
          arguments: Map<String, dynamic>.from(block['input'] as Map? ?? {}),
        ));
      }
    }
    return toolCalls;
  }

  AiTurnResult _parseMessage(Map<String, dynamic> data) {
    final content = data['content'] as List<dynamic>? ?? [];

    // Check for tool use first
    final toolCalls = _extractToolCalls(content);
    if (toolCalls.isNotEmpty) {
      return AiTurnResult.toolCalls(toolCalls);
    }

    // Collect text blocks
    final buf = StringBuffer();
    for (final block in content) {
      if (block is Map<String, dynamic> && block['type'] == 'text') {
        buf.write(block['text'] ?? '');
      }
    }
    final text = buf.toString();
    if (text.isEmpty) {
      return AiTurnResult.fromRawText('[错误] AI回复内容为空喵...');
    }
    return AiTurnResult.parse(text);
  }

  // ── Streaming (SSE) ──

  @override
  Stream<AiStreamChunk> sendTurnStream(AiTurnRequest request) async* {
    final url = _base.resolve('/v1/messages');
    final messages = _buildMessages(request, toolResults: request.toolResults);
    final body = _buildBody(messages, stream: true,
        systemPrompt: request.systemPrompt);

    final streamedResponse = await _httpClient.send(
      http.Request('POST', url)
        ..headers.addAll(_headers())
        ..body = jsonEncode(body),
    );

    if (streamedResponse.statusCode == 401 ||
        streamedResponse.statusCode == 403) {
      throw AiAuthException(
          'API Key验证失败 (HTTP ${streamedResponse.statusCode})');
    }
    if (streamedResponse.statusCode != 200) {
      final errorBody = await streamedResponse.stream.bytesToString();
      throw AiNetworkException(
          '请求失败 (HTTP ${streamedResponse.statusCode}): $errorBody');
    }

    final lines = streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    final buffer = StringBuffer();
    final toolAccumulators = <int, Map<String, dynamic>>{};

    await for (final line in lines) {
      // Anthropic SSE format: `event: <type>\ndata: <json>`
      if (!line.startsWith('data: ')) continue;

      final dataStr = line.substring(6);
      try {
        final event = jsonDecode(dataStr) as Map<String, dynamic>;
        final type = event['type'] as String?;

        switch (type) {
          case 'content_block_start':
            final block = event['content_block'] as Map<String, dynamic>?;
            final idx = event['index'] as int? ?? 0;
            if (block != null && block['type'] == 'tool_use') {
              toolAccumulators[idx] = {
                'id': block['id'],
                'name': block['name'],
                'input': StringBuffer(),
              };
            }
            break;

          case 'content_block_delta':
            final delta = event['delta'] as Map<String, dynamic>?;
            final idx = event['index'] as int? ?? 0;
            if (delta == null) continue;

            final deltaType = delta['type'] as String?;

            if (deltaType == 'text_delta') {
              final text = delta['text'] as String? ?? '';
              if (text.isNotEmpty) {
                buffer.write(text);
                yield AiStreamChunk(textDelta: text);
              }
            } else if (deltaType == 'thinking_delta') {
              final thinking = delta['thinking'] as String? ?? '';
              if (thinking.isNotEmpty) {
                yield AiStreamChunk(reasoningDelta: thinking);
              }
            } else if (deltaType == 'input_json_delta') {
              final partial = delta['partial_json'] as String? ?? '';
              final acc = toolAccumulators[idx];
              if (acc != null) {
                (acc['input'] as StringBuffer).write(partial);
              }
            }
            break;

          case 'content_block_stop':
            // Tool call block completed — input_json accumulation finished
            break;

          case 'message_delta':
            // Contains stop_reason and usage — no content to yield
            final stopReason =
                event['delta']?['stop_reason'] as String? ?? '';
            if (stopReason == 'tool_use') {
              // Flush accumulated tool calls
              if (toolAccumulators.isNotEmpty) {
                final allToolCalls = <ToolCallRequest>[];
                final indices = toolAccumulators.keys.toList()..sort();
                for (final i in indices) {
                  final acc = toolAccumulators[i]!;
                  final inputStr =
                      (acc['input'] as StringBuffer).toString();
                  allToolCalls.add(ToolCallRequest(
                    id: acc['id'] as String,
                    name: acc['name'] as String,
                    arguments: _parseArgs(inputStr),
                  ));
                }
                yield AiStreamChunk(toolCalls: allToolCalls);
              }
            }
            break;

          case 'message_stop':
            yield const AiStreamChunk(isDone: true);
            return;
        }
      } catch (_) {
        /* skip unparseable SSE lines */
      }
    }

    // If we got here without message_stop, still signal done
    yield const AiStreamChunk(isDone: true);
  }

  Map<String, dynamic> _parseArgs(String s) {
    try {
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  // ── Connection test ──

  @override
  Future<ConnectionTestResult> testConnection(AiSettings settings) async {
    final url = Uri.parse('${settings.baseUrl}/v1/messages');
    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': apiKey,
            'anthropic-version': _apiVersion,
          },
          body: jsonEncode({
            'model': settings.model,
            'max_tokens': 10,
            'messages': [
              {'role': 'user', 'content': [{'type': 'text', 'text': 'hi'}]}
            ],
          }));
      if (response.statusCode == 200) {
        return const ConnectionTestResult(success: true, message: '连接成功喵~ ✨');
      }
      return ConnectionTestResult(
          success: false, message: '服务器返回 HTTP ${response.statusCode}');
    } catch (e) {
      return ConnectionTestResult(
          success: false, message: '无法连接到服务器: $e');
    }
  }

  // ── Models ──

  @override
  Future<List<AiModel>> fetchModels({
    required String baseUrl,
    required String apiKey,
  }) async {
    // Anthropic doesn't have a public /v1/models endpoint that lists all
    // models in the same way OpenAI does. Return a curated static list.
    return const [
      AiModel(id: 'claude-opus-4-8', ownedBy: 'anthropic'),
      AiModel(id: 'claude-sonnet-4-6', ownedBy: 'anthropic'),
      AiModel(id: 'claude-haiku-4-5-20251001', ownedBy: 'anthropic'),
    ];
  }

  // ── Compression ──

  @override
  Future<String> compressHistory({
    required String systemPrompt,
    required List<Map<String, String>> oldMessages,
  }) async {
    final url = _base.resolve('/v1/messages');
    final text = oldMessages
        .map((m) => '${m['role']}: ${m['content']}')
        .join('\n\n');
    final body = {
      'model': _settings.model,
      'max_tokens': 1024,
      'system': '你是一个上下文压缩引擎。请将以下对话历史压缩为200-500字的简洁摘要，保留关键叙事事实、好感度变化、NPC出场和Flag设定。使用客观第三人称。',
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': text}
          ],
        },
      ],
    };

    final response =
        await _httpClient.post(url, headers: _headers(), body: jsonEncode(body));
    if (response.statusCode == 200) {
      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final content = data['content'] as List<dynamic>? ?? [];
      final buf = StringBuffer();
      for (final block in content) {
        if (block is Map<String, dynamic> && block['type'] == 'text') {
          buf.write(block['text'] ?? '');
        }
      }
      return buf.toString();
    }
    throw Exception('压缩请求失败 HTTP ${response.statusCode}');
  }
}
