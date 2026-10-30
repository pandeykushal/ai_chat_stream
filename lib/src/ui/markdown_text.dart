import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AiChatMarkdown extends StatelessWidget {
  const AiChatMarkdown({
    super.key,
    required this.data,
    required this.style,
    required this.codeBackground,
    required this.codeTextColor,
    required this.linkColor,
    this.codeFontFamily = 'monospace',
    this.codeRadius = const BorderRadius.all(Radius.circular(10)),
  });

  final String data;

  final TextStyle style;

  final Color codeBackground;

  final Color codeTextColor;

  final Color linkColor;

  final String codeFontFamily;

  final BorderRadius codeRadius;

  @override
  Widget build(BuildContext context) {
    final blocks = _parseBlocks(data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          _buildBlock(context, blocks[i]),
        ],
      ],
    );
  }

  Widget _buildBlock(BuildContext context, _Block block) {
    switch (block.type) {
      case _BlockType.code:
        return _CodeBlock(
          code: block.text,
          language: block.language,
          background: codeBackground,
          textColor: codeTextColor,
          fontFamily: codeFontFamily,
          radius: codeRadius,
        );
      case _BlockType.heading:
        final scale = switch (block.level) {
          1 => 1.5,
          2 => 1.3,
          3 => 1.15,
          _ => 1.05,
        };
        return Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 2),
          child: Text.rich(
            TextSpan(
              children: _inlineSpans(
                block.text,
                style.copyWith(
                  fontSize: (style.fontSize ?? 15.0) * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      case _BlockType.bullet:
      case _BlockType.ordered:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(block.marker!, style: style),
              const SizedBox(width: 6),
              Expanded(
                child: Text.rich(TextSpan(children: _inlineSpans(block.text, style))),
              ),
            ],
          ),
        );
      case _BlockType.quote:
        return Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: linkColor.withValues(alpha: 0.5), width: 3),
            ),
          ),
          padding: const EdgeInsets.only(left: 10, top: 2, bottom: 2),
          child: Text.rich(
            TextSpan(
              children: _inlineSpans(
                block.text,
                style.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ),
        );
      case _BlockType.rule:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Divider(height: 1, color: style.color?.withValues(alpha: 0.3)),
        );
      case _BlockType.paragraph:
        return Text.rich(TextSpan(children: _inlineSpans(block.text, style)));
    }
  }

  List<_Block> _parseBlocks(String src) {
    final lines = src.split('\n');
    final blocks = <_Block>[];
    final paragraph = <String>[];

    void flushParagraph() {
      if (paragraph.isEmpty) return;
      blocks.add(_Block(_BlockType.paragraph, paragraph.join(' ').trim()));
      paragraph.clear();
    }

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final fence = RegExp(r'^\s*```(.*)$').firstMatch(line);
      if (fence != null) {
        flushParagraph();
        final language = fence.group(1)!.trim();
        final buffer = <String>[];
        i++;
        while (i < lines.length && !RegExp(r'^\s*```\s*$').hasMatch(lines[i])) {
          buffer.add(lines[i]);
          i++;
        }
        blocks.add(_Block(
          _BlockType.code,
          buffer.join('\n'),
          language: language.isEmpty ? null : language,
        ));
        continue;
      }

      if (line.trim().isEmpty) {
        flushParagraph();
        continue;
      }

      final heading = RegExp(r'^(#{1,6})\s+(.*)$').firstMatch(line);
      if (heading != null) {
        flushParagraph();
        blocks.add(_Block(
          _BlockType.heading,
          heading.group(2)!.trim(),
          level: heading.group(1)!.length,
        ));
        continue;
      }

      if (RegExp(r'^\s*([-*_])(\s*\1){2,}\s*$').hasMatch(line)) {
        flushParagraph();
        blocks.add(const _Block(_BlockType.rule, ''));
        continue;
      }

      final bullet = RegExp(r'^\s*[-*+]\s+(.*)$').firstMatch(line);
      if (bullet != null) {
        flushParagraph();
        blocks.add(_Block(_BlockType.bullet, bullet.group(1)!, marker: '•'));
        continue;
      }

      final ordered = RegExp(r'^\s*(\d+)\.\s+(.*)$').firstMatch(line);
      if (ordered != null) {
        flushParagraph();
        blocks.add(_Block(
          _BlockType.ordered,
          ordered.group(2)!,
          marker: '${ordered.group(1)}.',
        ));
        continue;
      }

      final quote = RegExp(r'^\s*>\s?(.*)$').firstMatch(line);
      if (quote != null) {
        flushParagraph();
        blocks.add(_Block(_BlockType.quote, quote.group(1)!));
        continue;
      }

      paragraph.add(line.trim());
    }
    flushParagraph();
    return blocks;
  }

  List<InlineSpan> _inlineSpans(String text, TextStyle base) {
    final spans = <InlineSpan>[];
    final plain = StringBuffer();

    void flushPlain() {
      if (plain.isNotEmpty) {
        spans.add(TextSpan(text: plain.toString(), style: base));
        plain.clear();
      }
    }

    var i = 0;
    while (i < text.length) {
      if (text[i] == '`') {
        final close = text.indexOf('`', i + 1);
        if (close > i) {
          flushPlain();
          spans.add(TextSpan(
            text: text.substring(i + 1, close),
            style: base.copyWith(
              fontFamily: codeFontFamily,
              backgroundColor: codeBackground.withValues(alpha: 0.12),
              color: base.color,
            ),
          ));
          i = close + 1;
          continue;
        }
      }

      final bold = _matchDelimited(text, i, '**') ?? _matchDelimited(text, i, '__');
      if (bold != null) {
        flushPlain();
        spans.addAll(_inlineSpans(bold.inner, base.copyWith(fontWeight: FontWeight.w700)));
        i = bold.end;
        continue;
      }

      final italic = _matchDelimited(text, i, '*') ?? _matchDelimited(text, i, '_');
      if (italic != null) {
        flushPlain();
        spans.addAll(_inlineSpans(italic.inner, base.copyWith(fontStyle: FontStyle.italic)));
        i = italic.end;
        continue;
      }

      if (text[i] == '[') {
        final match = RegExp(r'^\[([^\]]+)\]\(([^)]+)\)').firstMatch(text.substring(i));
        if (match != null) {
          flushPlain();
          spans.add(TextSpan(
            text: match.group(1),
            style: base.copyWith(
              color: linkColor,
              decoration: TextDecoration.underline,
              decorationColor: linkColor,
            ),
          ));
          i += match.group(0)!.length;
          continue;
        }
      }

      plain.write(text[i]);
      i++;
    }
    flushPlain();
    return spans;
  }

  _Delimited? _matchDelimited(String text, int start, String delim) {
    if (!text.startsWith(delim, start)) return null;
    if (delim.length == 1 && text.startsWith(delim * 2, start)) return null;
    final contentStart = start + delim.length;
    final close = text.indexOf(delim, contentStart);
    if (close <= contentStart) return null; // no closing or empty
    return _Delimited(
      inner: text.substring(contentStart, close),
      end: close + delim.length,
    );
  }
}

class _Delimited {
  const _Delimited({required this.inner, required this.end});
  final String inner;
  final int end;
}

enum _BlockType { paragraph, heading, bullet, ordered, quote, code, rule }

class _Block {
  const _Block(this.type, this.text, {this.level = 0, this.marker, this.language});
  final _BlockType type;
  final String text;
  final int level;
  final String? marker;
  final String? language;
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({
    required this.code,
    required this.language,
    required this.background,
    required this.textColor,
    required this.fontFamily,
    required this.radius,
  });

  final String code;
  final String? language;
  final Color background;
  final Color textColor;
  final String fontFamily;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 8, 2),
                child: Text(
                  language ?? 'code',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontFamily: fontFamily,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Copy',
                visualDensity: VisualDensity.compact,
                iconSize: 16,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                color: textColor.withValues(alpha: 0.7),
                icon: const Icon(Icons.copy_rounded),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  if (context.mounted) {
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                      const SnackBar(
                        content: Text('Code copied'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SelectableText(
              code,
              style: TextStyle(
                color: textColor,
                fontFamily: fontFamily,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
