import 'package:flutter/widgets.dart';

@immutable
class AiChatIcons {
  const AiChatIcons({
    this.send,
    this.stop,
    this.launcher,
    this.avatar,
    this.copy,
    this.regenerate,
    this.retry,
    this.scrollToBottom,
    this.close,
    this.codeCopy,
  });

  final Widget? send;

  final Widget? stop;

  final Widget? launcher;

  final Widget? avatar;

  final Widget? copy;

  final Widget? regenerate;

  final Widget? retry;

  final Widget? scrollToBottom;

  final Widget? close;

  final Widget? codeCopy;

  AiChatIcons copyWith({
    Widget? send,
    Widget? stop,
    Widget? launcher,
    Widget? avatar,
    Widget? copy,
    Widget? regenerate,
    Widget? retry,
    Widget? scrollToBottom,
    Widget? close,
    Widget? codeCopy,
  }) {
    return AiChatIcons(
      send: send ?? this.send,
      stop: stop ?? this.stop,
      launcher: launcher ?? this.launcher,
      avatar: avatar ?? this.avatar,
      copy: copy ?? this.copy,
      regenerate: regenerate ?? this.regenerate,
      retry: retry ?? this.retry,
      scrollToBottom: scrollToBottom ?? this.scrollToBottom,
      close: close ?? this.close,
      codeCopy: codeCopy ?? this.codeCopy,
    );
  }
}
