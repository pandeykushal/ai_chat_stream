import 'package:flutter/material.dart';

import 'chat_builders.dart';
import 'chat_theme.dart';

/// The bottom input row: a multi-line text field and a button that toggles
/// between **Send** and **Stop** depending on streaming state.
///
/// Styled entirely from [AiChatTheme] (fill, radius, text/hint styles, padding,
/// button colour & size). Pass [sendIcon] / [stopIcon] to swap glyphs, or
/// [sendButtonBuilder] to replace the button. To replace the whole bar, use
/// `AiChatBuilders.input` on `AiChatView` / `AiChatBubble`.
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
    this.sendIcon,
    this.stopIcon,
    this.sendButtonBuilder,
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

  /// Custom glyph for the send button (default: an upward arrow).
  final Widget? sendIcon;

  /// Custom glyph for the stop button (default: a stop square).
  final Widget? stopIcon;

  /// Optional builder to replace the send/stop button entirely.
  final AiSendButtonBuilder? sendButtonBuilder;

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
    final enabled = widget.isStreaming || (_hasText && widget.enabled);

    final Widget button = widget.sendButtonBuilder != null
        ? widget.sendButtonBuilder!(
            context,
            AiSendButtonState(
              theme: theme,
              isStreaming: widget.isStreaming,
              enabled: enabled,
              onSend: _send,
              onStop: widget.onStop,
            ),
          )
        : _SendStopButton(
            theme: theme,
            isStreaming: widget.isStreaming,
            enabled: enabled,
            onSend: _send,
            onStop: widget.onStop,
            sendIcon: widget.sendIcon,
            stopIcon: widget.stopIcon,
          );

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
                style: (TextStyle(
                  color: theme.assistantTextColor,
                  fontSize: theme.fontSize,
                  fontFamily: theme.fontFamily,
                )).merge(theme.inputTextStyle),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: theme.hintStyle ??
                      TextStyle(color: theme.mutedColor),
                  filled: true,
                  fillColor: theme.effectiveInputFillColor,
                  isDense: true,
                  contentPadding: theme.inputContentPadding,
                  border: OutlineInputBorder(
                    borderRadius: theme.inputRadius,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            button,
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
    this.sendIcon,
    this.stopIcon,
  });

  final AiChatTheme theme;
  final bool isStreaming;
  final bool enabled;
  final VoidCallback onSend;
  final VoidCallback onStop;
  final Widget? sendIcon;
  final Widget? stopIcon;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? theme.effectiveSendButtonColor
        : theme.mutedColor.withValues(alpha: 0.4);
    final glyph = isStreaming
        ? (stopIcon ??
            Icon(Icons.stop_rounded, color: theme.userTextColor, size: 22))
        : (sendIcon ??
            Icon(Icons.arrow_upward_rounded,
                color: theme.userTextColor, size: 22));
    return Material(
      color: color,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? (isStreaming ? onStop : onSend) : null,
        child: SizedBox(
          width: theme.sendButtonSize,
          height: theme.sendButtonSize,
          child: Center(child: glyph),
        ),
      ),
    );
  }
}
