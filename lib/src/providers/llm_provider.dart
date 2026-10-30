import '../config/llm_config.dart';
import '../models/message.dart';

/// The one interface every backend implements.
///
/// This is the package's core abstraction: swap OpenAI for Claude for Gemini —
/// or plug in your own API — without touching the controller or UI. Implement
/// [streamChat] to emit the assistant reply token-by-token.
///
/// ### Writing a custom provider
///
/// ```dart
/// class MyProvider extends LlmProvider {
///   @override
///   Stream<String> streamChat(List<Message> history, LlmConfig config) async* {
///     // ... open your streaming request ...
///     yield 'Hello';
///     yield ', world';
///   }
/// }
/// ```
///
/// Cancellation is cooperative: when the consumer cancels the subscription
/// (e.g. the user taps **Stop**), the generator is terminated at its next
/// suspension point, so implementations should release resources in a
/// `finally` block (close the HTTP client, etc.).
abstract class LlmProvider {
  /// Const constructor so subclasses can be const where possible.
  const LlmProvider();

  /// Streams the assistant's reply to [history] as a sequence of text deltas.
  ///
  /// [history] is the full conversation in order (it may include a leading
  /// system message; providers may also read [LlmConfig.systemPrompt]).
  /// Implementations should throw an [LlmException](LlmException) subtype on
  /// failure.
  Stream<String> streamChat(List<Message> history, LlmConfig config);

  /// A short label for the provider, handy for pickers and logs.
  String get name => runtimeType.toString();
}
