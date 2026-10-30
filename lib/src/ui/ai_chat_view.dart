import 'package:flutter/material.dart';

import '../controller/chat_controller.dart';
import 'chat_builders.dart';
import 'chat_icons.dart';
import 'chat_input_bar.dart';
import 'chat_theme.dart';
import 'message_bubble.dart';
import 'message_list.dart';

/// Full-screen chat: a scrolling message list above the input bar.
class AiChatView extends StatelessWidget {
  const AiChatView({
    super.key,
    required this.controller,
    this.theme,
    this.icons = const AiChatIcons(),
    this.builders = const AiChatBuilders(),
    this.contentBuilder,
    this.emptyState,
    this.inputHint = 'Message…',
    this.listPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.showActions = true,
    this.enabled = true,
  });

  final ChatController controller;

  final AiChatTheme? theme;

  final AiChatIcons icons;

  final AiChatBuilders builders;

  final MessageContentBuilder? contentBuilder;

  final Widget? emptyState;

  final String inputHint;

  final EdgeInsets listPadding;

  final bool showActions;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final resolved = AiChatTheme.resolve(context, theme);
    return Material(
      color: resolved.background,
      child: Column(
        children: [
          Expanded(
            child: ChatMessageList(
              controller: controller,
              theme: resolved,
              icons: icons,
              builders: builders,
              contentBuilder: contentBuilder,
              padding: listPadding,
              emptyState: emptyState,
              showActions: showActions,
            ),
          ),
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              if (builders.input != null) {
                return builders.input!(
                  context,
                  AiInputState(
                    theme: resolved,
                    isStreaming: controller.isStreaming,
                    enabled: enabled,
                    hintText: inputHint,
                    onSend: controller.send,
                    onStop: controller.stop,
                  ),
                );
              }
              return ChatInputBar(
                theme: resolved,
                isStreaming: controller.isStreaming,
                enabled: enabled,
                hintText: inputHint,
                onSend: controller.send,
                onStop: controller.stop,
                sendIcon: icons.send,
                stopIcon: icons.stop,
                sendButtonBuilder: builders.sendButton,
              );
            },
          ),
        ],
      ),
    );
  }
}
