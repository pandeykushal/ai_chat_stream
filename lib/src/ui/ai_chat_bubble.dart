import 'package:flutter/material.dart';

import '../controller/chat_controller.dart';
import 'chat_builders.dart';
import 'chat_icons.dart';
import 'chat_input_bar.dart';
import 'chat_theme.dart';
import 'message_bubble.dart';
import 'message_list.dart';

/// Floating launcher that opens into a chat panel over any screen.
/// Mount it above your routes, e.g. in MaterialApp.builder.
class AiChatBubble extends StatefulWidget {
  const AiChatBubble({
    super.key,
    required this.controller,
    this.theme,
    this.icons = const AiChatIcons(),
    this.builders = const AiChatBuilders(),
    this.contentBuilder,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.all(16),
    this.bubbleSize = 56,
    this.panelSize = const Size(360, 520),
    this.title = 'Assistant',
    this.subtitle,
    this.inputHint = 'Message…',
    this.draggable = false,
    this.showUnreadBadge = true,
    this.emptyState,
    this.onOpen,
    this.onClose,
  });

  final ChatController controller;

  final AiChatTheme? theme;

  final AiChatIcons icons;

  final AiChatBuilders builders;

  final MessageContentBuilder? contentBuilder;

  final Alignment alignment;

  final EdgeInsets margin;

  final double bubbleSize;

  final Size panelSize;

  final String title;

  final String? subtitle;

  final String inputHint;

  final bool draggable;

  final bool showUnreadBadge;

  final Widget? emptyState;

  final VoidCallback? onOpen;

  final VoidCallback? onClose;

  @override
  State<AiChatBubble> createState() => _AiChatBubbleState();
}

class _AiChatBubbleState extends State<AiChatBubble> {
  late final OverlayEntry _entry =
      OverlayEntry(builder: (context) => _BubbleBody(host: widget));

  @override
  void didUpdateWidget(covariant AiChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entry.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    // Own Overlay so tooltips etc. work even when we're mounted next to the
    // app's Navigator instead of under it.
    return Overlay(initialEntries: [_entry]);
  }
}

class _BubbleBody extends StatefulWidget {
  const _BubbleBody({required this.host});

  final AiChatBubble host;

  @override
  State<_BubbleBody> createState() => _BubbleBodyState();
}

class _BubbleBodyState extends State<_BubbleBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  bool _open = false;
  int _seenCount = 0;
  int _unread = 0;
  Offset? _dragTopLeft;

  @override
  void initState() {
    super.initState();
    _seenCount = widget.host.controller.messages.length;
    widget.host.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.host.controller.removeListener(_onControllerChanged);
    _anim.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_open) return;
    final messages = widget.host.controller.messages;
    var count = 0;
    for (var i = _seenCount; i < messages.length; i++) {
      if (messages[i].isAssistant && messages[i].content.isNotEmpty) count++;
    }
    if (count != _unread) setState(() => _unread = count);
  }

  void _toggle() => _open ? _close() : _openPanel();

  void _openPanel() {
    setState(() {
      _open = true;
      _seenCount = widget.host.controller.messages.length;
      _unread = 0;
    });
    _anim.forward();
    widget.host.onOpen?.call();
  }

  void _close() {
    setState(() => _open = false);
    _seenCount = widget.host.controller.messages.length;
    _anim.reverse();
    FocusManager.instance.primaryFocus?.unfocus();
    widget.host.onClose?.call();
  }

  bool get _isRight => widget.host.alignment.x > 0;
  bool get _isBottom => widget.host.alignment.y > 0;

  @override
  Widget build(BuildContext context) {
    final theme = AiChatTheme.resolve(context, widget.host.theme);
    final media = MediaQuery.of(context);
    final safe = media.padding;
    final insets = media.viewInsets;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return AnimatedBuilder(
          animation: _anim,
          builder: (context, _) {
            final t = Curves.easeOutCubic.transform(_anim.value);
            return Stack(
              children: [
                if (t > 0)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _close,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.28 * t),
                      ),
                    ),
                  ),
                if (t > 0) _buildPanel(context, theme, w, h, safe, insets, t),
                _buildLauncher(context, theme, w, h, safe, t),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLauncher(
    BuildContext context,
    AiChatTheme theme,
    double w,
    double h,
    EdgeInsets safe,
    double t,
  ) {
    final size = widget.host.bubbleSize;
    final left = _dragTopLeft?.dx ??
        (_isRight
            ? w - size - widget.host.margin.right
            : widget.host.margin.left + safe.left);
    final top = _dragTopLeft?.dy ??
        (_isBottom
            ? h - size - widget.host.margin.bottom - safe.bottom
            : widget.host.margin.top + safe.top);

    final unread = widget.host.showUnreadBadge ? _unread : 0;
    final launcher = Opacity(
      opacity: (1 - t).clamp(0.0, 1.0).toDouble(),
      child: Transform.scale(
        scale: 1 - 0.25 * t,
        child: widget.host.builders.launcher
                ?.call(context, theme, unread, _toggle) ??
            _LauncherButton(
              theme: theme,
              size: size,
              icon: widget.host.icons.launcher,
              unread: unread,
              onTap: _toggle,
            ),
      ),
    );

    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        ignoring: t > 0.5,
        child: widget.host.draggable
            ? GestureDetector(
                onPanUpdate: (d) {
                  setState(() {
                    final nx = (left + d.delta.dx)
                        .clamp(widget.host.margin.left,
                            w - size - widget.host.margin.right)
                        .toDouble();
                    final ny = (top + d.delta.dy)
                        .clamp(
                          widget.host.margin.top + safe.top,
                          h - size - widget.host.margin.bottom - safe.bottom,
                        )
                        .toDouble();
                    _dragTopLeft = Offset(nx, ny);
                  });
                },
                child: launcher,
              )
            : launcher,
      ),
    );
  }

  Widget _buildPanel(
    BuildContext context,
    AiChatTheme theme,
    double w,
    double h,
    EdgeInsets safe,
    EdgeInsets insets,
    double t,
  ) {
    final panelW = widget.host.panelSize.width
        .clamp(0.0, w - widget.host.margin.left - widget.host.margin.right)
        .toDouble();
    final availH = h -
        safe.top -
        safe.bottom -
        widget.host.margin.top -
        widget.host.margin.bottom -
        insets.bottom;
    final panelH = widget.host.panelSize.height
        .clamp(220.0, availH.clamp(220.0, h))
        .toDouble();

    final left = _isRight
        ? w - widget.host.margin.right - panelW
        : widget.host.margin.left + safe.left;
    final bottom = _isBottom
        ? widget.host.margin.bottom + safe.bottom + insets.bottom
        : null;
    final top = _isBottom ? null : widget.host.margin.top + safe.top;

    return Positioned(
      left: left.clamp(0.0, w).toDouble(),
      bottom: bottom,
      top: top,
      width: panelW,
      height: panelH,
      child: Opacity(
        opacity: t,
        child: Transform.scale(
          scale: 0.7 + 0.3 * t,
          alignment: widget.host.alignment,
          child: Material(
            elevation: theme.panelElevation,
            borderRadius: theme.panelRadius,
            clipBehavior: Clip.antiAlias,
            color: theme.background,
            child: Column(
              children: [
                widget.host.builders.header?.call(context, theme, _close) ??
                    _PanelHeader(
                      theme: theme,
                      title: widget.host.title,
                      subtitle: widget.host.subtitle,
                      avatar: widget.host.icons.avatar,
                      closeIcon: widget.host.icons.close,
                      onClose: _close,
                    ),
                Expanded(
                  child: ChatMessageList(
                    controller: widget.host.controller,
                    theme: theme,
                    icons: widget.host.icons,
                    builders: widget.host.builders,
                    contentBuilder: widget.host.contentBuilder,
                    emptyState: widget.host.emptyState,
                  ),
                ),
                ListenableBuilder(
                  listenable: widget.host.controller,
                  builder: (context, _) {
                    if (widget.host.builders.input != null) {
                      return widget.host.builders.input!(
                        context,
                        AiInputState(
                          theme: theme,
                          isStreaming: widget.host.controller.isStreaming,
                          enabled: true,
                          hintText: widget.host.inputHint,
                          onSend: widget.host.controller.send,
                          onStop: widget.host.controller.stop,
                        ),
                      );
                    }
                    return ChatInputBar(
                      theme: theme,
                      isStreaming: widget.host.controller.isStreaming,
                      hintText: widget.host.inputHint,
                      onSend: widget.host.controller.send,
                      onStop: widget.host.controller.stop,
                      sendIcon: widget.host.icons.send,
                      stopIcon: widget.host.icons.stop,
                      sendButtonBuilder: widget.host.builders.sendButton,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LauncherButton extends StatelessWidget {
  const _LauncherButton({
    required this.theme,
    required this.size,
    required this.icon,
    required this.unread,
    required this.onTap,
  });

  final AiChatTheme theme;
  final double size;
  final Widget? icon;
  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: theme.effectiveLauncherColor,
          shape: const CircleBorder(),
          elevation: theme.launcherElevation,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: icon ??
                    Icon(
                      Icons.chat_bubble_rounded,
                      color: theme.effectiveLauncherIconColor,
                      size: size * 0.44,
                    ),
              ),
            ),
          ),
        ),
        if (unread > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(5),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              decoration: BoxDecoration(
                color: theme.errorColor,
                shape: BoxShape.circle,
                border: Border.all(color: theme.background, width: 2),
              ),
              child: Text(
                unread > 9 ? '9+' : '$unread',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.onClose,
    this.avatar,
    this.closeIcon,
  });

  final AiChatTheme theme;
  final String title;
  final String? subtitle;
  final VoidCallback onClose;
  final Widget? avatar;
  final Widget? closeIcon;

  @override
  Widget build(BuildContext context) {
    final fg = theme.effectiveHeaderTextColor;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: theme.effectiveHeaderColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: avatar ??
                CircleAvatar(
                  radius: 16,
                  backgroundColor: fg.withValues(alpha: 0.2),
                  child: Icon(Icons.smart_toy_rounded, size: 18, color: fg),
                ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: fg.withValues(alpha: 0.85),
                      fontSize: 11.5,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: closeIcon ?? const Icon(Icons.close_rounded),
            color: fg,
            iconSize: 20,
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}
