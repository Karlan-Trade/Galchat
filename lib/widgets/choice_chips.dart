import 'package:flutter/material.dart';

/// A set of Galgame-style choice chips displayed below the latest AI message.
///
/// Each chip represents a choice the user can tap to continue the story.
class ChoiceChips extends StatelessWidget {
  /// The list of choice texts to display.
  final List<_ChoiceItem> choices;
  final void Function(int index) onTap;

  const ChoiceChips({
    super.key,
    required this.choices,
    required this.onTap,
  });

  /// Factory: create choice chips from a list of key+text maps.
  factory ChoiceChips.fromMaps(
    List<Map<String, String>> choiceMaps, {
    required void Function(int index) onTap,
  }) {
    return ChoiceChips(
      choices: choiceMaps
          .map((m) => _ChoiceItem(
                id: m['id'] ?? '',
                text: m['text'] ?? '',
              ))
          .toList(),
      onTap: onTap,
    );
  }

  static const _choiceLabels = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    if (choices.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '选择行动',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          // Choice chips
          ...List.generate(choices.length, (i) {
            final choice = choices[i];
            final label = i < _choiceLabels.length ? _choiceLabels[i] : '?';

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => onTap(i),
                  borderRadius: BorderRadius.circular(12),
                  splashColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Choice label (A, B, C, D)
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Choice text
                        Expanded(
                          child: Text(
                            choice.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                        // Arrow
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ChoiceItem {
  final String id;
  final String text;

  const _ChoiceItem({required this.id, required this.text});
}
