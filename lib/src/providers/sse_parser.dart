import 'dart:convert';

/// Parses a Server-Sent Events byte stream into event data payloads (for LLM
/// APIs, usually a JSON string per event, or `[DONE]`). Buffers partial lines
/// so tokens split across packets aren't cut.
Stream<String> parseSse(Stream<List<int>> byteStream) async* {
  final lines =
      byteStream.transform(utf8.decoder).transform(const LineSplitter());
  final data = StringBuffer();

  await for (final line in lines) {
    if (line.isEmpty) {
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
  }

  if (data.isNotEmpty) {
    yield data.toString();
  }
}
