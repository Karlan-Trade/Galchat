/// Approximate token counting for context window estimation.
///
/// Uses a simplified heuristic (not the exact tiktoken algorithm):
/// - Chinese/Japanese/Korean chars: ~1.5 tokens each
/// - English words: ~1.3 tokens each
/// - Punctuation/whitespace: ~0.3 tokens each
///
/// This is accurate enough for a context-window progress bar
/// without requiring a huge tiktoken vocabulary file.
class TokenCounter {
  /// Estimate tokens in [text].
  static int estimate(String text) {
    if (text.isEmpty) return 0;

    int tokens = 0;
    final runes = text.runes.toList();
    int i = 0;

    while (i < runes.length) {
      final r = runes[i];

      if (_isCJK(r)) {
        // CJK characters: ~1.5 tokens each
        tokens += 2;
        i++;
      } else if (_isAsciiLetter(r)) {
        // Collect consecutive ASCII letters into a word
        final start = i;
        while (i < runes.length && _isAsciiLetter(runes[i])) {
          i++;
        }
        final wordLen = i - start;
        // ~1 token per 4 chars, at least 1
        tokens += (wordLen / 4).ceil().clamp(1, 999);
      } else if (r == 0x20 || r == 0x0A || r == 0x0D) {
        // Space/newline: collective ~0.3 tokens
        tokens += 1;
        i++;
      } else {
        // Other punctuation, emoji etc.
        tokens += 1;
        i++;
      }
    }

    return tokens;
  }

  /// Estimate tokens for a list of messages (system + history + user).
  static int estimateMessages(List<Map<String, String>> history, String systemPrompt) {
    int total = estimate(systemPrompt);
    for (final m in history) {
      total += estimate(m['content'] ?? '');
      total += 4; // role metadata overhead per message
    }
    return total;
  }

  /// Format a token count and limit into a human-readable string.
  static String formatUsage(int used, int limit) {
    final pct = limit > 0 ? (used * 100 ~/ limit).clamp(0, 100) : 0;
    return '$pct% (${_formatK(used)}/${_formatK(limit)})';
  }

  static String _formatK(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }

  static bool _isCJK(int r) {
    return (r >= 0x4E00 && r <= 0x9FFF) || // CJK Unified
        (r >= 0x3400 && r <= 0x4DBF) || // CJK Ext-A
        (r >= 0x3000 && r <= 0x303F) || // CJK Punctuation
        (r >= 0xFF00 && r <= 0xFFEF) || // Halfwidth/Fullwidth
        (r >= 0x3040 && r <= 0x309F) || // Hiragana
        (r >= 0x30A0 && r <= 0x30FF) || // Katakana
        (r >= 0xAC00 && r <= 0xD7AF);   // Hangul
  }

  static bool _isAsciiLetter(int r) {
    return (r >= 0x41 && r <= 0x5A) || (r >= 0x61 && r <= 0x7A);
  }
}
