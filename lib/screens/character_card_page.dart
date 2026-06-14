import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';

/// Character card editing page — only the personality prompt is user-editable.
/// Tool instructions are hardcoded and appended automatically at runtime.
class CharacterCardPage extends ConsumerStatefulWidget {
  const CharacterCardPage({super.key});

  @override
  ConsumerState<CharacterCardPage> createState() => _CharacterCardPageState();
}

class _CharacterCardPageState extends ConsumerState<CharacterCardPage> {
  final _systemPromptController = TextEditingController();
  bool _loaded = false;
  Character? _character;

  @override
  void initState() {
    super.initState();
    _loadCharacter();
  }

  Future<void> _loadCharacter() async {
    final db = ref.read(databaseProvider);
    _character = await db.getDefaultCharacter();

    _systemPromptController.text = _character?.systemPrompt ?? '';

    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _systemPromptController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final db = ref.read(databaseProvider);
    await db.updateCharacter(
      characterId: _character!.id,
      displayName: _character!.displayName,
      systemPrompt: _systemPromptController.text.trim(),
      greeting: _character!.greeting,
      worldSetting: _character!.worldSetting,
      replyStyle: _character!.replyStyle ?? '',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('角色卡已保存喵~ ✨'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _resetToDefault() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('恢复默认'),
        content: const Text('确定要恢复为默认的初雪人格提示词吗？你的修改将会丢失喵...'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('恢复默认'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final db = ref.read(databaseProvider);
    await db.resetCharacterToDefault(_character!.id);
    await _loadCharacter();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('角色卡')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('角色卡编辑'),
        actions: [
          TextButton(onPressed: _resetToDefault, child: const Text('恢复默认')),
          TextButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save, size: 18),
              label: const Text('保存')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                _character?.displayName.isNotEmpty == true
                    ? _character!.displayName[0]
                    : '？',
                style: TextStyle(
                    fontSize: 28, color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: '人格提示词', icon: Icons.psychology_outlined),
          const SizedBox(height: 4),
          Text(
            '这是初雪的核心人格设定，决定了她的性格、说话方式和行为规则。工具调用指令已固化在系统提示词中，可在"提示词预览"查看完整内容喵~',
            style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _systemPromptController,
            maxLines: null,
            minLines: 12,
            style: const TextStyle(
                fontSize: 13, fontFamily: 'monospace', height: 1.5),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.all(12),
              hintText: '输入角色的人格设定...',
              hintStyle: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.3)),
            ),
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
