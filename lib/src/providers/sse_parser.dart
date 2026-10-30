import 'dart:convert';

/// Parses a raw Server-Sent Events byte stream into event *data* payloads.
///
/// Handles the three things naive parsers get wrong:
///  * **Chunk splitting** — a single SSE line may arrive across several network
///    packets. [LineSplitter] (fed by a streaming UTF-8 decoder) buffers until a
///    newline, and the UTF-8 decoder buffers partial multi-byte characters, so
///    tokens are never cut mid-character.
///  * **Multi-line `data:` fields** — consecutive `data:` lines in one event are
///    joined with `\n`, per the SSE spec.
///  * **Comments / heartbeats** — lines starting with `:` are ignored.
///
/// Yields the payload of each event (for LLM APIs that is usually a JSON string,
/// or the sentinel `[DONE]`). `event:`, `id:` and `retry:` fields are ignored.
Stream<String> parseSse(Stream<List<int>> byteStream) async* {
  final lines =
      byteStream.transform(utf8.decoder).transform(const LineSplitter());
  final data = StringBuffer();

  await for (final line in lines) {
    if (line.isEmpty) {
      // Blank line terminates an event.
      if (data.isNotEmpty) {
        yield data.toString();
        data.clear();
      }
      continue;
    }
    if (line.startsWith(':')) continue; // comment / keep-alive
    if (line.startsWith('data:')) {
      var value = line.substring(5);
      if (value.startsWith(' ')) value = value.substring(1);
      if (data.isNotEmpty) data.write('\n');
      data.write(value);
    }
    // All other fields (event:, id:, retry:) are intentionally ignored.
  }

  // Flush a trailing event with no closing blank line.
  if (data.isNotEmpty) {
    yield data.toString();
  }
}
