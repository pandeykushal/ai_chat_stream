import 'dart:async';

import '../config/llm_config.dart';
import '../exceptions/llm_exception.dart';
import '../models/chat_role.dart';
import '../models/message.dart';
import 'llm_provider.dart';

class DemoProvider extends LlmProvider {
  const DemoProvider({
    this.reply = _defaultReply,
    this.tokenDelay = const Duration(milliseconds: 28),
    this.failAfter,
  });

  final String Function(List<Message> history) reply;

  final Duration tokenDelay;

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
