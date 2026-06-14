import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/narrative_service.dart';

class NarrativeEditorPage extends ConsumerStatefulWidget {
  const NarrativeEditorPage({super.key});

  @override
  ConsumerState<NarrativeEditorPage> createState() =>
      _NarrativeEditorPageState();
}

class _NarrativeEditorPageState extends ConsumerState<NarrativeEditorPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _controllers = <String, TextEditingController>{};
  bool _loaded = false;

  static const _tabs = [
    _TabInfo('galgame-settings.md', '设定', Icons.settings_outlined),
    _TabInfo('galgame-npcs.md', 'NPC', Icons.people_outline),
    _TabInfo('galgame-plot-outline.md', '大纲', Icons.menu_book_outlined),
    _TabInfo('galgame-progress.md', '进度', Icons.trending_up),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    for (final t in _tabs) {
      _controllers[t.name] = TextEditingController();
    }
    _load();
  }

  Future<void> _load() async {
    final service = ref.read(narrativeServiceProvider);
    await service.init();
    final all = await service.readAll();
    for (final t in _tabs) {
      _controllers[t.name]!.text = all[t.name] ?? '';
    }
    setState(() => _loaded = true);
  }

  Future<void> _save(String name) async {
    final service = ref.read(narrativeServiceProvider);
    await service.writeFile(name, _controllers[name]!.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('$name 已保存喵~'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1)),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!_loaded) {
      return Scaffold(
          appBar: AppBar(title: const Text('叙事文件')),
          body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('叙事文件编辑'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs
              .map((t) => Tab(
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(t.icon, size: 16),
                    const SizedBox(width: 6),
                    Text(t.label)
                  ])))
              .toList(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _save(_tabs[_tabController.index].name),
            icon: const Icon(Icons.save, size: 18),
            label: const Text('保存'),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((t) {
          return Column(
            children: [
              // File path indicator
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color:
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                child: Row(children: [
                  Icon(Icons.description_outlined,
                      size: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(t.name,
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.5)))),
                  TextButton.icon(
                    onPressed: () => _save(t.name),
                    icon: const Icon(Icons.save, size: 14),
                    label: const Text('保存', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact),
                  ),
                ]),
              ),
              Expanded(
                child: TextField(
                  controller: _controllers[t.name],
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                      fontSize: 14, fontFamily: 'monospace', height: 1.6),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _TabInfo {
  final String name;
  final String label;
  final IconData icon;
  const _TabInfo(this.name, this.label, this.icon);
}
