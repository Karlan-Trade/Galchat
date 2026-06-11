import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/settings_state.dart';

/// Prompt and character configuration page.
class PromptSettingsPage extends ConsumerStatefulWidget {
  const PromptSettingsPage({super.key});

  @override
  ConsumerState<PromptSettingsPage> createState() => _PromptSettingsPageState();
}

class _PromptSettingsPageState extends ConsumerState<PromptSettingsPage> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(settingsProvider.notifier).load();
      setState(() => _loaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('提示词设置')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('提示词设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==========================================
          // Character & Prompt Files
          // ==========================================
          const _SectionHeader(title: '提示词文件', icon: Icons.description_outlined),
          const SizedBox(height: 8),

          _NavTile(
            icon: Icons.person,
            title: '角色卡 (人格提示词)',
            subtitle: '定义初雪的身份、性格、说话方式和行为规则',
            onTap: () => Navigator.pushNamed(context, '/character-card'),
          ),
          _NavTile(
            icon: Icons.chat_bubble_outline,
            title: '示例对话',
            subtitle: '帮助AI理解Galgame叙事格式的循环示例',
            onTap: () => Navigator.pushNamed(context, '/file-editor', arguments: {
              'file': 'example-dialogue.md',
              'title': '示例对话',
              'hint': '帮助AI理解Galgame叙事格式。包含完整的场景→动作→选项→用户选择→AI回复循环示例',
              },
            ),
          ),
          _NavTile(
            icon: Icons.menu_book_outlined,
            title: '叙事文件 (设定/NPC/大纲/进度)',
            subtitle: '世界观设定、NPC阵容、剧情大纲和进度追踪',
            onTap: () => Navigator.pushNamed(context, '/narrative'),
          ),
          _NavTile(
            icon: Icons.auto_awesome,
            title: '向导提示词',
            subtitle: '新建对话时初雪引导故事设定的提示词',
            onTap: () => Navigator.pushNamed(context, '/file-editor', arguments: {
              'file': 'story-setup-prompt.md',
              'title': '向导提示词',
              'hint': '这是新建对话时，初雪引导故事设定的提示词。修改后下次创建新对话时生效喵~',
              },
            ),
          ),
          _NavTile(
            icon: Icons.play_arrow,
            title: '开场提示词',
            subtitle: 'AI生成第一条消息时的用户提示词',
            onTap: () => Navigator.pushNamed(context, '/file-editor', arguments: {
              'file': 'opening-message-prompt.md',
              'title': '开场提示词',
              'hint': 'AI生成第一条消息时的用户提示词。可自定义开场内容要求喵~',
              },
            ),
          ),
          _NavTile(
            icon: Icons.format_quote,
            title: '回复风格提示词',
            subtitle: '追加在System Prompt末尾的回复风格引导',
            onTap: () => Navigator.pushNamed(context, '/file-editor', arguments: {
              'file': 'reply-style-prompt.md',
              'title': '回复风格提示词',
              'hint': '追加在System Prompt末尾的回复风格引导。控制AI的对话方式喵~',
              },
            ),
          ),
          _NavTile(
            icon: Icons.preview,
            title: '提示词预览',
            subtitle: '查看发送给AI的完整系统提示词（含固化的工具调用指令）',
            onTap: () => Navigator.pushNamed(context, '/prompt-preview'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// A navigation tile for opening sub-editors.
class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
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
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
      ],
    );
  }
}
