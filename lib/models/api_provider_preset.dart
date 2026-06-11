/// Which API protocol format a provider uses.
///
/// GalChat needs to send differently-structured requests depending on
/// the protocol. OpenAI-compatible is the default / most common.
enum ApiProtocol {
  /// OpenAI Chat Completions API format.
  /// POST {baseUrl}/chat/completions | `Authorization: Bearer <key>`
  /// Used by: OpenAI, DeepSeek, MiMO, Duobao, Groq, Together, Ollama, etc.
  openAiCompatible,

  /// Anthropic Messages API format.
  /// POST {baseUrl}/messages | `x-api-key: <key>` | `anthropic-version: 2023-06-01`
  /// Key differences: system is top-level (not a message role), max_tokens
  /// is required, tool calls use content block format.
  anthropic,
}

/// A predefined API provider configuration for quick setup.
///
/// Each preset only provides the **protocol type** and **base URL**.
/// The user fills in model, context window, and max tokens manually
/// after selecting a preset.
class ApiProviderPreset {
  final String id;
  final String name;
  final ApiProtocol protocol;
  final String baseUrl;

  const ApiProviderPreset({
    required this.id,
    required this.name,
    required this.protocol,
    required this.baseUrl,
  });
}

/// All built-in provider presets.
///
/// Only base URL is pre-filled. Model / context window / max tokens
/// are left blank for the user to configure after API key is set up.
const builtInPresets = <ApiProviderPreset>[
  // 1. OpenAI 兼容
  ApiProviderPreset(
    id: 'openai',
    name: 'OpenAI 兼容',
    protocol: ApiProtocol.openAiCompatible,
    baseUrl: 'https://api.openai.com/v1',
  ),

  // 2. Anthropic 兼容
  // Native Messages API at api.anthropic.com.
  // Notes: auth via x-api-key header, not Bearer token;
  //        anthropic-version header required;
  //        system is a top-level field, not a message role;
  //        max_tokens is required in every request.
  ApiProviderPreset(
    id: 'anthropic',
    name: 'Anthropic 兼容',
    protocol: ApiProtocol.anthropic,
    baseUrl: 'https://api.anthropic.com',
  ),

  // 3. DeepSeek
  // OpenAI-compatible protocol with reasoning_content extension.
  ApiProviderPreset(
    id: 'deepseek',
    name: 'DeepSeek',
    protocol: ApiProtocol.openAiCompatible,
    baseUrl: 'https://api.deepseek.com/v1',
  ),
];

/// The "Custom" preset sentinel — user has manually configured everything.
const customPreset = ApiProviderPreset(
  id: 'custom',
  name: '自定义',
  protocol: ApiProtocol.openAiCompatible,
  baseUrl: '',
);

/// Find a preset by its [id], or return [customPreset] if not found.
ApiProviderPreset findPreset(String id) {
  for (final p in builtInPresets) {
    if (p.id == id) return p;
  }
  return customPreset;
}

/// Determine the best matching preset for current settings.
/// Returns [customPreset] if no preset matches exactly.
ApiProviderPreset detectPreset(String baseUrl) {
  for (final p in builtInPresets) {
    if (p.baseUrl == baseUrl) return p;
  }
  return customPreset;
}
