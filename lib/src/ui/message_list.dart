import 'package:flutter/material.dart';

import '../controller/chat_controller.dart';
import 'chat_builders.dart';
import 'chat_icons.dart';
import 'chat_theme.dart';
import 'message_bubble.dart';

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({
    super.key,
    required this.controller,
    required this.theme,
    this.icons = const AiChatIcons(),
    this.builders = const AiChatBuilders(),
    this.contentBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.emptyState,
    this.showActions = true,
  });

  final ChatController controller;

  final AiChatTheme theme;

  final AiChatIcons icons;

  final AiChatBuilders builders;

  final MessageContentBuilder? contentBuilder;

  final EdgeInsets padding;

  final Widget? emptyState;

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
                  icons: widget.icons,
                  builders: widget.builders,
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
                child: widget.builders.scrollToBottom?.call(
                      context,
                      widget.theme,
                      _animateToBottom,
                    ) ??
                    _ScrollToBottomButton(
                      theme: widget.theme,
                      glyph: widget.icons.scrollToBottom,
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
  const _ScrollToBottomButton({
    required this.theme,
    required this.onTap,
    this.glyph,
  });

  final AiChatTheme theme;
  final VoidCallback onTap;
  final Widget? glyph;

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
          child: Center(
            child: glyph ??
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.assistantTextColor,
                  size: 22,
                ),
          ),
        ),
      ),
    );
  }
}
