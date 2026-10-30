import 'package:flutter/material.dart';

@immutable
class AiChatTheme {
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

  final Color background;

  final Color userBubbleColor;

  final Color userTextColor;

  final Color assistantBubbleColor;

  final Color assistantTextColor;

  final Color codeBackground;

  final Color codeTextColor;

  final Color accentColor;

  final Color mutedColor;

  final Color errorColor;

  final Color? headerColor;

  final Color? headerTextColor;

  final Color? linkColor;

  final Color? sendButtonColor;

  final Color? launcherColor;

  final Color? launcherIconColor;

  final Color? inputFillColor;

  final Color? typingIndicatorColor;

  final String? fontFamily;

  final String? codeFontFamily;

  final TextStyle? userTextStyle;

  final TextStyle? assistantTextStyle;

  final TextStyle? inputTextStyle;

  final TextStyle? hintStyle;

  final TextStyle? timestampStyle;

  final BorderRadius bubbleRadius;

  final BorderRadius? userBubbleRadius;

  final BorderRadius? assistantBubbleRadius;

  final EdgeInsets userBubblePadding;

  final EdgeInsets assistantBubblePadding;

  final EdgeInsets inputContentPadding;

  final BorderRadius inputRadius;

  final BorderRadius panelRadius;

  final BorderRadius codeBlockRadius;

  final double fontSize;

  final double bubbleSpacing;

  final double horizontalPadding;

  final double maxBubbleWidthFraction;

  final double sendButtonSize;

  final double launcherElevation;

  final double panelElevation;

  final bool showTimestamps;

  Color get effectiveHeaderColor => headerColor ?? accentColor;

  Color get effectiveHeaderTextColor => headerTextColor ?? userTextColor;

  Color get effectiveLinkColor => linkColor ?? accentColor;

  Color get effectiveSendButtonColor => sendButtonColor ?? accentColor;

  Color get effectiveLauncherColor => launcherColor ?? accentColor;

  Color get effectiveLauncherIconColor => launcherIconColor ?? userTextColor;

  Color get effectiveInputFillColor =>
      inputFillColor ?? assistantBubbleColor.withValues(alpha: 0.6);

  Color get effectiveTypingIndicatorColor =>
      typingIndicatorColor ?? mutedColor;

  String get effectiveCodeFontFamily => codeFontFamily ?? 'monospace';

  BorderRadius get effectiveUserBubbleRadius =>
      userBubbleRadius ?? bubbleRadius;

  BorderRadius get effectiveAssistantBubbleRadius =>
      assistantBubbleRadius ?? bubbleRadius;

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

  factory AiChatTheme.light() =>
      AiChatTheme.fromTheme(ThemeData(brightness: Brightness.light));

  factory AiChatTheme.dark() =>
      AiChatTheme.fromTheme(ThemeData(brightness: Brightness.dark));

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

  static AiChatTheme resolve(BuildContext context, AiChatTheme? override) {
    return override ?? AiChatTheme.fromTheme(Theme.of(context));
  }
}
