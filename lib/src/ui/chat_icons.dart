import 'package:flutter/widgets.dart';

/// Overridable logos and glyphs for the chat UI.
///
/// Every slot is optional — leave it null to keep the Material default. Pass
/// any widget, so a brand logo can be an `Image.asset`, an `SvgPicture`, a
/// `CircleAvatar`, or a plain `Icon`.
///
/// ```dart
/// AiChatBubble(
///   controller: controller,
///   icons: AiChatIcons(
///     launcher: Image.asset('assets/logo.png'),
///     avatar: const CircleAvatar(backgroundImage: AssetImage('assets/logo.png')),
///     send: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
///   ),
/// );
/// ```
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

  /// Glyph inside the send button (default: an upward arrow).
  final Widget? send;

  /// Glyph inside the button while a reply streams (default: a stop square).
  final Widget? stop;

  /// Logo/icon on the floating launcher bubble (default: a chat glyph).
  final Widget? launcher;

  /// Logo/avatar in the chat panel header (default: a bot glyph in a circle).
  final Widget? avatar;

  /// Glyph for the "copy message" action (default: a copy icon).
  final Widget? copy;

  /// Glyph for the "regenerate" action (default: a refresh icon).
  final Widget? regenerate;

  /// Glyph for the "retry" action on a failed message (default: a refresh icon).
  final Widget? retry;

  /// Glyph for the scroll-to-bottom button (default: a chevron-down icon).
  final Widget? scrollToBottom;

  /// Glyph for the panel header close button (default: an X icon).
  final Widget? close;

  /// Glyph for the "copy code" button on fenced code blocks (default: a copy
  /// icon).
  final Widget? codeCopy;

  /// Returns a copy with the given slots replaced.
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
