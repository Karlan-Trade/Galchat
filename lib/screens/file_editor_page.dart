import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/narrative_service.dart';

/// Generic single-file editor. Reads/writes one file from the narrative directory.
/// Route arguments: `{'file': 'story-setup-prompt.md', 'title': '向导提示词', 'hint': '...'}`
class FileEditorPage extends ConsumerStatefulWidget {
  const FileEditorPage({super.key});

  @override
  ConsumerState<FileEditorPage> createState() => _FileEditorPageState();
}

class _FileEditorPageState extends ConsumerState<FileEditorPage> {
  final _controller = TextEditingController();
  bool _loaded = false;
  String _file = '';
  String _title = '';
  String _hint = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    if (args != null) {
      _file = args['file'] ?? '';
      _title = args['title'] ?? '文件编辑';
      _hint = args['hint'] ?? '';
    }
    if (!_loaded) {
      Future.microtask(_load);
    }
  }

  Future<void> _load() async {
    final ns = ref.read(narrativeServiceProvider);
    await ns.init();
    _controller.text = await ns.readFile(_file);
    setState(() => _loaded = true);
  }

  Future<void> _save() async {
    final ns = ref.read(narrativeServiceProvider);
    await ns.writeFile(_file, _controller.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_title 已保存喵~'), backgroundColor: Colors.green, duration: const Duration(seconds: 1)),
      );
    }
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
      return Scaffold(appBar: AppBar(title: Text(_title)), body: const Center(child: CircularProgressIndicator()));
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
          if (_hint.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              child: Text(_hint, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
            ),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontSize: 14, fontFamily: 'monospace', height: 1.6),
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
