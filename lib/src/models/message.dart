import 'chat_role.dart';
import 'message_status.dart';

/// An immutable chat message.
///
/// Messages are value objects: streaming updates produce a new instance via
/// [copyWith] rather than mutating in place, which keeps change detection in
/// [ChatController](ChatController) and the UI predictable.
class Message {
  /// Creates a message. [id] defaults to a timestamp-based unique value and
  /// [timestamp] to [DateTime.now] when omitted.
  Message({
    String? id,
    required this.role,
    this.content = '',
    this.status = MessageStatus.done,
    DateTime? timestamp,
    this.error,
  })  : id = id ?? _generateId(),
        timestamp = timestamp ?? DateTime.now();

  /// Stable unique identifier (used as the list key in the UI).
  final String id;

  /// Who authored the message.
  final ChatRole role;

  /// The text content. Grows as tokens stream in for assistant messages.
  final String content;

  /// Current lifecycle status.
  final MessageStatus status;

  /// When the message was created.
  final DateTime timestamp;

  /// Human-readable error detail when [status] is [MessageStatus.error].
  final String? error;

  /// Convenience: `true` when authored by the user.
  bool get isUser => role.isUser;

  /// Convenience: `true` when authored by the assistant.
  bool get isAssistant => role.isAssistant;

  /// Returns a copy with the given fields replaced.
  ///
  /// Pass [clearError] to drop an existing [error] (since `null` means
  /// "keep the current value").
  Message copyWith({
    String? id,
    ChatRole? role,
    String? content,
    MessageStatus? status,
    DateTime? timestamp,
    String? error,
    bool clearError = false,
  }) {
    return Message(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Appends [delta] to [content] and returns the new instance.
  Message appendContent(String delta) => copyWith(content: content + delta);

  @override
  String toString() =>
      'Message(id: $id, role: ${role.name}, status: ${status.name}, '
      'content: ${content.length} chars)';

  static int _counter = 0;
  static String _generateId() {
    _counter++;
    return '${DateTime.now().microsecondsSinceEpoch}_$_counter';
  }
}
