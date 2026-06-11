import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_provider.dart';

/// OpenAI function (tool) definition for the API request.
const _narrativeFileTools = [
  {
    'type': 'function',
    'function': {
      'name': 'read_file',
      'description': '读取故事叙述文件的当前内容。可用文件名: galgame-settings.md(世界观设定), galgame-npcs.md(NPC阵容), galgame-plot-outline.md(剧情大纲), galgame-progress.md(进度追踪)。可一次读取单个或多个文件',
      'parameters': {
        'type': 'object',
        'properties': {
          'filename': {
            'type': 'string',
            'description': '单个文件名，如 galgame-settings.md',
            'enum': ['galgame-settings.md', 'galgame-npcs.md', 'galgame-plot-outline.md', 'galgame-progress.md'],
          },
          'filenames': {
            'type': 'array',
            'description': '文件名列表，一次读取多个文件。如 ["galgame-settings.md", "galgame-progress.md"]',
            'items': {
              'type': 'string',
              'enum': ['galgame-settings.md', 'galgame-npcs.md', 'galgame-plot-outline.md', 'galgame-progress.md'],
            },
          },
        },
      },
    },
  },
  {
    'type': 'function',
    'function': {
      'name': 'write_file',
      'description': '写入或更新故事叙述文件的内容。用于根据剧情推进更新NPC信息、进度追踪、事件完成状态等',
      'parameters': {
        'type': 'object',
        'properties': {
          'filename': {
            'type': 'string',
            'description': '文件名',
            'enum': ['galgame-settings.md', 'galgame-npcs.md', 'galgame-plot-outline.md', 'galgame-progress.md'],
          },
          'content': {
            'type': 'string',
            'description': 'Markdown格式的新内容',
          },
        },
        'required': ['filename', 'content'],
      },
    },
  },
];

/// OpenAI-compatible chat completion API provider with tool calling support.
class OpenAiCompatibleProvider implements AiProvider {
  final String apiKey;
  final AiSettings _settings;
  final http.Client _httpClient;
  bool _includeTools = false;
  ToolRunner? _toolRunner;
  bool _thinkingEnabled = true;

  OpenAiCompatibleProvider({
    required this.apiKey,
    required AiSettings settings,
    http.Client? httpClient,
  })  : _settings = settings,
        _httpClient = httpClient ?? http.Client();

  /// Enable / disable thinking mode.
  @override
  void setThinkingEnabled(bool v) => _thinkingEnabled = v;

  /// Enable tool calling for subsequent requests.
  @override
  void enableTools(ToolRunner runner) {
    _includeTools = true;
    _toolRunner = runner;
  }

  /// Disable tool calling.
  @override
  void disableTools() {
    _includeTools = false;
    _toolRunner = null;
  }

  @override
  Future<AiTurnResult> sendTurn(AiTurnRequest request) async {
    final url = Uri.parse('${_settings.baseUrl}/chat/completions');
    final messages = _buildMessages(request, toolResults: request.toolResults);
    final body = _buildBody(messages, stream: false);

    try {
      final response = await _httpClient.post(url, headers: _headers(), body: jsonEncode(body));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return _parseResponse(data);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw AiAuthException('API Key验证失败 (HTTP ${response.statusCode})');
      } else {
        throw AiNetworkException('请求失败 (HTTP ${response.statusCode}): ${response.body}');
      }
    } on AiAuthException { rethrow; }
    on AiNetworkException { rethrow; }
    catch (e) { throw AiNetworkException('网络错误: $e'); }
  }

  /// Stream AI response chunks via SSE.
  @override
  Stream<AiStreamChunk> sendTurnStream(AiTurnRequest request) async* {
    final url = Uri.parse('${_settings.baseUrl}/chat/completions');
    final messages = _buildMessages(request, toolResults: request.toolResults);
    final body = _buildBody(messages, stream: true);

    final streamedResponse = await _httpClient.send(
      http.Request('POST', url)..headers.addAll(_headers())..body = jsonEncode(body),
    );

    if (streamedResponse.statusCode == 401 || streamedResponse.statusCode == 403) {
      throw AiAuthException('API Key验证失败 (HTTP ${streamedResponse.statusCode})');
    }
    if (streamedResponse.statusCode != 200) {
      final errorBody = await streamedResponse.stream.bytesToString();
      throw AiNetworkException('请求失败 (HTTP ${streamedResponse.statusCode}): $errorBody');
    }

    final lines = streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    final buffer = StringBuffer();
    final toolCallAccs = <int, Map<String, dynamic>>{};
    final toolCallIds = <int, String>{};
    final toolCallNames = <int, String>{};
    final toolArgsBufs = <int, StringBuffer>{};

    await for (final line in lines) {
      if (line.startsWith('data: ')) {
        final data = line.substring(6);
        if (data == '[DONE]') {
          // Flush all pending tool calls
          if (toolCallAccs.isNotEmpty) {
            final allToolCalls = <ToolCallRequest>[];
            final indices = toolCallAccs.keys.toList()..sort();
            for (final index in indices) {
              final acc = toolCallAccs[index]!;
              allToolCalls.add(ToolCallRequest(
                id: acc['id'] as String,
                name: (acc['function'] as Map)['name'] as String,
                arguments: _parseArgs((acc['function'] as Map)['arguments'] as String? ?? '{}'),
              ));
            }
            yield AiStreamChunk(toolCalls: allToolCalls);
          }
          yield const AiStreamChunk(isDone: true);
          break;
        }
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final choices = json['choices'] as List<dynamic>?;
          if (choices == null || choices.isEmpty) continue;

          final delta = choices.first['delta'] as Map<String, dynamic>?;
          if (delta == null) continue;

          // Check for tool calls in delta (supports multiple concurrent tool calls)
          final toolCalls = delta['tool_calls'] as List<dynamic>?;
          if (toolCalls != null && toolCalls.isNotEmpty) {
            for (final tc in toolCalls) {
              final tcMap = tc as Map<String, dynamic>;
              final index = tcMap['index'] as int? ?? 0;
              final fn = tcMap['function'] as Map<String, dynamic>?;

              if (tcMap['id'] != null) {
                // New tool call starting at this index — initialize accumulator
                toolCallAccs[index] = tcMap;
                toolCallIds[index] = tcMap['id'] as String;
                toolCallNames[index] = fn?['name'] as String? ?? '';
                toolArgsBufs[index] = StringBuffer();
              }
              if (fn?['arguments'] != null) {
                final buf = toolArgsBufs.putIfAbsent(index, () => StringBuffer());
                buf.write(fn!['arguments'] as String);
                final acc = toolCallAccs[index];
                if (acc != null) {
                  (acc['function'] as Map)['arguments'] = buf.toString();
                }
              }
            }
            continue; // Don't yield tool call chunks as text
          }

          // Yield reasoning_content and normal content
          final reasoning = delta['reasoning_content'] as String? ?? '';
          final content = delta['content'] as String? ?? '';
          if (reasoning.isNotEmpty) {
            yield AiStreamChunk(reasoningDelta: reasoning);
          }
          if (content.isNotEmpty) {
            buffer.write(content);
            yield AiStreamChunk(textDelta: content);
          }
        } catch (_) { /* skip unparseable */ }
      }
    }

    _lastStreamedContent = buffer.toString();
  }

  String? _lastStreamedContent;

  /// Extract all tool calls from a non-streaming response.
  List<ToolCallRequest> _extractToolCalls(Map<String, dynamic> data) {
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) return [];
    final msg = choices.first['message'] as Map<String, dynamic>?;
    if (msg == null) return [];
    final toolCalls = msg['tool_calls'] as List<dynamic>?;
    if (toolCalls == null || toolCalls.isEmpty) return [];
    return toolCalls.map((tc) {
      final t = tc as Map<String, dynamic>;
      final fn = t['function'] as Map<String, dynamic>;
      return ToolCallRequest(
        id: t['id'] as String,
        name: fn['name'] as String,
        arguments: _parseArgs(fn['arguments'] as String? ?? '{}'),
      );
    }).toList();
  }

  Map<String, dynamic> _parseArgs(String s) {
    try { return jsonDecode(s) as Map<String, dynamic>; } catch (_) { return {}; }
  }

  /// Parse a non-streaming response.
  AiTurnResult _parseResponse(Map<String, dynamic> data) {
    final toolCalls = _extractToolCalls(data);
    if (toolCalls.isNotEmpty) {
      return AiTurnResult.toolCalls(toolCalls);
    }
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      return AiTurnResult.fromRawText('[错误] AI返回了空的回复喵...');
    }
    final content = choices.first['message']?['content'] as String? ?? '';
    if (content.isEmpty) {
      return AiTurnResult.fromRawText('[错误] AI回复内容为空喵...');
    }
    return AiTurnResult.parse(content);
  }

  @override
  Future<List<AiModel>> fetchModels({required String baseUrl, required String apiKey}) async {
    final url = Uri.parse('$baseUrl/models');
    try {
      final response = await _httpClient.get(url, headers: {'Authorization': 'Bearer $apiKey'});
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return (data['data'] as List<dynamic>? ?? [])
            .map((m) => AiModel.fromJson(m as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  @override
  Future<ConnectionTestResult> testConnection(AiSettings settings) async {
    final url = Uri.parse('${settings.baseUrl}/chat/completions');
    try {
      final response = await http.post(url,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'},
        body: jsonEncode({'model': settings.model, 'messages': [{'role': 'user', 'content': 'hi'}], 'max_tokens': 10}),
      );
      if (response.statusCode == 200) return const ConnectionTestResult(success: true, message: '连接成功喵~ ✨');
      return ConnectionTestResult(success: false, message: '服务器返回 HTTP ${response.statusCode}');
    } catch (e) {
      return ConnectionTestResult(success: false, message: '无法连接到服务器: $e');
    }
  }

  @override
  @override
  Future<String> compressHistory({
    required String systemPrompt,
    required List<Map<String, String>> oldMessages,
  }) async {
    final url = Uri.parse('${_settings.baseUrl}/chat/completions');
    final response = await _httpClient.post(url, headers: _headers(), body: jsonEncode({
      'model': _settings.model,
      'messages': [
        {'role': 'system', 'content': '你是一个上下文压缩引擎。请将以下对话历史压缩为200-500字的简洁摘要，保留关键叙事事实、好感度变化、NPC出场和Flag设定。使用客观第三人称。'},
        {'role': 'user', 'content': oldMessages.map((m) => '${m['role']}: ${m['content']}').join('\n\n')},
      ],
      'temperature': 0.3,
      'max_tokens': 1024,
    }));
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return (data['choices'] as List?)?.first['message']?['content'] as String? ?? '';
    }
    throw Exception('压缩请求失败 HTTP ${response.statusCode}');
  }

  // ─── builders ───

  List<Map<String, dynamic>> _buildMessages(AiTurnRequest request, {List<Map<String, dynamic>>? toolResults}) {
    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': request.systemPrompt},
    ];
    for (final entry in request.history) {
      // Strip reasoning_content — per DeepSeek API, non-tool-call reasoning
      // should not be passed to subsequent turns
      final cleaned = Map<String, dynamic>.from(entry);
      cleaned.remove('reasoning_content');
      messages.add(cleaned);
    }
    messages.add({'role': 'user', 'content': request.userMessage});
    // Append tool results if any
    if (toolResults != null) {
      for (final tr in toolResults) {
        messages.add(tr);
      }
    }
    return messages;
  }

  Map<String, dynamic> _buildBody(List<Map<String, dynamic>> messages, {required bool stream}) {
    final body = <String, dynamic>{
      'model': _settings.model,
      'messages': messages,
      'temperature': _settings.temperature,
      'max_tokens': _settings.maxTokens,
      'stream': stream,
    };
    if (_includeTools && _toolRunner != null) {
      body['tools'] = _narrativeFileTools;
      body['tool_choice'] = 'auto';
    }
    if (_thinkingEnabled && _settings.model.contains('deepseek')) {
      body['thinking'] = {'type': 'enabled'};
    }
    return body;
  }

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };
}

