import 'dart:convert';

import 'package:ai_chat_stream/ai_chat_stream.dart';
import 'package:flutter_test/flutter_test.dart';

Stream<List<int>> _bytes(List<String> chunks) async* {
  for (final c in chunks) {
    yield utf8.encode(c);
  }
}

void main() {
  group('parseSse', () {
    test('extracts a single data payload', () async {
      final out = await parseSse(_bytes(['data: hello\n\n'])).toList();
      expect(out, ['hello']);
    });

    test('passes the [DONE] sentinel through', () async {
      final out = await parseSse(_bytes(['data: [DONE]\n\n'])).toList();
      expect(out, ['[DONE]']);
    });

    test('handles a line split across network chunks', () async {
      final out = await parseSse(_bytes(['data: wor', 'ld\n\n'])).toList();
      expect(out, ['world']);
    });

    test('ignores comment / keep-alive lines', () async {
      final out =
          await parseSse(_bytes([': keep-alive\n\ndata: x\n\n'])).toList();
      expect(out, ['x']);
    });

    test('joins multiple data: lines in one event with newlines', () async {
      final out = await parseSse(_bytes(['data: a\ndata: b\n\n'])).toList();
      expect(out, ['a\nb']);
    });

    test('yields multiple events in order', () async {
      final out = await parseSse(
        _bytes(['data: one\n\ndata: two\n\ndata: [DONE]\n\n']),
      ).toList();
      expect(out, ['one', 'two', '[DONE]']);
    });

    test('flushes a trailing event with no closing blank line', () async {
      final out = await parseSse(_bytes(['data: tail'])).toList();
      expect(out, ['tail']);
    });
  });
}
