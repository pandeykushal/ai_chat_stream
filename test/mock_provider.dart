import 'package:ai_chat_stream/ai_chat_stream.dart';

class MockProvider extends LlmProvider {
  MockProvider({
    required this.tokens,
    this.perToken = Duration.zero,
    this.throwAfter,
  });

  final List<String> tokens;

  final Duration perToken;

  final int? throwAfter;

  @override
  String get name => 'Mock';

  @override
  Stream<String> streamChat(List<Message> history, LlmConfig config) async* {
    var emitted = 0;
    for (final token in tokens) {
      if (perToken > Duration.zero) await Future<void>.delayed(perToken);
      if (throwAfter != null && emitted >= throwAfter!) {
        throw const NetworkException('mock failure');
      }
      yield token;
      emitted++;
    }
  }
}
