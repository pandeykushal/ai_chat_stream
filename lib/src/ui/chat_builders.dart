import 'package:flutter/widgets.dart';

import '../models/message.dart';
import 'chat_theme.dart';

typedef AiMessageBuilder = Widget Function(
  BuildContext context,
  Message message,
  AiChatTheme theme,
  Widget defaultBubble,
);

typedef AiAvatarBuilder = Widget? Function(
  BuildContext context,
  Message message,
  AiChatTheme theme,
);

typedef AiTypingBuilder = Widget Function(
  BuildContext context,
  AiChatTheme theme,
);

typedef AiTimestampBuilder = Widget Function(
  BuildContext context,
  Message message,
  AiChatTheme theme,
);

typedef AiInputBuilder = Widget Function(
  BuildContext context,
  AiInputState state,
);

typedef AiSendButtonBuilder = Widget Function(
  BuildContext context,
  AiSendButtonState state,
);

typedef AiHeaderBuilder = Widget Function(
  BuildContext context,
  AiChatTheme theme,
  VoidCallback onClose,
);

typedef AiLauncherBuilder = Widget Function(
  BuildContext context,
  AiChatTheme theme,
  int unread,
  VoidCallback onTap,
);

typedef AiScrollToBottomBuilder = Widget Function(
  BuildContext context,
  AiChatTheme theme,
  VoidCallback onTap,
);

@immutable
class AiInputState {
  const AiInputState({
    required this.theme,
    required this.isStreaming,
    required this.enabled,
    required this.hintText,
    required this.onSend,
    required this.onStop,
  });

  final AiChatTheme theme;

  final bool isStreaming;

  final bool enabled;

  final String hintText;

  final ValueChanged<String> onSend;

  final VoidCallback onStop;
}

@immutable
class AiSendButtonState {
  const AiSendButtonState({
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
}

@immutable
class AiChatBuilders {
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

  final AiMessageBuilder? message;

  final AiAvatarBuilder? userAvatar;

  final AiAvatarBuilder? assistantAvatar;

  final AiTypingBuilder? typingIndicator;

  final AiTimestampBuilder? timestamp;

  final AiInputBuilder? input;

  final AiSendButtonBuilder? sendButton;

  final AiHeaderBuilder? header;

  final AiLauncherBuilder? launcher;

  final AiScrollToBottomBuilder? scrollToBottom;
}
