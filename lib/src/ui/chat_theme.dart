import 'package:flutter/material.dart';

/// Visual styling for the chat UI.
///
/// Derived from the host app's [ThemeData] by default (via
/// [AiChatTheme.fromTheme]), so the chat follows your light/dark theme with no
/// configuration. Every token is overridable through the constructor or
/// [copyWith]. For replacing whole widgets (bubbles, input bar, header, …) see
/// `AiChatBuilders`; for swapping glyphs/logos see `AiChatIcons`.
@immutable
class AiChatTheme {
  /// Creates a theme. Only colours are required; everything else has a default.
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
    this.headerColor,
    this.headerTextColor,
    this.linkColor,
    this.sendButtonColor,
    this.launcherColor,
    this.launcherIconColor,
    this.inputFillColor,
    this.typingIndicatorColor,
    this.fontFamily,
    this.codeFontFamily,
    this.userTextStyle,
    this.assistantTextStyle,
    this.inputTextStyle,
    this.hintStyle,
    this.timestampStyle,
    this.bubbleRadius = const BorderRadius.all(Radius.circular(18)),
    this.userBubbleRadius,
    this.assistantBubbleRadius,
    this.userBubblePadding =
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.assistantBubblePadding =
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.inputContentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.inputRadius = const BorderRadius.all(Radius.circular(24)),
    this.panelRadius = const BorderRadius.all(Radius.circular(18)),
    this.codeBlockRadius = const BorderRadius.all(Radius.circular(10)),
    this.fontSize = 15,
    this.bubbleSpacing = 10,
    this.horizontalPadding = 12,
    this.maxBubbleWidthFraction = 0.86,
    this.sendButtonSize = 44,
    this.launcherElevation = 6,
    this.panelElevation = 12,
    this.showTimestamps = false,
  });

  // --- colours -------------------------------------------------------------

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

  /// Background of code blocks and inline code.
  final Color codeBackground;

  /// Text colour of code.
  final Color codeTextColor;

  /// Accent used for the send button, links and the launcher (unless the more
  /// specific tokens below are set).
  final Color accentColor;

  /// Muted colour for timestamps, hints and the typing indicator.
  final Color mutedColor;

  /// Colour for error text and the retry affordance.
  final Color errorColor;

  /// Background of the panel header. Defaults to [accentColor].
  final Color? headerColor;

  /// Text/icon colour in the panel header. Defaults to [userTextColor].
  final Color? headerTextColor;

  /// Colour for links. Defaults to [accentColor].
  final Color? linkColor;

  /// Fill of the send/stop button. Defaults to [accentColor].
  final Color? sendButtonColor;

  /// Fill of the floating launcher. Defaults to [accentColor].
  final Color? launcherColor;

  /// Icon colour on the launcher. Defaults to [userTextColor].
  final Color? launcherIconColor;

  /// Fill of the input text field. Defaults to a muted [assistantBubbleColor].
  final Color? inputFillColor;

  /// Colour of the typing indicator dots. Defaults to [mutedColor].
  final Color? typingIndicatorColor;

  // --- typography ----------------------------------------------------------

  /// Font family for message text (and the UI). Null uses the app default.
  final String? fontFamily;

  /// Font family for code. Defaults to `monospace`.
  final String? codeFontFamily;

  /// Extra style merged over user message text.
  final TextStyle? userTextStyle;

  /// Extra style merged over assistant message text.
  final TextStyle? assistantTextStyle;

  /// Style for the input field text.
  final TextStyle? inputTextStyle;

  /// Style for the input placeholder.
  final TextStyle? hintStyle;

  /// Style for message timestamps (when [showTimestamps] is true).
  final TextStyle? timestampStyle;

  // --- shape & spacing -----------------------------------------------------

  /// Default bubble corner radius (per-role overrides below take precedence).
  final BorderRadius bubbleRadius;

  /// Corner radius for user bubbles. Falls back to [bubbleRadius].
  final BorderRadius? userBubbleRadius;

  /// Corner radius for assistant bubbles. Falls back to [bubbleRadius].
  final BorderRadius? assistantBubbleRadius;

  /// Padding inside user bubbles.
  final EdgeInsets userBubblePadding;

  /// Padding inside assistant bubbles.
  final EdgeInsets assistantBubblePadding;

  /// Padding inside the input text field.
  final EdgeInsets inputContentPadding;

  /// Corner radius of the input field.
  final BorderRadius inputRadius;

  /// Corner radius of the floating panel.
  final BorderRadius panelRadius;

  /// Corner radius of fenced code blocks.
  final BorderRadius codeBlockRadius;

  /// Base font size for message text.
  final double fontSize;

  /// Vertical gap between bubbles.
  final double bubbleSpacing;

  /// Horizontal padding around the message list.
  final double horizontalPadding;

  /// Max bubble width as a fraction of the available width (0–1).
  final double maxBubbleWidthFraction;

  /// Diameter of the send/stop button.
  final double sendButtonSize;

  /// Elevation of the floating launcher.
  final double launcherElevation;

  /// Elevation of the floating panel.
  final double panelElevation;

  /// Whether to show a timestamp under each message.
  final bool showTimestamps;

  // --- effective (resolved) tokens -----------------------------------------

  /// Header background ([headerColor] or [accentColor]).
  Color get effectiveHeaderColor => headerColor ?? accentColor;

  /// Header foreground ([headerTextColor] or [userTextColor]).
  Color get effectiveHeaderTextColor => headerTextColor ?? userTextColor;

  /// Link colour ([linkColor] or [accentColor]).
  Color get effectiveLinkColor => linkColor ?? accentColor;

  /// Send button colour ([sendButtonColor] or [accentColor]).
  Color get effectiveSendButtonColor => sendButtonColor ?? accentColor;

  /// Launcher colour ([launcherColor] or [accentColor]).
  Color get effectiveLauncherColor => launcherColor ?? accentColor;

  /// Launcher icon colour ([launcherIconColor] or [userTextColor]).
  Color get effectiveLauncherIconColor => launcherIconColor ?? userTextColor;

  /// Input fill ([inputFillColor] or a muted assistant bubble colour).
  Color get effectiveInputFillColor =>
      inputFillColor ?? assistantBubbleColor.withValues(alpha: 0.6);

  /// Typing indicator colour ([typingIndicatorColor] or [mutedColor]).
  Color get effectiveTypingIndicatorColor =>
      typingIndicatorColor ?? mutedColor;

  /// Code font family ([codeFontFamily] or `monospace`).
  String get effectiveCodeFontFamily => codeFontFamily ?? 'monospace';

  /// User bubble radius ([userBubbleRadius] or [bubbleRadius]).
  BorderRadius get effectiveUserBubbleRadius =>
      userBubbleRadius ?? bubbleRadius;

  /// Assistant bubble radius ([assistantBubbleRadius] or [bubbleRadius]).
  BorderRadius get effectiveAssistantBubbleRadius =>
      assistantBubbleRadius ?? bubbleRadius;

  /// The resolved text style for a message by [isUser].
  TextStyle messageTextStyle(bool isUser) {
    final base = TextStyle(
      color: isUser ? userTextColor : assistantTextColor,
      fontSize: fontSize,
      height: 1.4,
      fontFamily: fontFamily,
    );
    final extra = isUser ? userTextStyle : assistantTextStyle;
    return extra == null ? base : base.merge(extra);
  }

  // --- factories -----------------------------------------------------------

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
      codeBackground:
          isDark ? const Color(0xFF0D1117) : const Color(0xFF1E1E1E),
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
    Color? headerColor,
    Color? headerTextColor,
    Color? linkColor,
    Color? sendButtonColor,
    Color? launcherColor,
    Color? launcherIconColor,
    Color? inputFillColor,
    Color? typingIndicatorColor,
    String? fontFamily,
    String? codeFontFamily,
    TextStyle? userTextStyle,
    TextStyle? assistantTextStyle,
    TextStyle? inputTextStyle,
    TextStyle? hintStyle,
    TextStyle? timestampStyle,
    BorderRadius? bubbleRadius,
    BorderRadius? userBubbleRadius,
    BorderRadius? assistantBubbleRadius,
    EdgeInsets? userBubblePadding,
    EdgeInsets? assistantBubblePadding,
    EdgeInsets? inputContentPadding,
    BorderRadius? inputRadius,
    BorderRadius? panelRadius,
    BorderRadius? codeBlockRadius,
    double? fontSize,
    double? bubbleSpacing,
    double? horizontalPadding,
    double? maxBubbleWidthFraction,
    double? sendButtonSize,
    double? launcherElevation,
    double? panelElevation,
    bool? showTimestamps,
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
      headerColor: headerColor ?? this.headerColor,
      headerTextColor: headerTextColor ?? this.headerTextColor,
      linkColor: linkColor ?? this.linkColor,
      sendButtonColor: sendButtonColor ?? this.sendButtonColor,
      launcherColor: launcherColor ?? this.launcherColor,
      launcherIconColor: launcherIconColor ?? this.launcherIconColor,
      inputFillColor: inputFillColor ?? this.inputFillColor,
      typingIndicatorColor: typingIndicatorColor ?? this.typingIndicatorColor,
      fontFamily: fontFamily ?? this.fontFamily,
      codeFontFamily: codeFontFamily ?? this.codeFontFamily,
      userTextStyle: userTextStyle ?? this.userTextStyle,
      assistantTextStyle: assistantTextStyle ?? this.assistantTextStyle,
      inputTextStyle: inputTextStyle ?? this.inputTextStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      timestampStyle: timestampStyle ?? this.timestampStyle,
      bubbleRadius: bubbleRadius ?? this.bubbleRadius,
      userBubbleRadius: userBubbleRadius ?? this.userBubbleRadius,
      assistantBubbleRadius:
          assistantBubbleRadius ?? this.assistantBubbleRadius,
      userBubblePadding: userBubblePadding ?? this.userBubblePadding,
      assistantBubblePadding:
          assistantBubblePadding ?? this.assistantBubblePadding,
      inputContentPadding: inputContentPadding ?? this.inputContentPadding,
      inputRadius: inputRadius ?? this.inputRadius,
      panelRadius: panelRadius ?? this.panelRadius,
      codeBlockRadius: codeBlockRadius ?? this.codeBlockRadius,
      fontSize: fontSize ?? this.fontSize,
      bubbleSpacing: bubbleSpacing ?? this.bubbleSpacing,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      maxBubbleWidthFraction:
          maxBubbleWidthFraction ?? this.maxBubbleWidthFraction,
      sendButtonSize: sendButtonSize ?? this.sendButtonSize,
      launcherElevation: launcherElevation ?? this.launcherElevation,
      panelElevation: panelElevation ?? this.panelElevation,
      showTimestamps: showTimestamps ?? this.showTimestamps,
    );
  }

  /// Resolves the effective theme: [override] if given, else one derived from
  /// the ambient [Theme].
  static AiChatTheme resolve(BuildContext context, AiChatTheme? override) {
    return override ?? AiChatTheme.fromTheme(Theme.of(context));
  }
}
