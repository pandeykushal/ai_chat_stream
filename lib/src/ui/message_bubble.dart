import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/message.dart';
import '../models/message_status.dart';
import 'chat_theme.dart';
import 'markdown_text.dart';
import 'typing_indicator.dart';

/// Signature for overriding how a message's content is rendered.
typedef MessageContentBuilder = Widget Function(
  BuildContext context,
  Message message,
  AiChatTheme theme,
);

/// Renders a single [Message] as a chat bubble, with role-based alignment and
/// styling, Markdown for assistant replies, a typing indicator / streaming
/// cursor, inline error state, and copy / regenerate actions.
class MessageBubble extends StatelessWidget {
  /// Creates a bubble for [message].
  const MessageBubble({
    super.key,
    required this.message,
    required this.theme,
    this.onRegenerate,
    this.contentBuilder,
    this.showActions = true,
  });

  /// The message to render.
  final Message message;

  /// Resolved visual theme.
  final AiChatTheme theme;

  /// Called when the user taps **Regenerate** / **Retry** on this message.
  final VoidCallback? onRegenerate;

  /// Optional custom renderer for message content (e.g. a full Markdown pkg).
  final MessageContentBuilder? contentBuilder;

  /// Whether to show the copy / regenerate row under assistant messages.
  final bool showActions;

  bool get _isUser => message.isUser;

  @override
  Widget build(BuildContext context) {
    final align = _isUser ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor =
        _isUser ? theme.userBubbleColor : theme.assistantBubbleColor;
    final textColor =
        _isUser ? theme.userTextColor : theme.assistantTextColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth * 0.86;
        return Align(
          alignment: align,
          child: Column(
            crossAxisAlignment:
                _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: theme.bubbleRadius,
                  ),
                  child: _buildContent(context, textColor),
                ),
              ),
              if (!_isUser && showActions && !message.status.isInProgress)
                _ActionsRow(
                  message: message,
                  theme: theme,
                  onRegenerate: onRegenerate,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, Color textColor) {
    final baseStyle = TextStyle(
      color: textColor,
      fontSize: theme.fontSize,
      height: 1.4,
    );

    // Empty + in-progress → typing dots.
    if (message.content.isEmpty && message.status.isInProgress) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: TypingIndicator(color: theme.mutedColor),
      );
    }

    final content = _isUser
        ? Text(message.content, style: baseStyle)
        : (contentBuilder?.call(context, message, theme) ??
            AiChatMarkdown(
              data: message.content,
              style: baseStyle,
              codeBackground: theme.codeBackground,
              codeTextColor: theme.codeTextColor,
              linkColor: theme.accentColor,
            ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        content,
        if (message.status == MessageStatus.streaming)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _BlinkingCursor(color: theme.accentColor),
          ),
        if (message.status.isError) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 15, color: theme.errorColor),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  message.error ?? 'Something went wrong.',
                  style: TextStyle(color: theme.errorColor, fontSize: 12.5),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ActionsRow extends StatelessWidget {
  const _ActionsRow({
    required this.message,
    required this.theme,
    required this.onRegenerate,
  });

  final Message message;
  final AiChatTheme theme;
  final VoidCallback? onRegenerate;

  @override
  Widget build(BuildContext context) {
    final isError = message.status.isError;
    return Padding(
      padding: const EdgeInsets.only(top: 2, left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.content.isNotEmpty)
            _IconAction(
              icon: Icons.copy_rounded,
              tooltip: 'Copy',
              color: theme.mutedColor,
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: message.content));
                if (context.mounted) {
                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    const SnackBar(
                      content: Text('Copied'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
          if (onRegenerate != null)
            _IconAction(
              icon: isError ? Icons.refresh_rounded : Icons.autorenew_rounded,
              tooltip: isError ? 'Retry' : 'Regenerate',
              color: isError ? theme.errorColor : theme.mutedColor,
              onTap: onRegenerate!,
            ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon),
      iconSize: 15,
      color: color,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
    );
  }
}

/// A thin, blinking text cursor shown at the end of a streaming reply.
class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor({required this.color});
  final Color color;

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

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
        width: 7,
        height: 14,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
