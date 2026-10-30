import 'package:flutter/widgets.dart';

import '../models/message.dart';
import 'chat_theme.dart';

/// Replaces a whole message bubble. [defaultBubble] is the package's rendering,
/// so you can wrap it (add a timestamp, a tail, a reaction bar) instead of
/// rebuilding from scratch.
typedef AiMessageBuilder = Widget Function(
  BuildContext context,
  Message message,
  AiChatTheme theme,
  Widget defaultBubble,
);

/// Builds the avatar shown next to a message. Return null for no avatar.
typedef AiAvatarBuilder = Widget? Function(
  BuildContext context,
  Message message,
  AiChatTheme theme,
);

/// Builds the "assistant is typing" indicator (shown before the first token).
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

/// Builds the entire input bar. Call [AiInputState.onSend] with the text.
typedef AiInputBuilder = Widget Function(
  BuildContext context,
  AiInputState state,
);

/// Builds just the send/stop button inside the default input bar.
typedef AiSendButtonBuilder = Widget Function(
  BuildContext context,
  AiSendButtonState state,
);

/// Builds the floating panel header. Call [onClose] to collapse the panel.
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

/// State handed to a custom [AiInputBuilder].
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

  /// Whether a reply is currently streaming.
  final bool isStreaming;

  /// Whether input is enabled.
  final bool enabled;

  /// Placeholder text.
  final String hintText;

  /// Call with the message text to send it.
  final ValueChanged<String> onSend;

  /// Call to stop the in-flight reply.
  final VoidCallback onStop;
}

/// State handed to a custom [AiSendButtonBuilder].
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

  /// Whether a reply is currently streaming (show a stop glyph).
  final bool isStreaming;

  /// Whether the button is enabled.
  final bool enabled;

  /// Call to send the current field text.
  final VoidCallback onSend;

  /// Call to stop the in-flight reply.
  final VoidCallback onStop;
}

/// A bundle of optional builders that replace whole UI elements.
///
/// Anything left null uses the package's default widget. For colours, fonts and
/// sizes prefer `AiChatTheme`; for glyphs/logos prefer `AiChatIcons`. Reach for
/// a builder only when you want to replace an element wholesale.
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

  /// Replace a whole message bubble.
  final AiMessageBuilder? message;

  /// Avatar beside user messages.
  final AiAvatarBuilder? userAvatar;

  /// Avatar beside assistant messages.
  final AiAvatarBuilder? assistantAvatar;

  /// The typing indicator.
  final AiTypingBuilder? typingIndicator;

  /// The per-message timestamp line (used when `AiChatTheme.showTimestamps`).
  final AiTimestampBuilder? timestamp;

  /// The entire input bar.
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
