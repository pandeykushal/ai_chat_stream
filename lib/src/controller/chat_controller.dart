import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/llm_config.dart';
import '../exceptions/llm_exception.dart';
import '../models/chat_role.dart';
import '../models/message.dart';
import '../models/message_status.dart';
import '../providers/llm_provider.dart';

/// The headless brain of a chat: owns the message list and streaming state,
/// and appends partial tokens as they arrive.
///
/// It is a [ChangeNotifier], so it works with `ListenableBuilder`,
/// `AnimatedBuilder`, `provider`, or any state-management approach — and with
/// **no UI at all**. [AiChatView](AiChatView) and [AiChatBubble](AiChatBubble)
/// are thin shells over this class.
///
/// ```dart
/// final controller = ChatController(
///   provider: const OpenAIProvider(),
///   config: const LlmConfig(model: 'gpt-4o', apiKey: '...'),
/// );
/// await controller.send('Hello!');
/// ```
class ChatController extends ChangeNotifier {
  /// Creates a controller bound to [provider] and [config].
  ChatController({
    required LlmProvider provider,
    required LlmConfig config,
    List<Message>? initialMessages,
  })  : _provider = provider,
        _config = config,
        _messages = List<Message>.of(initialMessages ?? const []);

  LlmProvider _provider;
  LlmConfig _config;
  final List<Message> _messages;

  StreamSubscription<String>? _subscription;
  String? _streamingId;
  Completer<void>? _completer;
  bool _disposed = false;

  void _finish() {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete();
    }
    _completer = null;
  }

  /// The active provider. Assigning a new one affects the *next* request.
  LlmProvider get provider => _provider;
  set provider(LlmProvider value) {
    _provider = value;
    _safeNotify();
  }

  /// The active configuration. Assigning a new one affects the *next* request.
  LlmConfig get config => _config;
  set config(LlmConfig value) {
    _config = value;
    _safeNotify();
  }

  /// The conversation, oldest first. Unmodifiable — mutate via the methods.
  List<Message> get messages => List<Message>.unmodifiable(_messages);

  /// `true` while a response is streaming (or the request is in flight).
  bool get isStreaming => _subscription != null;

  /// Convenience alias for [isStreaming].
  bool get isBusy => isStreaming;

  /// The last user message's text, or `null` if none yet.
  String? get lastUserText {
    for (final m in _messages.reversed) {
      if (m.isUser) return m.content;
    }
    return null;
  }

  /// Sends [text] as a user message and streams the assistant's reply.
  ///
  /// No-ops on empty input or while another response is streaming.
  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isBusy || _disposed) return;
    _messages.add(Message(role: ChatRole.user, content: trimmed));
    _safeNotify();
    await _run();
  }

  /// Aborts the in-flight response cleanly, keeping any partial text.
  void stop() {
    if (_subscription == null) return;
    _subscription!.cancel();
    _subscription = null;
    final id = _streamingId;
    _streamingId = null;
    if (id != null) {
      _updateMessage(
        id,
        (m) => m.copyWith(
          status: m.content.isEmpty ? MessageStatus.error : MessageStatus.done,
          error: m.content.isEmpty ? 'Stopped before any reply.' : null,
        ),
      );
    } else {
      _safeNotify();
    }
    _finish();
  }

  /// Re-generates the reply to the most recent user message.
  ///
  /// Drops the last assistant message (if any) and streams a fresh one.
  Future<void> regenerate() async {
    if (isBusy || _disposed) return;
    if (_messages.isEmpty) return;
    if (_messages.last.isAssistant) {
      _messages.removeLast();
      _safeNotify();
    }
    if (_messages.isEmpty || !_messages.last.isUser) return;
    await _run();
  }

  /// Clears the conversation (stopping any active stream first).
  void clear() {
    if (isStreaming) stop();
    _messages.clear();
    _safeNotify();
  }

  /// Appends a pre-built [message] (e.g. to seed a greeting). Not for streaming.
  void addMessage(Message message) {
    _messages.add(message);
    _safeNotify();
  }

  // --- internals -----------------------------------------------------------

  Future<void> _run() async {
    // Snapshot the history BEFORE adding the assistant placeholder.
    final history = List<Message>.of(_messages);

    final placeholder = Message(role: ChatRole.assistant, content: '', status: MessageStatus.sending);
    _streamingId = placeholder.id;
    _messages.add(placeholder);
    _safeNotify();

    final completer = Completer<void>();
    _completer = completer;
    var started = false;

    _subscription = _provider.streamChat(history, _config).listen(
      (delta) {
        final id = _streamingId;
        if (id == null) return;
        if (!started) {
          started = true;
          _updateMessage(
            id,
            (m) => m.copyWith(status: MessageStatus.streaming),
            notify: false,
          );
        }
        _updateMessage(id, (m) => m.appendContent(delta));
      },
      onError: (Object error, StackTrace stack) {
        final id = _streamingId;
        _subscription = null;
        _streamingId = null;
        if (id != null) {
          _updateMessage(
            id,
            (m) => m.copyWith(
              status: MessageStatus.error,
              error: _describeError(error),
            ),
          );
        }
        _finish();
      },
      onDone: () {
        final id = _streamingId;
        _subscription = null;
        _streamingId = null;
        if (id != null) {
          _updateMessage(id, (m) => m.copyWith(status: MessageStatus.done));
        }
        _finish();
      },
      cancelOnError: true,
    );

    return completer.future;
  }

  void _updateMessage(
    String id,
    Message Function(Message) update, {
    bool notify = true,
  }) {
    final index = _messages.indexWhere((m) => m.id == id);
    if (index == -1) return;
    _messages[index] = update(_messages[index]);
    if (notify) _safeNotify();
  }

  String _describeError(Object error) {
    if (error is LlmException) return error.message;
    return 'Something went wrong: $error';
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
    _finish();
    super.dispose();
  }
}
