import 'ai_provider.dart';
import '../models/api_provider_preset.dart';
import 'openai_compatible_provider.dart';
import 'anthropic_provider.dart';

/// Create the correct [AiProvider] implementation for the configured protocol.
AiProvider createAiProvider({
  required String apiKey,
  required AiSettings settings,
}) {
  if (settings.protocol == ApiProtocol.anthropic) {
    return AnthropicProvider(apiKey: apiKey, settings: settings);
  }
  return OpenAiCompatibleProvider(apiKey: apiKey, settings: settings);
}
