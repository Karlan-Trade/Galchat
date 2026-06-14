import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../state/chat_state.dart';
import '../state/settings_state.dart';
import '../services/api_key_service.dart';
import '../services/narrative_service.dart';
import '../services/narrative_tool_runner.dart';
import '../services/token_counter.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/choice_chips.dart';
import '../widgets/message_input.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});
  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  ChatNotifier? _chatNotifier;
  final _scrollController = ScrollController();
  int? _conversationId;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final convId = ModalRoute.of(context)?.settings.arguments as int?;
    if (convId != null && convId != _conversationId) {
      _conversationId = convId;
      _chatNotifier?.removeListener(_onChatChanged);
      _chatNotifier?.dispose();
      final db = ref.read(databaseProvider);
      final apiKeyService = ref.read(apiKeyServiceProvider);
      final aiSettings = ref.read(aiSettingsFromStateProvider);
      _chatNotifier = ChatNotifier(db, apiKeyService, aiSettings);
      final narrativeService = ref.read(narrativeServiceProvider);
      final settings = ref.read(settingsProvider);
      _chatNotifier!.addListener(_onChatChanged);
      _chatNotifier!.setIncludeExampleDialogue(settings.includeExampleDialogue);
      _chatNotifier!.setAiFirstMessage(settings.aiFirstMessage);
      _chatNotifier!.setThinkingEnabled(settings.thinkingEnabled);
      _chatNotifier!.setToolsEnabled(settings.toolsEnabled);
      narrativeService.init().then((_) async {
        if (!mounted || _conversationId != convId) return;
        final d = await narrativeService.readFile('example-dialogue.md');
        if (!mounted || _conversationId != convId) return;
        _chatNotifier?.setExampleDialogue(d);
        final o = await narrativeService.readFile('opening-message-prompt.md');
        if (!mounted || _conversationId != convId) return;
        _chatNotifier?.setOpeningPrompt(o);
        final r = await narrativeService.readFile('reply-style-prompt.md');
        if (!mounted || _conversationId != convId) return;
        _chatNotifier?.setReplyStylePrompt(r);
        _chatNotifier?.enableFileTools(
          NarrativeToolRunner(narrativeService, conversationId: convId),
        );
        await _chatNotifier?.loadConversation(convId);
      });
    }
  }

  void _onChatChanged() {
    if (!mounted) return;
    setState(() {});
    _scrollToBottom();
  }

  @override
  void dispose() {
    _chatNotifier?.removeListener(_onChatChanged);
    _chatNotifier?.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final distanceFromBottom =
        _scrollController.position.maxScrollExtent - _scrollController.offset;
    final shouldShow = distanceFromBottom > 180;
    if (shouldShow != _showScrollToBottom && mounted) {
      setState(() => _showScrollToBottom = shouldShow);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _jumpToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleSend(String text) => _chatNotifier?.sendMessage(text);
  void _handleCancel() => _chatNotifier?.cancelGeneration();

  Future<void> _showPromptPreview() async {
    final prompt = await _chatNotifier?.buildFullPrompt() ?? '(加载中...)';
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.preview, size: 18),
                    const SizedBox(width: 8),
                    const Text('提示词预览',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: '复制全部',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: prompt));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('已复制喵~'),
                              duration: Duration(seconds: 1)),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    prompt,
                    style: const TextStyle(
                        fontSize: 12, fontFamily: 'monospace', height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThinkingDialog(String reasoning) {
    if (reasoning.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('本回复没有思考内容喵~ 可能思考模式未开启'),
            duration: Duration(seconds: 2)),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Icon(Icons.psychology,
                      size: 18, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  const Text('思考内容',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: '复制',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: reasoning));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('已复制喵~'),
                          duration: Duration(seconds: 1)));
                    },
                  ),
                  IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.pop(ctx)),
                ]),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(reasoning,
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          height: 1.5,
                          color: Colors.amber.shade900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleChoiceTap(int index) {
    final st = _chatNotifier?.state;
    if (st == null || index >= st.pendingChoices.length) return;
    _chatNotifier?.sendMessage(st.pendingChoices[index].choiceText);
  }

  // ──────────── Retry / Edit actions ────────────

  bool _isLastAssistant(Message msg) {
    final st = _chatNotifier?.state;
    if (st == null) return false;
    final nonSys = st.messages.where((m) => m.role != 'system').toList();
    if (nonSys.isEmpty || msg.role != 'assistant') return false;
    return nonSys.last.role == 'assistant' && nonSys.last.id == msg.id;
  }

  void _showEditDialog(Message msg) {
    final ctrl = TextEditingController(text: msg.content);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑消息'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          minLines: 2,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final t = ctrl.text.trim();
              if (t.isNotEmpty) _chatNotifier?.editAndResend(msg.id, t);
              Navigator.pop(ctx);
            },
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }

  // ──────────── Build ────────────

  @override
  Widget build(BuildContext context) {
    final chatState = _chatNotifier?.state;
    if (chatState == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('加载中喵...')),
          body: const Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final aiSettingsState = ref.watch(aiSettingsFromStateProvider);
    final contextWindow = aiSettingsState.contextWindow;
    final markdownEnabled = aiSettingsState.markdownRender;
    final contextPayload = buildContextPayload(
      systemPrompt: _chatNotifier?.systemPrompt ?? '',
      messages: chatState.messages,
      settings: aiSettingsState,
    );
    final usedTokens = TokenCounter.estimateMessages(
      contextPayload.history,
      contextPayload.systemPrompt,
    );
    final showCompressButton = aiSettingsState.truncateStrategy == 'compress';

    return Scaffold(
      appBar: AppBar(
        title: const Text('初雪'),
        actions: [
          IconButton(
            icon: Icon(Icons.psychology,
                color: chatState.lastReasoning.isNotEmpty
                    ? Colors.amber.shade700
                    : null),
            tooltip: '查看思考内容',
            onPressed: () => _showThinkingDialog(chatState.lastReasoning),
          ),
          IconButton(
            icon: const Icon(Icons.preview),
            tooltip: '提示词预览',
            onPressed: _showPromptPreview,
          ),
          IconButton(
            icon: Icon(markdownEnabled
                ? Icons.format_bold
                : Icons.format_bold_outlined),
            tooltip: markdownEnabled ? 'Markdown渲染：开' : 'Markdown渲染：关',
            color: markdownEnabled ? theme.colorScheme.primary : null,
            onPressed: () {
              final notifier = ref.read(settingsProvider.notifier);
              notifier.setMarkdownRender(!markdownEnabled);
              notifier.saveSettings();
            },
          ),
          if (showCompressButton)
            IconButton(
              icon: chatState.isCompressing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.compress),
              tooltip: '压缩上下文',
              onPressed: chatState.isCompressing
                  ? null
                  : () => _chatNotifier?.compressContext(),
            ),
          if (chatState.errorMessage != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '重试',
              onPressed: () => _chatNotifier?.retry(),
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _ContextWindowBar(
                  usedTokens: usedTokens, maxTokens: contextWindow),
              if (chatState.errorMessage != null)
                MaterialBanner(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  content: SelectableText(chatState.errorMessage!,
                      style: const TextStyle(fontSize: 13)),
                  backgroundColor: theme.colorScheme.errorContainer,
                  leading:
                      Icon(Icons.error_outline, color: theme.colorScheme.error),
                  actions: [
                    TextButton(
                        onPressed: () => _chatNotifier?.retry(),
                        child: const Text('重试'))
                  ],
                ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: chatState.messages.length +
                      (chatState.streamingReasoning.isNotEmpty ? 1 : 0) +
                      (chatState.streamingText.isNotEmpty ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Streaming reasoning (thinking) bubble
                    if (chatState.streamingReasoning.isNotEmpty &&
                        index == chatState.messages.length) {
                      return _ThinkingBubble(
                        content: chatState.streamingReasoning,
                        isDone: chatState.streamingText.isNotEmpty,
                      );
                    }
                    // Streaming text bubble
                    final textIdx = chatState.messages.length +
                        (chatState.streamingReasoning.isNotEmpty ? 1 : 0);
                    if (index == textIdx &&
                        chatState.streamingText.isNotEmpty) {
                      return ChatBubble(
                          content: chatState.streamingText,
                          speaker: '初雪',
                          isStreaming: true,
                          markdownEnabled: markdownEnabled);
                    }

                    final msg = chatState.messages[index];
                    if (msg.role == 'system') return const SizedBox.shrink();

                    final isUser = msg.role == 'user';
                    final isError = msg.role == 'error';
                    final hasRawPayload =
                        msg.rawPayload != null && msg.rawPayload!.isNotEmpty;
                    final isLastAi = _isLastAssistant(msg);

                    return Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        ChatBubble(
                          content: msg.content,
                          speaker: msg.speaker,
                          isUser: isUser,
                          isError: isError || hasRawPayload,
                          markdownEnabled: markdownEnabled,
                        ),
                        // Action buttons
                        if (isUser && !chatState.isLoading)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: _ActionButton(
                              icon: Icons.edit,
                              label: '改写重发',
                              onTap: () => _showEditDialog(msg),
                              isUser: true,
                            ),
                          ),
                        if (isLastAi && !chatState.isLoading)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: _ActionButton(
                              icon: Icons.refresh,
                              label: '重新生成',
                              onTap: () => _chatNotifier?.regenerate(),
                              isUser: false,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              if (chatState.pendingChoices.isNotEmpty &&
                  chatState.streamingText.isEmpty)
                ChoiceChips.fromMaps(
                  chatState.pendingChoices
                      .map((c) => {'id': c.choiceKey, 'text': c.choiceText})
                      .toList(),
                  onTap: _handleChoiceTap,
                ),
              MessageInput(
                  isLoading: chatState.isLoading,
                  onSend: _handleSend,
                  onCancel: _handleCancel),
            ],
          ),
          if (_showScrollToBottom)
            Positioned(
              right: 16,
              bottom: chatState.pendingChoices.isNotEmpty ? 112 : 72,
              child: FloatingActionButton.small(
                heroTag: 'chat-scroll-to-bottom',
                tooltip: '滚动到底部',
                onPressed: _jumpToBottom,
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            ),
        ],
      ),
    );
  }
}

/// Collapsible thinking bubble for reasoning_content display.
class _ThinkingBubble extends StatefulWidget {
  final String content;
  final bool isDone;
  const _ThinkingBubble({required this.content, required this.isDone});

  @override
  State<_ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<_ThinkingBubble> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.amber.shade900.withOpacity(0.15)
                : Colors.amber.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.shade300.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.psychology, size: 14, color: Colors.amber.shade700),
                const SizedBox(width: 6),
                Text(
                  widget.isDone ? '思考过程（点击展开/收起）' : '正在思考...',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.w600),
                ),
                if (!widget.isDone) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: Colors.amber.shade700)),
                ],
                const Spacer(),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: Colors.amber.shade600,
                ),
              ]),
              if (_expanded) ...[
                const SizedBox(height: 6),
                SelectableText(
                  widget.content,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber.shade900,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Small inline action button below a chat bubble.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isUser;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(left: isUser ? 0 : 56, right: isUser ? 56 : 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.5))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContextWindowBar extends StatelessWidget {
  final int usedTokens;
  final int maxTokens;
  const _ContextWindowBar({required this.usedTokens, required this.maxTokens});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio =
        maxTokens > 0 ? (usedTokens / maxTokens).clamp(0.0, 1.0) : 0.0;
    final barColor = ratio > 0.9
        ? Colors.red
        : ratio > 0.7
            ? Colors.orange
            : theme.colorScheme.primary;

    return Column(
      children: [
        SizedBox(
            height: 3,
            child: Row(children: [
              Expanded(
                  flex: (ratio * 100).ceil().clamp(1, 100),
                  child: Container(color: barColor)),
              if (ratio < 1.0)
                Expanded(
                    flex: 100 - (ratio * 100).ceil().clamp(0, 99),
                    child:
                        Container(color: theme.dividerColor.withOpacity(0.2))),
            ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          alignment: Alignment.centerRight,
          child: Text(TokenCounter.formatUsage(usedTokens, maxTokens),
              style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withOpacity(0.35))),
        ),
      ],
    );
  }
}
