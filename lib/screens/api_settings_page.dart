import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_provider_preset.dart';
import '../state/settings_state.dart';

/// API and provider configuration page.
class ApiSettingsPage extends ConsumerStatefulWidget {
  const ApiSettingsPage({super.key});

  @override
  ConsumerState<ApiSettingsPage> createState() => _ApiSettingsPageState();
}

class _ApiSettingsPageState extends ConsumerState<ApiSettingsPage> {
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  final _maxTokensController = TextEditingController();
  final _contextWindowController = TextEditingController();
  final _truncateLimitController = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(settingsProvider.notifier).load();
      _syncControllers();
      setState(() => _loaded = true);
    });
  }

  void _syncControllers() {
    final state = ref.read(settingsProvider);
    _baseUrlController.text = state.baseUrl;
    _modelController.text = state.model;
    _maxTokensController.text = state.maxTokens > 0 ? state.maxTokens.toString() : '';
    _contextWindowController.text = state.contextWindow > 0 ? state.contextWindow.toString() : '';
    _truncateLimitController.text = state.truncateLimit.toString();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelController.dispose();
    _maxTokensController.dispose();
    _contextWindowController.dispose();
    _truncateLimitController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final notifier = ref.read(settingsProvider.notifier);
    notifier.setBaseUrl(_baseUrlController.text.trim());
    notifier.setModel(_modelController.text.trim());
    final maxTokens = int.tryParse(_maxTokensController.text.trim());
    if (maxTokens != null && maxTokens >= 1) {
      notifier.setMaxTokens(maxTokens);
    }
    final contextWindow = int.tryParse(_contextWindowController.text.trim());
    if (contextWindow != null && contextWindow >= 1024) {
      notifier.setContextWindow(contextWindow);
    }
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isNotEmpty) {
      await notifier.saveApiKey(apiKey);
      _apiKeyController.clear();
    }
    final ok = await notifier.saveSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        ok
            ? const SnackBar(content: Text('设置已保存喵~ ✨'), backgroundColor: Colors.green, duration: Duration(seconds: 2))
            : const SnackBar(content: Text('保存失败喵...请重试'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('API 设置')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('API 设置'),
        actions: [
          TextButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save, size: 18),
            label: const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ==========================================
          // Provider Preset Selector
          // ==========================================
          const _SectionHeader(title: '服务商', icon: Icons.dns_outlined),
          const SizedBox(height: 4),
          Text(
            '选择一个预设将自动填入 API 地址，模型等参数请自行配置',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in builtInPresets)
                _PresetChip(
                  preset: preset,
                  selected: state.providerPresetId == preset.id,
                  onTap: () {
                    ref.read(settingsProvider.notifier).selectProviderPreset(preset);
                    _syncControllers();
                  },
                ),
            ],
          ),
          const SizedBox(height: 18),

          // ==========================================
          // API Key
          // ==========================================
          const _SectionHeader(title: 'API Key', icon: Icons.vpn_key_outlined),
          const SizedBox(height: 8),
          TextField(
            controller: _apiKeyController,
            obscureText: state.isApiKeyMasked,
            decoration: InputDecoration(
              hintText: state.hasApiKey ? '•••••••••••••••• (已设置)' : '输入你的API Key',
              labelText: 'API Key',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.key),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.hasApiKey)
                    IconButton(
                      icon: Icon(state.isApiKeyMasked ? Icons.visibility_off : Icons.visibility, size: 20),
                      tooltip: state.isApiKeyMasked ? '显示' : '隐藏',
                      onPressed: () => ref.read(settingsProvider.notifier).toggleApiKeyMask(),
                    ),
                  if (state.hasApiKey)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: '清除API Key',
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('清除API Key'),
                            content: const Text('确定要清除已保存的API Key吗喵？'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('清除'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          ref.read(settingsProvider.notifier).clearApiKey();
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'API Key仅保存在设备安全存储中，不会导出到备份文件。',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          ),
          const SizedBox(height: 18),

          // ==========================================
          // Provider settings
          // ==========================================
          const _SectionHeader(title: '接口配置', icon: Icons.api_outlined),
          const SizedBox(height: 8),

          TextField(
            controller: _baseUrlController,
            decoration: const InputDecoration(
              labelText: 'Base URL',
              hintText: 'https://api.deepseek.com',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.link),
            ),
            onChanged: (val) => ref.read(settingsProvider.notifier).setBaseUrl(val),
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _modelController,
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    hintText: '',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.smart_toy_outlined),
                  ),
                  onChanged: (val) => ref.read(settingsProvider.notifier).setModel(val),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: state.isLoadingModels
                      ? null
                      : () => ref.read(settingsProvider.notifier).fetchModels(),
                  child: state.isLoadingModels
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.cloud_download_outlined, size: 20),
                ),
              ),
            ],
          ),

          if (state.availableModels.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      '可用模型 (${state.availableModels.length})',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.availableModels.length,
                      itemBuilder: (ctx, i) {
                        final m = state.availableModels[i];
                        final isSelected = m.id == state.model;
                        return ListTile(
                          dense: true,
                          selected: isSelected,
                          title: Text(m.id, style: const TextStyle(fontSize: 13)),
                          subtitle: m.ownedBy != null ? Text(m.ownedBy!, style: const TextStyle(fontSize: 11)) : null,
                          trailing: isSelected ? Icon(Icons.check, size: 16, color: theme.colorScheme.primary) : null,
                          onTap: () {
                            _modelController.text = m.id;
                            ref.read(settingsProvider.notifier).setModel(m.id);
                            ref.read(settingsProvider.notifier).clearAvailableModels();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Temperature
          Row(
            children: [
              const Icon(Icons.thermostat_outlined, size: 20),
              const SizedBox(width: 8),
              const Text('Temperature'),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: state.temperature,
                  min: 0.0,
                  max: 2.0,
                  divisions: 20,
                  label: state.temperature.toStringAsFixed(1),
                  onChanged: (val) => ref.read(settingsProvider.notifier).setTemperature(val),
                ),
              ),
              SizedBox(width: 40, child: Text(state.temperature.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w500))),
            ],
          ),

          // Context window
          TextField(
            controller: _contextWindowController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '模型上下文窗口',
              hintText: '',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.memory),
              helperText: '模型实际支持的总上下文大小（Token），用于对话页进度条显示',
            ),
            onChanged: (val) {
              final n = int.tryParse(val.trim());
              if (n != null && n >= 1024) ref.read(settingsProvider.notifier).setContextWindow(n);
            },
          ),
          const SizedBox(height: 12),

          // Max Tokens
          TextField(
            controller: _maxTokensController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '单次回复最大 Token',
              hintText: '',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tune),
              helperText: 'AI单次回复最多生成的Token数，超出将被截断',
            ),
            onChanged: (val) {
              final n = int.tryParse(val.trim());
              if (n != null && n >= 1) ref.read(settingsProvider.notifier).setMaxTokens(n);
            },
          ),
          const SizedBox(height: 18),

          // ==========================================
          // Context Management
          // ==========================================
          const _SectionHeader(title: '上下文管理', icon: Icons.memory_outlined),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _StrategyChip(
                  label: '压缩',
                  subtitle: 'AI 将历史总结为摘要',
                  icon: Icons.compress,
                  selected: state.truncateStrategy == 'compress',
                  onTap: () => ref.read(settingsProvider.notifier).setTruncateStrategy('compress'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StrategyChip(
                  label: '截断',
                  subtitle: '保留最近 N 轮对话',
                  icon: Icons.content_cut,
                  selected: state.truncateStrategy == 'truncate',
                  onTap: () => ref.read(settingsProvider.notifier).setTruncateStrategy('truncate'),
                ),
              ),
            ],
          ),

          if (state.truncateStrategy == 'truncate') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _truncateLimitController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '保留最近对话轮数',
                hintText: '20',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.repeat),
                helperText: '超过此轮数的旧消息将被丢弃，不发送给AI',
                suffixText: '轮',
              ),
              onChanged: (val) {
                final n = int.tryParse(val.trim());
                if (n != null && n >= 1) ref.read(settingsProvider.notifier).setTruncateLimit(n);
              },
            ),
          ],
          const SizedBox(height: 18),

          // ==========================================
          // Connection Test
          // ==========================================
          const _SectionHeader(title: '连接测试', icon: Icons.wifi_tethering),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: state.isTesting ? null : () => ref.read(settingsProvider.notifier).testConnection(),
              icon: state.isTesting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.play_arrow),
              label: Text(state.isTesting ? '测试中...' : '测试连接'),
            ),
          ),
          if (state.testResult != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: state.testSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: (state.testSuccess ? Colors.green : Colors.red).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(state.testSuccess ? Icons.check_circle : Icons.error, size: 18, color: state.testSuccess ? Colors.green : Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.testResult!, style: TextStyle(fontSize: 13, color: state.testSuccess ? Colors.green[800] : Colors.red[800]))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// A chip showing an API provider preset name and protocol type.
class _PresetChip extends StatelessWidget {
  final ApiProviderPreset preset;
  final bool selected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = selected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest;
    final fgColor = selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    final borderColor = selected ? theme.colorScheme.primary : theme.dividerColor;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(preset.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fgColor)),
              if (selected) ...[
                const SizedBox(width: 4),
                Icon(Icons.check_circle, size: 16, color: fgColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Strategy selection chip for context management.
class _StrategyChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _StrategyChip({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest;
    final textColor = selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? theme.colorScheme.primary : theme.dividerColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: textColor),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
              const SizedBox(height: 2),
              Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.7))),
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
