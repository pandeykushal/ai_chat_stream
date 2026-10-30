import 'package:ai_chat_stream/ai_chat_stream.dart';

/// A tiny deterministic provider for tests — proof that the [LlmProvider]
/// interface makes mocking trivial (no HTTP, no keys).
class MockProvider extends LlmProvider {
  MockProvider({
    required this.tokens,
    this.perToken = Duration.zero,
    this.throwAfter,
  });

  /// The chunks to emit, in order.
  final List<String> tokens;

  /// Delay before each chunk (keep [Duration.zero] for fast tests).
  final Duration perToken;

  /// If set, throw a [NetworkException] once this many chunks have been emitted.
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
