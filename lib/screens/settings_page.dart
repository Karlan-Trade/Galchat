import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_provider_preset.dart';
import '../services/backup_service.dart';
import '../services/narrative_service.dart';
import '../state/conversation_state.dart';
import '../state/settings_state.dart';

/// Settings hub — entry point to sub-settings pages and backup/restore.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _loaded = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        await ref.read(settingsProvider.notifier).load();
      } catch (e) {
        _loadError = '$e';
      }
      if (mounted) {
        setState(() => _loaded = true);
      }
    });
  }

  Future<void> _exportBackup() async {
    try {
      final backupService = ref.read(backupServiceProvider);

      // Build the JSON payload first so we have the bytes for the save dialog.
      final json = await backupService.buildExportJson();
      final bytes = utf8.encode(json);

      final savePath = await FilePicker.saveFile(
        dialogTitle: '选择备份保存位置',
        fileName: 'galchat_backup.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (savePath == null) return; // user cancelled

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('备份已导出到: $savePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败喵: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Open the story setup wizard. If narrative files already hold content,
  /// warn first — running the wizard overwrites those files and seeds a new
  /// character prompt + conversation.
  Future<void> _openStorySetup() async {
    final ns = ref.read(narrativeServiceProvider);
    final existing = await Future.wait([
      ns.readFile('galgame-settings.md'),
      ns.readFile('galgame-npcs.md'),
      ns.readFile('galgame-plot-outline.md'),
    ]);
    final hasSetup = existing.any((c) => c.trim().isNotEmpty);

    if (!mounted) return;

    if (hasSetup) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('已存在故事设定'),
          content: const Text(
            '检测到已有故事设定文件喵...重新使用向导会覆盖现有的世界观、NPC、剧情大纲和角色提示词，'
            '已经进行中的对话不受影响，但新设定会成为之后的默认设定哦~确定要继续吗？',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('继续设定')),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    if (mounted) Navigator.pushNamed(context, '/story-setup');
  }

  Future<void> _importBackup() async {    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: '选择备份文件',
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;
      final path = result.files.single.path;
      if (path == null || path.isEmpty) return;

      if (!mounted) return;

      final backupService = ref.read(backupServiceProvider);
      final count = await backupService.importFromFile(path);

      ref.read(conversationListProvider.notifier).loadConversations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('成功导入 $count 个对话喵~ ✨'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on BackupException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败喵: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('设置')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('设置')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('加载设置失败喵...', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text(_loadError!, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () async {
                    setState(() {
                      _loaded = false;
                      _loadError = null;
                    });
                    try {
                      await ref.read(settingsProvider.notifier).load();
                    } catch (e) {
                      _loadError = '$e';
                    }
                    if (mounted) setState(() => _loaded = true);
                  },
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final hasKey = state.hasApiKey;
    final connectionStatus = hasKey ? '已配置' : '未配置';
    final connectionColor = hasKey ? Colors.green : theme.colorScheme.error;

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==========================================
          // API Settings entry
          // ==========================================
          _HubCard(
            icon: Icons.api_outlined,
            title: 'API 设置',
            subtitle: state.model.isNotEmpty
                ? '${findPreset(state.providerPresetId).name} · ${state.model}'
                : '${findPreset(state.providerPresetId).name} (模型待设置)',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: connectionColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(connectionStatus, style: TextStyle(fontSize: 11, color: connectionColor, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () => Navigator.pushNamed(context, '/api-settings'),
          ),
          const SizedBox(height: 10),

          // ==========================================
          // Behavior Settings entry
          // ==========================================
          _HubCard(
            icon: Icons.toggle_on_outlined,
            title: '行为设置',
            subtitle: '示例对话 · AI开场 · 思考模式 · 工具调用',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/behavior-settings'),
          ),
          const SizedBox(height: 10),

          // ==========================================
          // Prompt Settings entry
          // ==========================================
          _HubCard(
            icon: Icons.description_outlined,
            title: '提示词设置',
            subtitle: '角色卡 · 叙事文件 · 示例对话 · 回复风格',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/prompt-settings'),
          ),
          const SizedBox(height: 10),

          // ==========================================
          // Story Setup
          // ==========================================
          _HubCard(
            icon: Icons.folder_special_outlined,
            title: '故事设定向导',
            subtitle: '新建一个带有自定义设定和开场的剧情存档',
            trailing: const Icon(Icons.chevron_right),
            onTap: _openStorySetup,
          ),
          const SizedBox(height: 24),

          // ==========================================
          // Backup & Restore
          // ==========================================
          const _SectionHeader(title: '数据备份', icon: Icons.backup_outlined),
          const SizedBox(height: 8),

          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.file_upload_outlined,
                    title: '导出备份',
                    subtitle: '将所有对话和设定数据导出为备份文件',
                    onTap: _exportBackup,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.file_download_outlined,
                    title: '导入备份',
                    subtitle: '从备份文件恢复对话和数据',
                    onTap: _importBackup,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '备份文件不含API Key，安全存储在本地。',
            style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.45)),
          ),

          const SizedBox(height: 32),

          // Version info
          Center(
            child: Text(
              'GalChat v0.6.2 · 初雪',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.3)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// A big tappable card for navigating to a sub-settings page.
class _HubCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  const _HubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.55))),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// A tappable action card for backup/restore operations.
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 28, color: theme.colorScheme.primary),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.55)),
              ),
            ],
          ),
        ),
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
