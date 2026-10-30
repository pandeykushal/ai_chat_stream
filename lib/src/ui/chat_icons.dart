import 'package:flutter/widgets.dart';

/// Swap in your own glyphs or logos. Each slot takes any widget (an `Icon`,
/// `Image.asset`, SVG, `CircleAvatar`, ...); null keeps the default.
@immutable
class AiChatIcons {
  /// Creates an icon set. All slots are optional.
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

  /// Send button glyph.
  final Widget? send;

  /// Stop button glyph (shown while streaming).
  final Widget? stop;

  /// Floating launcher logo.
  final Widget? launcher;

  /// Panel header / message avatar.
  final Widget? avatar;

  /// "Copy message" action.
  final Widget? copy;

  /// "Regenerate" action.
  final Widget? regenerate;

  /// "Retry" action on a failed message.
  final Widget? retry;

  /// Scroll-to-bottom button.
  final Widget? scrollToBottom;

  /// Panel header close button.
  final Widget? close;

  /// "Copy code" button on code blocks.
  final Widget? codeCopy;

  /// A copy with the given slots replaced.
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
