import 'package:flutter/widgets.dart';

import '../models/message.dart';
import 'chat_theme.dart';

/// Replaces a whole message bubble. [defaultBubble] is the stock rendering, so
/// you can wrap it instead of starting over.
typedef AiMessageBuilder = Widget Function(
  BuildContext context,
  Message message,
  AiChatTheme theme,
  Widget defaultBubble,
);

/// Builds the avatar next to a message. Return null for none.
typedef AiAvatarBuilder = Widget? Function(
  BuildContext context,
  Message message,
  AiChatTheme theme,
);

/// Builds the "assistant is typing" indicator.
typedef AiTypingBuilder = Widget Function(
  BuildContext context,
  AiChatTheme theme,
);

/// Builds a message timestamp line.
typedef AiTimestampBuilder = Widget Function(
  BuildContext context,
  Message message,
  AiChatTheme theme,
);

/// Builds the whole input bar. Call [AiInputState.onSend] with the text.
typedef AiInputBuilder = Widget Function(
  BuildContext context,
  AiInputState state,
);

/// Builds just the send/stop button.
typedef AiSendButtonBuilder = Widget Function(
  BuildContext context,
  AiSendButtonState state,
);

/// Builds the floating panel header. Call [onClose] to collapse it.
typedef AiHeaderBuilder = Widget Function(
  BuildContext context,
  AiChatTheme theme,
  VoidCallback onClose,
);

/// Builds the floating launcher. Call [onTap] to toggle the panel.
typedef AiLauncherBuilder = Widget Function(
  BuildContext context,
  AiChatTheme theme,
  int unread,
  VoidCallback onTap,
);

/// Builds the scroll-to-bottom button. Call [onTap] to jump to the latest.
typedef AiScrollToBottomBuilder = Widget Function(
  BuildContext context,
  AiChatTheme theme,
  VoidCallback onTap,
);

/// Passed to a custom [AiInputBuilder].
@immutable
class AiInputState {
  /// Creates the input state.
  const AiInputState({
    required this.theme,
    required this.isStreaming,
    required this.enabled,
    required this.hintText,
    required this.onSend,
    required this.onStop,
  });

  /// Resolved theme.
  final AiChatTheme theme;

  /// Whether a reply is streaming.
  final bool isStreaming;

  /// Whether input is enabled.
  final bool enabled;

  /// Placeholder text.
  final String hintText;

  /// Send the given text.
  final ValueChanged<String> onSend;

  /// Stop the in-flight reply.
  final VoidCallback onStop;
}

/// Passed to a custom [AiSendButtonBuilder].
@immutable
class AiSendButtonState {
  /// Creates the send-button state.
  const AiSendButtonState({
    required this.theme,
    required this.isStreaming,
    required this.enabled,
    required this.onSend,
    required this.onStop,
  });

  /// Resolved theme.
  final AiChatTheme theme;

  /// Whether a reply is streaming (show a stop glyph).
  final bool isStreaming;

  /// Whether the button is enabled.
  final bool enabled;

  /// Send the current field text.
  final VoidCallback onSend;

  /// Stop the in-flight reply.
  final VoidCallback onStop;
}

/// Replace whole widgets when the theme and icons aren't enough. Anything left
/// null uses the default.
@immutable
class AiChatBuilders {
  /// Creates a builder set. All slots are optional.
  const AiChatBuilders({
    this.message,
    this.userAvatar,
    this.assistantAvatar,
    this.typingIndicator,
    this.timestamp,
    this.input,
    this.sendButton,
    this.header,
    this.launcher,
    this.scrollToBottom,
  });

  /// The whole message bubble.
  final AiMessageBuilder? message;

  /// Avatar next to user messages.
  final AiAvatarBuilder? userAvatar;

  /// Avatar next to assistant messages.
  final AiAvatarBuilder? assistantAvatar;

  /// The typing indicator.
  final AiTypingBuilder? typingIndicator;

  /// The per-message timestamp (when `AiChatTheme.showTimestamps`).
  final AiTimestampBuilder? timestamp;

  /// The whole input bar.
  final AiInputBuilder? input;

  /// Just the send/stop button.
  final AiSendButtonBuilder? sendButton;

  /// The floating panel header.
  final AiHeaderBuilder? header;

  /// The floating launcher.
  final AiLauncherBuilder? launcher;

  /// The scroll-to-bottom button.
  final AiScrollToBottomBuilder? scrollToBottom;
}
