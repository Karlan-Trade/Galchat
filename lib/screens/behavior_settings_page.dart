import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/settings_state.dart';

/// Behavior toggle settings page.
class BehaviorSettingsPage extends ConsumerStatefulWidget {
  const BehaviorSettingsPage({super.key});

  @override
  ConsumerState<BehaviorSettingsPage> createState() =>
      _BehaviorSettingsPageState();
}

class _BehaviorSettingsPageState extends ConsumerState<BehaviorSettingsPage> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(settingsProvider.notifier).load();
      setState(() => _loaded = true);
    });
  }

  Future<void> _savePrefs() async {
    await ref.read(settingsProvider.notifier).saveSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('行为设置已保存喵~ ✨'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('行为设置')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('行为设置'),
        actions: [
          TextButton.icon(
            onPressed: _savePrefs,
            icon: const Icon(Icons.save, size: 18),
            label: const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader(title: '对话行为', icon: Icons.chat_outlined),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('示例对话加入提示词', style: TextStyle(fontSize: 14)),
            subtitle: Text(
              '帮助AI理解Galgame叙事格式。关闭可节省上下文窗口',
              style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ),
            value: state.includeExampleDialogue,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .setIncludeExampleDialogue(v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('AI主动发送开场', style: TextStyle(fontSize: 14)),
            subtitle: Text(
              '新建对话后初雪主动发来第一条消息。关闭则由主人自由输入第一句话',
              style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ),
            value: state.aiFirstMessage,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setAiFirstMessage(v),
          ),
          const SizedBox(height: 18),
          const _SectionHeader(title: 'AI 能力', icon: Icons.smart_toy_outlined),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('思考模式', style: TextStyle(fontSize: 14)),
            subtitle: Text(
              '开启后AI会先内部分析再回复，提升回答质量。仅支持的模型有效',
              style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ),
            value: state.thinkingEnabled,
            onChanged: (v) {
              ref.read(settingsProvider.notifier).setThinkingEnabled(v);
              if (!v)
                ref.read(settingsProvider.notifier).setToolsEnabled(false);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('工具调用', style: TextStyle(fontSize: 14)),
            subtitle: Text(
              state.thinkingEnabled
                  ? '允许AI读取和更新叙述文件（设定/NPC/大纲/进度），实现有记忆的互动。关闭后AI不再维护进度文件'
                  : '需要先开启"思考模式"才能使用工具调用',
              style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface
                      .withOpacity(state.thinkingEnabled ? 0.5 : 0.35)),
            ),
            value: state.toolsEnabled,
            onChanged: state.thinkingEnabled
                ? (v) => ref.read(settingsProvider.notifier).setToolsEnabled(v)
                : null,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary)),
      ],
    );
  }
}
