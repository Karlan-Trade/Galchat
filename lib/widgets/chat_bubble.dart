import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

/// A chat bubble that shows a message from either the user or the AI character.
class ChatBubble extends StatelessWidget {
  final String content;
  final String? speaker;
  final bool isUser;
  final bool isError;
  final bool isStreaming;
  final bool markdownEnabled;

  const ChatBubble({
    super.key,
    required this.content,
    this.speaker,
    this.isUser = false,
    this.isError = false,
    this.isStreaming = false,
    this.markdownEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Color schemes
    final userBubbleColor = theme.colorScheme.primary;
    final aiBubbleColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;
    final errorBubbleColor = isDark ? Colors.red[900]! : Colors.red[50]!;

    final bubbleColor = isError
        ? errorBubbleColor
        : isUser
            ? userBubbleColor
            : aiBubbleColor;

    final textColor = isError
        ? (isDark ? Colors.red[200]! : Colors.red[800]!)
        : isUser
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for AI messages
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  speaker?.isNotEmpty == true ? speaker![0] : '？',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),

          // Bubble content
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Speaker name for AI messages
                  if (speaker != null && speaker!.isNotEmpty && !isUser)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        speaker!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  // Message content
                  if (markdownEnabled)
                    MarkdownBody(
                      data: content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                        p: TextStyle(fontSize: 15, color: textColor, height: 1.5),
                        h1: TextStyle(fontSize: 20, color: textColor, fontWeight: FontWeight.bold),
                        h2: TextStyle(fontSize: 18, color: textColor, fontWeight: FontWeight.bold),
                        h3: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.bold),
                        code: TextStyle(
                          fontSize: 13,
                          color: isUser ? Colors.white70 : theme.colorScheme.primary,
                          fontFamily: 'monospace',
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        blockquoteDecoration: BoxDecoration(
                          border: Border(left: BorderSide(color: theme.colorScheme.primary.withOpacity(0.4), width: 3)),
                        ),
                        listBullet: TextStyle(fontSize: 15, color: textColor),
                      ),
                      onTapLink: (text, href, title) {
                        if (href != null) launchUrl(Uri.parse(href));
                      },
                    )
                  else
                    SelectableText(
                      content,
                      style: TextStyle(
                        fontSize: 15,
                        color: textColor,
                        height: 1.5,
                      ),
                    ),
                  // Streaming blinking cursor
                  if (isStreaming)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: _StreamingIndicator(),
                    ),
                  // Error indicator
                  if (isError)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 14, color: textColor),
                          const SizedBox(width: 4),
                          Text(
                            '格式异常',
                            style: TextStyle(fontSize: 11, color: textColor),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Avatar for user messages
          if (isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primary,
                child: Icon(Icons.person, size: 16, color: theme.colorScheme.onPrimary),
              ),
            ),
        ],
      ),
    );
  }
}

/// Animated blinking cursor for streaming output.
class _StreamingIndicator extends StatefulWidget {
  const _StreamingIndicator();

  @override
  State<_StreamingIndicator> createState() => _StreamingIndicatorState();
}

class _StreamingIndicatorState extends State<_StreamingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 16,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
