import 'dart:convert';

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
