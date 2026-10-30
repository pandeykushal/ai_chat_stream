import 'package:flutter/material.dart';

import '../controller/chat_controller.dart';
import 'chat_theme.dart';
import 'message_bubble.dart';

/// The scrolling list of message bubbles — the shared engine behind both
/// [AiChatView](AiChatView) and [AiChatBubble](AiChatBubble).
///
/// Handles sticky auto-scroll (follows the stream while you're at the bottom,
/// but leaves you alone when you've scrolled up) and a scroll-to-bottom button.
class ChatMessageList extends StatefulWidget {
  /// Creates a message list bound to [controller].
  const ChatMessageList({
    super.key,
    required this.controller,
    required this.theme,
    this.contentBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.emptyState,
    this.showActions = true,
  });

  /// The chat controller to render.
  final ChatController controller;

  /// Resolved visual theme.
  final AiChatTheme theme;

  /// Optional custom content renderer passed to each bubble.
  final MessageContentBuilder? contentBuilder;

  /// Padding around the list.
  final EdgeInsets padding;

  /// Shown (centered) when there are no messages yet.
  final Widget? emptyState;

  /// Whether bubbles show copy / regenerate actions.
  final bool showActions;

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scroll = ScrollController();
  bool _atBottom = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant ChatMessageList old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    widget.controller.removeListener(_onControllerChanged);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final atBottom =
        _scroll.position.maxScrollExtent - _scroll.offset < 80;
    if (atBottom != _atBottom) setState(() => _atBottom = atBottom);
  }

  void _onControllerChanged() {
    if (_atBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
    }
  }

  void _jumpToBottom() {
    if (!_scroll.hasClients) return;
    _scroll.jumpTo(_scroll.position.maxScrollExtent);
  }

  Future<void> _animateToBottom() async {
    if (!_scroll.hasClients) return;
    setState(() => _atBottom = true);
    await _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final messages = widget.controller.messages;
        if (messages.isEmpty && widget.emptyState != null) {
          return Center(child: widget.emptyState);
        }
        return Stack(
          children: [
            ListView.separated(
              controller: _scroll,
              padding: widget.padding,
              itemCount: messages.length,
              separatorBuilder: (_, __) =>
                  SizedBox(height: widget.theme.bubbleSpacing),
              itemBuilder: (context, index) {
                final message = messages[index];
                return MessageBubble(
                  key: ValueKey(message.id),
                  message: message,
                  theme: widget.theme,
                  contentBuilder: widget.contentBuilder,
                  showActions: widget.showActions,
                  onRegenerate: message.isAssistant
                      ? widget.controller.regenerate
                      : null,
                );
              },
            ),
            if (!_atBottom)
              Positioned(
                right: 12,
                bottom: 12,
                child: _ScrollToBottomButton(
                  theme: widget.theme,
                  onTap: _animateToBottom,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ScrollToBottomButton extends StatelessWidget {
  const _ScrollToBottomButton({required this.theme, required this.onTap});

  final AiChatTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.assistantBubbleColor,
      shape: const CircleBorder(),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.assistantTextColor,
            size: 22,
          ),
        ),
      ),
    );
  }
}
