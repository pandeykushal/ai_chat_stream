import 'dart:async';

import '../config/llm_config.dart';
import '../exceptions/llm_exception.dart';
import '../models/chat_role.dart';
import '../models/message.dart';
import 'llm_provider.dart';

/// A fake provider that streams a canned reply with no key and no network.
/// Handy for first runs, demos and tests.
class DemoProvider extends LlmProvider {
  /// Creates a demo provider.
  const DemoProvider({
    this.reply = _defaultReply,
    this.tokenDelay = const Duration(milliseconds: 28),
    this.failAfter,
  });

  /// Builds the reply from the conversation so far.
  final String Function(List<Message> history) reply;

  /// Delay between emitted chunks (use [Duration.zero] in tests).
  final Duration tokenDelay;

  /// If set, throw after this many chunks (to exercise error UI).
  final int? failAfter;

  @override
  String get name => 'Demo';

  @override
  Stream<String> streamChat(List<Message> history, LlmConfig config) async* {
    final text = reply(history);
    final chunks = text.split(RegExp(r'(?<=\s)'));
    var emitted = 0;
    for (final chunk in chunks) {
      if (tokenDelay > Duration.zero) await Future<void>.delayed(tokenDelay);
      if (failAfter != null && emitted >= failAfter!) {
        throw const NetworkException('Simulated connection drop (demo).');
      }
      yield chunk;
      emitted++;
    }
  }

  static String _defaultReply(List<Message> history) {
    final lastUser = history.lastWhere(
      (m) => m.isUser,
      orElse: () => Message(role: ChatRole.user, content: ''),
    );
    final q = lastUser.content.trim();
    return "Hey! I'm the built-in **demo** provider, streaming this reply "
        "token-by-token with no API key.\n\n"
        "${q.isEmpty ? '' : 'You said: "$q"\n\n'}"
        "I render Markdown — *italics*, **bold**, `inline code`, lists:\n\n"
        "1. Swap me for `OpenAIProvider`, `ClaudeProvider` or `GeminiProvider`\n"
        "2. Add your key (or a proxy `baseUrl`)\n"
        "3. Ship it\n\n"
        "And fenced code blocks scroll on their own:\n\n"
        "```dart\n"
        "String reverse(String s) =>\n"
        "    String.fromCharCodes(s.runes.toList().reversed);\n"
        "```\n\n"
        "Tap **Stop** mid-stream to cancel cleanly — the partial text stays.";
  }
}
