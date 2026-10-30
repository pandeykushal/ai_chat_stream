import 'package:flutter/material.dart';

/// Visual styling for the chat UI.
///
/// By default it is derived from the host app's [ThemeData] (via
/// [AiChatTheme.fromTheme]), so the chat follows your light/dark theme with no
/// configuration. Override any field through the constructor or [copyWith] for
/// custom branding.
@immutable
class AiChatTheme {
  /// Creates a fully-specified theme. Prefer [AiChatTheme.fromTheme] and
  /// [copyWith] unless you want to set everything by hand.
  const AiChatTheme({
    required this.background,
    required this.userBubbleColor,
    required this.userTextColor,
    required this.assistantBubbleColor,
    required this.assistantTextColor,
    required this.codeBackground,
    required this.codeTextColor,
    required this.accentColor,
    required this.mutedColor,
    required this.errorColor,
    this.bubbleRadius = const BorderRadius.all(Radius.circular(18)),
    this.fontSize = 15,
    this.bubbleSpacing = 10,
    this.horizontalPadding = 12,
  });

  /// Background behind the message list.
  final Color background;

  /// Fill of the user's bubbles.
  final Color userBubbleColor;

  /// Text colour inside the user's bubbles.
  final Color userTextColor;

  /// Fill of the assistant's bubbles.
  final Color assistantBubbleColor;

  /// Text colour inside the assistant's bubbles.
  final Color assistantTextColor;

  /// Background of fenced code blocks and inline code.
  final Color codeBackground;

  /// Text colour of code.
  final Color codeTextColor;

  /// Accent used for the send button, links and the streaming cursor.
  final Color accentColor;

  /// Muted colour for timestamps, hints and the typing indicator.
  final Color mutedColor;

  /// Colour for error text and the retry affordance.
  final Color errorColor;

  /// Corner radius of message bubbles.
  final BorderRadius bubbleRadius;

  /// Base font size for message text.
  final double fontSize;

  /// Vertical gap between bubbles.
  final double bubbleSpacing;

  /// Horizontal padding around the message list.
  final double horizontalPadding;

  /// Derives a theme from the ambient [ThemeData], matching the host app.
  factory AiChatTheme.fromTheme(ThemeData theme) {
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return AiChatTheme(
      background: scheme.surface,
      userBubbleColor: scheme.primary,
      userTextColor: scheme.onPrimary,
      assistantBubbleColor: isDark
          ? scheme.surfaceContainerHighest
          : scheme.surfaceContainerHighest.withValues(alpha: 0.7),
      assistantTextColor: scheme.onSurface,
      codeBackground: isDark
          ? const Color(0xFF0D1117)
          : const Color(0xFF1E1E1E),
      codeTextColor: const Color(0xFFE6EDF3),
      accentColor: scheme.primary,
      mutedColor: scheme.onSurfaceVariant,
      errorColor: scheme.error,
    );
  }

  /// A light theme usable without a surrounding [Theme].
  factory AiChatTheme.light() =>
      AiChatTheme.fromTheme(ThemeData(brightness: Brightness.light));

  /// A dark theme usable without a surrounding [Theme].
  factory AiChatTheme.dark() =>
      AiChatTheme.fromTheme(ThemeData(brightness: Brightness.dark));

  /// Returns a copy with the given fields replaced.
  AiChatTheme copyWith({
    Color? background,
    Color? userBubbleColor,
    Color? userTextColor,
    Color? assistantBubbleColor,
    Color? assistantTextColor,
    Color? codeBackground,
    Color? codeTextColor,
    Color? accentColor,
    Color? mutedColor,
    Color? errorColor,
    BorderRadius? bubbleRadius,
    double? fontSize,
    double? bubbleSpacing,
    double? horizontalPadding,
  }) {
    return AiChatTheme(
      background: background ?? this.background,
      userBubbleColor: userBubbleColor ?? this.userBubbleColor,
      userTextColor: userTextColor ?? this.userTextColor,
      assistantBubbleColor: assistantBubbleColor ?? this.assistantBubbleColor,
      assistantTextColor: assistantTextColor ?? this.assistantTextColor,
      codeBackground: codeBackground ?? this.codeBackground,
      codeTextColor: codeTextColor ?? this.codeTextColor,
      accentColor: accentColor ?? this.accentColor,
      mutedColor: mutedColor ?? this.mutedColor,
      errorColor: errorColor ?? this.errorColor,
      bubbleRadius: bubbleRadius ?? this.bubbleRadius,
      fontSize: fontSize ?? this.fontSize,
      bubbleSpacing: bubbleSpacing ?? this.bubbleSpacing,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
    );
  }

  /// Resolves the effective theme: the explicit [override] if given, otherwise
  /// one derived from the ambient [Theme].
  static AiChatTheme resolve(BuildContext context, AiChatTheme? override) {
    return override ?? AiChatTheme.fromTheme(Theme.of(context));
  }
}
