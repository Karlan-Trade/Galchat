import 'package:flutter/material.dart';

/// Text input bar for the chat page.
///
/// Shows a text field with a send button that turns into a cancel/stop button
/// while the AI is generating a response.
class MessageInput extends StatefulWidget {
  final bool isLoading;
  final void Function(String text) onSend;
  final VoidCallback? onCancel;

  const MessageInput({
    super.key,
    required this.isLoading,
    required this.onSend,
    this.onCancel,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool get _canSend => _controller.text.trim().isNotEmpty && !widget.isLoading;

  void _handleSend() {
    final text = _controller.text.trim();
    if (!_canSend) return;

    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _handleSend(),
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: widget.isLoading ? '初雪正在思考喵...' : '输入消息...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    fontSize: 15,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  border: InputBorder.none,
                ),
                enabled: !widget.isLoading,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Send / Cancel button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: widget.isLoading
                ? _CancelButton(
                    theme: theme,
                    onTap: widget.onCancel,
                  )
                : _SendButton(
                    theme: theme,
                    enabled: _canSend,
                    onTap: _handleSend,
                  ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final ThemeData theme;
  final bool enabled;
  final VoidCallback onTap;

  const _SendButton({
    required this.theme,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.send_rounded,
          size: 20,
          color: enabled
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface.withOpacity(0.3),
        ),
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback? onTap;

  const _CancelButton({required this.theme, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.withOpacity(0.85),
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.stop_rounded,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }
}
