import '../config/llm_config.dart';
import '../models/message.dart';

/// A backend. Implement [streamChat] to emit the reply as text deltas.
abstract class LlmProvider {
  const LlmProvider();

  Stream<String> streamChat(List<Message> history, LlmConfig config);

  String get name => runtimeType.toString();
}
