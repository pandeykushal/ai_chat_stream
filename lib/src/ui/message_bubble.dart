import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/message.dart';
import '../models/message_status.dart';
import 'chat_builders.dart';
import 'chat_icons.dart';
import 'chat_theme.dart';
import 'markdown_text.dart';
import 'typing_indicator.dart';

typedef MessageContentBuilder = Widget Function(
  BuildContext context,
  Message message,
  AiChatTheme theme,
);

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.theme,
    this.icons = const AiChatIcons(),
    this.builders = const AiChatBuilders(),
    this.onRegenerate,
    this.contentBuilder,
    this.showActions = true,
  });

  final Message message;

  final AiChatTheme theme;

  final AiChatIcons icons;

  final AiChatBuilders builders;

  final VoidCallback? onRegenerate;

  final MessageContentBuilder? contentBuilder;

  final bool showActions;

  bool get _isUser => message.isUser;

  @override
  Widget build(BuildContext context) {
    final defaultBubble = _buildRow(context);
    if (builders.message != null) {
      return builders.message!(context, message, theme, defaultBubble);
    }
    return defaultBubble;
  }

  Widget _buildRow(BuildContext context) {
    final avatarBuilder =
        _isUser ? builders.userAvatar : builders.assistantAvatar;
    final avatar = avatarBuilder?.call(context, message, theme);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth =
            constraints.maxWidth * theme.maxBubbleWidthFraction;
        final column = Flexible(
          child: Column(
            crossAxisAlignment:
                _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: _buildBubble(context),
              ),
              if (!_isUser && showActions && !message.status.isInProgress)
                _buildActions(context),
              if (theme.showTimestamps) _buildTimestamp(context),
            ],
          ),
        );

        return Row(
          mainAxisAlignment:
              _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (avatar != null && !_isUser) ...[avatar, const SizedBox(width: 8)],
            column,
            if (avatar != null && _isUser) ...[const SizedBox(width: 8), avatar],
          ],
        );
      },
    );
  }

  Widget _buildBubble(BuildContext context) {
    final bubbleColor =
        _isUser ? theme.userBubbleColor : theme.assistantBubbleColor;
    return Container(
      padding: _isUser ? theme.userBubblePadding : theme.assistantBubblePadding,
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: _isUser
            ? theme.effectiveUserBubbleRadius
            : theme.effectiveAssistantBubbleRadius,
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final baseStyle = theme.messageTextStyle(_isUser);

    if (message.content.isEmpty && message.status.isInProgress) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: builders.typingIndicator?.call(context, theme) ??
            TypingIndicator(color: theme.effectiveTypingIndicatorColor),
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
              linkColor: theme.effectiveLinkColor,
              codeFontFamily: theme.effectiveCodeFontFamily,
              codeRadius: theme.codeBlockRadius,
            ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        content,
        if (message.status == MessageStatus.streaming)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _BlinkingCursor(color: theme.effectiveLinkColor),
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

  Widget _buildActions(BuildContext context) {
    final isError = message.status.isError;
    return Padding(
      padding: const EdgeInsets.only(top: 2, left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.content.isNotEmpty)
            _ActionButton(
              tooltip: 'Copy',
              glyph: icons.copy ??
                  Icon(Icons.copy_rounded, size: 15, color: theme.mutedColor),
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
            _ActionButton(
              tooltip: isError ? 'Retry' : 'Regenerate',
              glyph: (isError ? (icons.retry ?? icons.regenerate) : icons.regenerate) ??
                  Icon(
                    isError ? Icons.refresh_rounded : Icons.autorenew_rounded,
                    size: 15,
                    color: isError ? theme.errorColor : theme.mutedColor,
                  ),
              onTap: onRegenerate!,
            ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    if (builders.timestamp != null) {
      return builders.timestamp!(context, message, theme);
    }
    final t = message.timestamp;
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
      child: Text(
        '$hh:$mm',
        style: theme.timestampStyle ??
            TextStyle(color: theme.mutedColor, fontSize: 10.5),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.tooltip,
    required this.glyph,
    required this.onTap,
  });

  final String tooltip;
  final Widget glyph;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: glyph,
      iconSize: 15,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
    );
  }
}

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
