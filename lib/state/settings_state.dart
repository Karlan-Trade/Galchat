import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../database/database.dart';
import '../models/api_provider_preset.dart';
import '../providers/ai_provider.dart';
import '../providers/provider_factory.dart';
import '../services/api_key_service.dart';

/// Holds the UI state for the settings page.
class SettingsUiState {
  final String baseUrl;
  final String model;
  final double temperature;
  final int maxTokens;
  final int contextWindow;
  final String truncateStrategy;
  final int truncateLimit;
  final bool includeExampleDialogue;
  final bool aiFirstMessage;
  final bool thinkingEnabled;
  final bool toolsEnabled;
  final bool markdownRender;
  final String providerPresetId;
  final bool hasApiKey;
  final bool isApiKeyMasked;
  final bool isTesting;
  final String? testResult;
  final bool testSuccess;
  final List<AiModel> availableModels;
  final bool isLoadingModels;

  const SettingsUiState({
    this.baseUrl = 'https://api.deepseek.com/v1',
    this.model = '',
    this.temperature = 0.7,
    this.maxTokens = 0,
    this.contextWindow = 0,
    this.truncateStrategy = 'compress',
    this.truncateLimit = 20,
    this.includeExampleDialogue = true,
    this.aiFirstMessage = true,
    this.thinkingEnabled = true,
    this.toolsEnabled = true,
    this.markdownRender = false,
    this.providerPresetId = 'deepseek',
    this.hasApiKey = false,
    this.isApiKeyMasked = true,
    this.isTesting = false,
    this.testResult,
    this.testSuccess = false,
    this.availableModels = const [],
    this.isLoadingModels = false,
  });

  SettingsUiState copyWith({
    String? baseUrl, String? model, double? temperature, int? maxTokens,
    int? contextWindow, String? truncateStrategy, int? truncateLimit, bool? includeExampleDialogue,
    bool? aiFirstMessage, bool? thinkingEnabled, bool? toolsEnabled, bool? markdownRender, String? providerPresetId, bool? hasApiKey, bool? isApiKeyMasked, bool? isTesting,
    String? testResult, bool? testSuccess, bool clearTestResult = false,
    List<AiModel>? availableModels, bool? isLoadingModels, bool clearModels = false,
  }) {
    return SettingsUiState(
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      contextWindow: contextWindow ?? this.contextWindow,
      truncateStrategy: truncateStrategy ?? this.truncateStrategy,
      truncateLimit: truncateLimit ?? this.truncateLimit,
      includeExampleDialogue: includeExampleDialogue ?? this.includeExampleDialogue,
      aiFirstMessage: aiFirstMessage ?? this.aiFirstMessage,
      thinkingEnabled: thinkingEnabled ?? this.thinkingEnabled,
      toolsEnabled: toolsEnabled ?? this.toolsEnabled,
      markdownRender: markdownRender ?? this.markdownRender,
      providerPresetId: providerPresetId ?? this.providerPresetId,
      hasApiKey: hasApiKey ?? this.hasApiKey,
      isApiKeyMasked: isApiKeyMasked ?? this.isApiKeyMasked,
      isTesting: isTesting ?? this.isTesting,
      testResult: clearTestResult ? null : (testResult ?? this.testResult),
      testSuccess: testSuccess ?? this.testSuccess,
      availableModels: clearModels ? [] : (availableModels ?? this.availableModels),
      isLoadingModels: isLoadingModels ?? this.isLoadingModels,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsUiState> {
  final AppDatabase _db;
  final ApiKeyService _apiKeyService;

  SettingsNotifier(this._db, this._apiKeyService) : super(const SettingsUiState());

  Future<void> load() async {
    try {
      final aiSettings = await _db.getAiSettings();
      final hasKey = await _apiKeyService.hasApiKey();

      if (aiSettings != null) {
        state = SettingsUiState(
          baseUrl: aiSettings.baseUrl,
          model: aiSettings.model,
          temperature: aiSettings.temperature,
          maxTokens: aiSettings.maxTokens,
          contextWindow: aiSettings.contextWindow,
          truncateStrategy: aiSettings.truncateStrategy,
          truncateLimit: aiSettings.truncateLimit,
          markdownRender: aiSettings.markdownRender,
          hasApiKey: hasKey,
        );
      } else {
        state = state.copyWith(hasApiKey: hasKey);
      }
    } catch (e) {
      debugPrint('SettingsNotifier.load: 数据库读取失败，使用默认值 — $e');
      final hasKey = await _apiKeyService.hasApiKey();
      state = state.copyWith(hasApiKey: hasKey);
    }
    final hadSavedPreset = await _loadPrefs();
    // Only derive the preset from the URL when the user has never made an
    // explicit choice (legacy config / first run). Once a preset is saved,
    // trust it — editing the Base URL must not silently de-select the chip.
    if (!hadSavedPreset) _autoDetectPreset();
  }

  /// Auto-detect preset from current base URL, unless user explicitly has a preset set.
  void _autoDetectPreset() {
    final detected = detectPreset(state.baseUrl);
    if (detected.id == 'custom' && state.providerPresetId != 'custom') {
      // User was on a preset but no longer matches — mark as custom
      state = state.copyWith(providerPresetId: 'custom');
    } else if (detected.id != 'custom' && state.providerPresetId != detected.id) {
      // Base URL matches a known preset — sync
      state = state.copyWith(providerPresetId: detected.id);
    }
  }

  void setBaseUrl(String url) {
    // Only update the URL — keep current preset id intact.
    // Preset gets set exclusively by selectProviderPreset().
    state = state.copyWith(baseUrl: url);
  }
  void setModel(String model) => state = state.copyWith(model: model);
  void setTemperature(double temp) => state = state.copyWith(temperature: temp);
  void setMaxTokens(int tokens) => state = state.copyWith(maxTokens: tokens);
  void setContextWindow(int n) => state = state.copyWith(contextWindow: n);
  void setTruncateStrategy(String s) => state = state.copyWith(truncateStrategy: s);
  void setTruncateLimit(int n) => state = state.copyWith(truncateLimit: n);
  void setIncludeExampleDialogue(bool v) => state = state.copyWith(includeExampleDialogue: v);
  void setAiFirstMessage(bool v) => state = state.copyWith(aiFirstMessage: v);
  void setThinkingEnabled(bool v) => state = state.copyWith(thinkingEnabled: v);
  void setToolsEnabled(bool v) => state = state.copyWith(toolsEnabled: v);
  void setMarkdownRender(bool v) => state = state.copyWith(markdownRender: v);

  /// Clear the available models list (e.g. after user selects a model).
  void clearAvailableModels() => state = state.copyWith(clearModels: true);

  /// Mark the current config as custom (no preset).
  void markAsCustomPreset() {
    state = state.copyWith(providerPresetId: 'custom');
  }

  /// Select a provider preset, filling in only the base URL.
  /// Model / context window / max tokens are left for the user to configure.
  void selectProviderPreset(ApiProviderPreset preset) {
    state = state.copyWith(
      providerPresetId: preset.id,
      baseUrl: preset.baseUrl,
    );
  }

  Future<String> _prefsPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/narrative/preferences.json';
  }

  Future<void> _savePrefs() async {
    try {
      final path = await _prefsPath();
      final f = File(path);
      await f.parent.create(recursive: true);
      await f.writeAsString(jsonEncode({
        'includeExampleDialogue': state.includeExampleDialogue,
        'aiFirstMessage': state.aiFirstMessage,
        'thinkingEnabled': state.thinkingEnabled,
        'toolsEnabled': state.toolsEnabled,
        'providerPresetId': state.providerPresetId,
      }));
    } catch (e) {
      debugPrint('SettingsNotifier._savePrefs: 保存偏好文件失败 — $e');
    }
  }

  /// Returns true if a `providerPresetId` was explicitly persisted, so the
  /// caller can skip URL-based auto-detection and honor the saved choice.
  Future<bool> _loadPrefs() async {
    try {
      final path = await _prefsPath();
      final f = File(path);
      if (f.existsSync()) {
        final data = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
        // Only update behavior toggles from JSON; DB fields (baseUrl, model,
        // markdownRender, etc.) are loaded separately and shouldn't be
        // overwritten here.
        state = state.copyWith(
          includeExampleDialogue: data['includeExampleDialogue'] as bool? ?? state.includeExampleDialogue,
          aiFirstMessage: data['aiFirstMessage'] as bool? ?? state.aiFirstMessage,
          thinkingEnabled: data['thinkingEnabled'] as bool? ?? state.thinkingEnabled,
          toolsEnabled: data['toolsEnabled'] as bool? ?? state.toolsEnabled,
          providerPresetId: data['providerPresetId'] as String? ?? state.providerPresetId,
        );
        return data.containsKey('providerPresetId');
      }
    } catch (e) {
      debugPrint('SettingsNotifier._loadPrefs: 读取偏好文件失败 — $e');
    }
    return false;
  }

  Future<void> saveApiKey(String key) async {
    if (key.isNotEmpty) {
      await _apiKeyService.setApiKey(key);
      state = state.copyWith(hasApiKey: true);
    }
  }

  Future<void> clearApiKey() async {
    await _apiKeyService.deleteApiKey();
    state = state.copyWith(hasApiKey: false);
  }

  void toggleApiKeyMask() {
    state = state.copyWith(isApiKeyMasked: !state.isApiKeyMasked);
  }

  Future<bool> saveSettings() async {
    try {
      await _db.saveAiSettings(AiSettingsCompanion(
        baseUrl: Value(state.baseUrl),
        model: Value(state.model),
        temperature: Value(state.temperature),
        maxTokens: Value(state.maxTokens),
        contextWindow: Value(state.contextWindow),
        truncateStrategy: Value(state.truncateStrategy),
        truncateLimit: Value(state.truncateLimit),
        markdownRender: Value(state.markdownRender),
        updatedAt: Value(DateTime.now()),
      ));
      await _savePrefs();
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('设置保存失败: $e');
      return false;
    }
  }

  Future<void> testConnection() async {
    state = state.copyWith(isTesting: true, clearTestResult: true);
    final apiKey = await _apiKeyService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      state = state.copyWith(isTesting: false, testResult: '请先设置API Key喵~', testSuccess: false);
      return;
    }
    final provider = createAiProvider(
      apiKey: apiKey, settings: AiSettings(baseUrl: state.baseUrl, model: state.model),
    );
    final result = await provider.testConnection(AiSettings(baseUrl: state.baseUrl, model: state.model));
    state = state.copyWith(isTesting: false, testResult: result.message, testSuccess: result.success);
  }

  Future<void> fetchModels() async {
    final apiKey = await _apiKeyService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      state = state.copyWith(testResult: '请先设置API Key喵~', testSuccess: false);
      return;
    }
    state = state.copyWith(isLoadingModels: true, clearModels: true);
    try {
      final provider = createAiProvider(
        apiKey: apiKey, settings: AiSettings(baseUrl: state.baseUrl, model: state.model),
      );
      final models = await provider.fetchModels(baseUrl: state.baseUrl, apiKey: apiKey);
      models.sort((a, b) {
        final aChat = _isChatModel(a.id), bChat = _isChatModel(b.id);
        if (aChat && !bChat) return -1;
        if (!aChat && bChat) return 1;
        return a.id.compareTo(b.id);
      });
      state = state.copyWith(isLoadingModels: false, availableModels: models);
    } catch (_) {
      state = state.copyWith(isLoadingModels: false, testResult: '获取模型列表失败喵~', testSuccess: false);
    }
  }

  bool _isChatModel(String id) {
    final lower = id.toLowerCase();
    return lower.contains('gpt') || lower.contains('claude') || lower.contains('gemini') ||
        lower.contains('chat') || lower.contains('qwen') || lower.contains('deepseek') ||
        lower.contains('glm') || lower.contains('ernie') || lower.contains('yi-') || lower.contains('moonshot');
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsUiState>(
  (ref) {
    final db = ref.watch(databaseProvider);
    final apiKeyService = ref.watch(apiKeyServiceProvider);
    return SettingsNotifier(db, apiKeyService);
  },
);

final aiSettingsFromStateProvider = Provider<AiSettings>((ref) {
  final state = ref.watch(settingsProvider);
  return AiSettings(
    baseUrl: state.baseUrl, model: state.model,
    temperature: state.temperature, maxTokens: state.maxTokens,
    contextWindow: state.contextWindow,
    truncateStrategy: state.truncateStrategy, truncateLimit: state.truncateLimit,
    markdownRender: state.markdownRender,
    protocol: findPreset(state.providerPresetId).protocol,
  );
});
