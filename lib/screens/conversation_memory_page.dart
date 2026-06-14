import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/narrative_service.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, Object?>?;
    final nextId = args?['conversationId'] as int?;
    if (nextId != null && nextId != _conversationId) {
      _conversationId = nextId;
      _title = args?['title'] as String? ?? '记忆';
      _loaded = false;
      Future.microtask(_load);
    }
  }

  Future<void> _load() async {
    final conversationId = _conversationId;
    if (conversationId == null) return;
    final ns = ref.read(narrativeServiceProvider);
    await ns.init();
    final content = await ns.readConversationMemory(conversationId);
    if (!mounted || _conversationId != conversationId) return;
    _controller.text = content;
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    final conversationId = _conversationId;
    if (conversationId == null) return;
    final ns = ref.read(narrativeServiceProvider);
    await ns.writeConversationMemory(conversationId, _controller.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('记忆已保存喵~'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              '此记忆只属于当前对话，删除对话时会一起删除。',
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
}
