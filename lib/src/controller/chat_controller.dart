import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/llm_config.dart';
import '../exceptions/llm_exception.dart';
import '../models/chat_role.dart';
import '../models/message.dart';
import '../models/message_status.dart';
import '../providers/llm_provider.dart';

/// Holds the message list and streaming state. A ChangeNotifier, so it works
/// with the built-in widgets or on its own.
class ChatController extends ChangeNotifier {
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

  // Resolves the future from send(), including when we stop or dispose
  // mid-stream (onDone won't fire then).
  void _finish() {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete();
    }
    _completer = null;
  }

  LlmProvider get provider => _provider;
  set provider(LlmProvider value) {
    _provider = value;
    _safeNotify();
  }

  LlmConfig get config => _config;
  set config(LlmConfig value) {
    _config = value;
    _safeNotify();
  }

  List<Message> get messages => List<Message>.unmodifiable(_messages);

  bool get isStreaming => _subscription != null;

  bool get isBusy => isStreaming;

  String? get lastUserText {
    for (final m in _messages.reversed) {
      if (m.isUser) return m.content;
    }
    return null;
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isBusy || _disposed) return;
    _messages.add(Message(role: ChatRole.user, content: trimmed));
    _safeNotify();
    await _run();
  }

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

  void clear() {
    if (isStreaming) stop();
    _messages.clear();
    _safeNotify();
  }

  void addMessage(Message message) {
    _messages.add(message);
    _safeNotify();
  }

  Future<void> _run() async {
    final history = List<Message>.of(_messages);

    final placeholder = Message(
        role: ChatRole.assistant, content: '', status: MessageStatus.sending);
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
