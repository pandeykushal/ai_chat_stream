import 'package:flutter/material.dart';

import '../controller/chat_controller.dart';
import 'chat_builders.dart';
import 'chat_icons.dart';
import 'chat_input_bar.dart';
import 'chat_theme.dart';
import 'message_bubble.dart';
import 'message_list.dart';

/// A full-screen chat surface: a scrolling message list above a send/stop
/// input bar, wired to a [ChatController].
///
/// Drop it into a `Scaffold` body:
///
/// ```dart
/// Scaffold(
///   appBar: AppBar(title: const Text('Assistant')),
///   body: AiChatView(controller: controller),
/// )
/// ```
///
/// It follows the host [Theme] by default; pass [theme] to customise, or
/// [contentBuilder] to swap in your own message renderer.
class AiChatView extends StatelessWidget {
  /// Creates a full-screen chat view.
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

  /// The chat controller driving this view.
  final ChatController controller;

  /// Visual theme. Defaults to one derived from the ambient [Theme].
  final AiChatTheme? theme;

  /// Overridable glyphs (send / stop / copy / regenerate / scroll-to-bottom).
  final AiChatIcons icons;

  /// Whole-element builders (message / avatar / typing / input / send button).
  final AiChatBuilders builders;

  /// Optional custom renderer for message content.
  final MessageContentBuilder? contentBuilder;

  /// Widget shown when the conversation is empty.
  final Widget? emptyState;

  /// Placeholder text for the input field.
  final String inputHint;

  /// Padding around the message list.
  final EdgeInsets listPadding;

  /// Whether bubbles show copy / regenerate actions.
  final bool showActions;

  /// Whether input is enabled.
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
