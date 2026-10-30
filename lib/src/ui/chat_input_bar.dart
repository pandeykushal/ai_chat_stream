import 'package:flutter/material.dart';

import 'chat_theme.dart';

/// The bottom input row: a multi-line text field and a button that toggles
/// between **Send** and **Stop** depending on streaming state.
class ChatInputBar extends StatefulWidget {
  /// Creates an input bar.
  const ChatInputBar({
    super.key,
    required this.theme,
    required this.isStreaming,
    required this.onSend,
    required this.onStop,
    this.enabled = true,
    this.hintText = 'Message…',
  });

  /// Resolved visual theme.
  final AiChatTheme theme;

  /// Whether a response is currently streaming (button shows **Stop**).
  final bool isStreaming;

  /// Called with the trimmed text when the user sends a message.
  final ValueChanged<String> onSend;

  /// Called when the user taps **Stop** mid-stream.
  final VoidCallback onStop;

  /// Whether the field accepts input.
  final bool enabled;

  /// Placeholder shown when the field is empty.
  final String hintText;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final fieldFill = theme.assistantBubbleColor.withValues(alpha: 0.6);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                style: TextStyle(color: theme.assistantTextColor, fontSize: theme.fontSize),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: theme.mutedColor),
                  filled: true,
                  fillColor: fieldFill,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _SendStopButton(
              theme: theme,
              isStreaming: widget.isStreaming,
              enabled: widget.isStreaming || (_hasText && widget.enabled),
              onSend: _send,
              onStop: widget.onStop,
            ),
          ],
        ),
      ),
    );
  }
}

class _SendStopButton extends StatelessWidget {
  const _SendStopButton({
    required this.theme,
    required this.isStreaming,
    required this.enabled,
    required this.onSend,
    required this.onStop,
  });

  final AiChatTheme theme;
  final bool isStreaming;
  final bool enabled;
  final VoidCallback onSend;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final color =
        enabled ? theme.accentColor : theme.mutedColor.withValues(alpha: 0.4);
    return Material(
      color: color,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? (isStreaming ? onStop : onSend) : null,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            isStreaming ? Icons.stop_rounded : Icons.arrow_upward_rounded,
            color: theme.userTextColor,
            size: 22,
          ),
        ),
      ),
    );
  }
}
