import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../database/database.dart';
import '../services/narrative_service.dart';
import '../state/chat_state.dart';
import '../state/settings_state.dart';

class ConversationMemoryPage extends ConsumerStatefulWidget {
  const ConversationMemoryPage({super.key});

  @override
  ConsumerState<ConversationMemoryPage> createState() =>
      _ConversationMemoryPageState();
}

class _ConversationMemoryPageState
    extends ConsumerState<ConversationMemoryPage> {
  final _controller = TextEditingController();
  bool _loaded = false;
  int? _conversationId;
  String _title = '记忆';
  String _kind = 'memory';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, Object?>?;
    final nextId = args?['conversationId'] as int?;
    if (nextId != null && nextId != _conversationId) {
      _conversationId = nextId;
      _title = args?['title'] as String? ?? '记忆';
      _kind = args?['kind'] as String? ?? 'memory';
      _loaded = false;
      Future.microtask(_load);
    }
  }

  Future<void> _load() async {
    final conversationId = _conversationId;
    if (conversationId == null) return;
    final ns = ref.read(narrativeServiceProvider);
    await ns.init();
    final content = _kind == 'summary'
        ? await _readCompressedContext(conversationId)
        : await ns.readConversationMemory(conversationId);
    if (!mounted || _conversationId != conversationId) return;
    _controller.text = content;
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    final conversationId = _conversationId;
    if (conversationId == null) return;
    final ns = ref.read(narrativeServiceProvider);
    if (_kind == 'summary') {
      await _writeCompressedContext(conversationId, _controller.text);
    } else {
      await ns.writeConversationMemory(conversationId, _controller.text);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_kind == 'summary' ? '上下文摘要已保存喵~' : '记忆已保存喵~'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<String> _readCompressedContext(int conversationId) async {
    final db = ref.read(databaseProvider);
    final messages = await db.getMessagesByConversation(conversationId);
    final summaries = messages.where((m) =>
        m.role == 'system' &&
        m.content.trim().startsWith(compressedContextMarker));
    if (summaries.isEmpty) return '';
    return summaries.map((m) {
      final content = m.content.trim();
      return content.startsWith(compressedContextMarker)
          ? content.substring(compressedContextMarker.length).trimLeft()
          : content;
    }).join('\n\n');
  }

  Future<void> _writeCompressedContext(
      int conversationId, String content) async {
    final db = ref.read(databaseProvider);
    final messages = await db.getMessagesByConversation(conversationId);
    final summaries = messages
        .where((m) =>
            m.role == 'system' &&
            m.content.trim().startsWith(compressedContextMarker))
        .toList();

    await db.transaction(() async {
      for (final message in summaries) {
        await db.deleteMessage(message.id);
      }
      final text = content.trim();
      if (text.isNotEmpty) {
        await db.insertMessage(
          MessagesCompanion(
            conversationId: Value(conversationId),
            role: const Value('system'),
            speaker: const Value(''),
            content: Value('$compressedContextMarker\n$text'),
            createdAt: Value(DateTime.now()),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final truncateStrategy = ref.watch(settingsProvider).truncateStrategy;
    final helperText = _helperText(truncateStrategy);

    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: Text(_title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save, size: 18),
            label: const Text('保存'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            child: Text(
              helperText,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                height: 1.6,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _helperText(String truncateStrategy) {
    if (_kind != 'summary') {
      return '此记忆只属于当前对话，删除对话时会一起删除。';
    }
    if (truncateStrategy == 'truncate') {
      return '当前为截断模式，不会自动生成新摘要；已有摘要仍会参与后续回复，清空并保存可移除。';
    }
    return '此摘要会作为当前对话的压缩上下文参与后续回复。清空并保存可移除摘要。';
  }
}
