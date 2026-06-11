import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/prompt_constants.dart';
import '../database/database.dart';
import '../services/narrative_service.dart';
import '../state/settings_state.dart';

/// Read-only preview of the full assembled system prompt.
///
/// Shows exactly what the AI will receive: character personality prompt +
/// hardcoded tool instructions + example dialogue (if enabled) + reply style.
class PromptPreviewPage extends ConsumerStatefulWidget {
  const PromptPreviewPage({super.key});

  @override
  ConsumerState<PromptPreviewPage> createState() => _PromptPreviewPageState();
}

class _PromptPreviewPageState extends ConsumerState<PromptPreviewPage> {
  String _fullPrompt = '';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _buildPreview());
  }

  Future<void> _buildPreview() async {
    try {
      final db = ref.read(databaseProvider);
      final settings = ref.read(settingsProvider);
      final narrative = ref.read(narrativeServiceProvider);

      // Character personality prompt
      final character = await db.getDefaultCharacter();
      final charPrompt = character.systemPrompt;

      // Example dialogue (if enabled)
      String exampleBlock = '';
      if (settings.includeExampleDialogue) {
        final dialogue = await narrative.readFile('example-dialogue.md');
        if (dialogue.isNotEmpty) {
          exampleBlock = '\n## 示例对话（请严格遵循此格式）\n\n$dialogue\n';
        }
      }

      // Reply style prompt
      String replyBlock = '';
      try {
        final replyStyle = await narrative.readFile('reply-style-prompt.md');
        if (replyStyle.isNotEmpty) {
          replyBlock = replyStyle;
        }
      } catch (_) {}

      // Tool instructions (if enabled)
      final toolsBlock = settings.toolsEnabled ? toolInstructions : '';

      _fullPrompt = '$charPrompt'
          '$toolsBlock'
          '$exampleBlock'
          '$replyBlock';

      setState(() => _loaded = true);
    } catch (_) {
      setState(() {
        _fullPrompt = '(加载提示词失败喵...)';
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('提示词预览')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final charCount = _fullPrompt.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('提示词预览'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: '复制全文',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _fullPrompt));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('完整提示词已复制到剪贴板喵~'), duration: Duration(seconds: 2)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '这是发送给AI的完整系统提示词。工具调用指令已固化，不可编辑。',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  ),
                ),
                Text(
                  '约${(charCount * 0.5).round()} tokens',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),
          // Prompt content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                _fullPrompt,
                style: const TextStyle(fontSize: 13, fontFamily: 'monospace', height: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
