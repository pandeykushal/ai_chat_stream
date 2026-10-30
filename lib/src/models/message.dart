import 'chat_role.dart';
import 'message_status.dart';

/// A single chat message. Immutable; streaming produces new copies via
/// [copyWith] rather than mutating.
class Message {
  /// Creates a message. [id] and [timestamp] default to generated values.
  Message({
    String? id,
    required this.role,
    this.content = '',
    this.status = MessageStatus.done,
    DateTime? timestamp,
    this.error,
  })  : id = id ?? _generateId(),
        timestamp = timestamp ?? DateTime.now();

  /// Stable id, used as the list key.
  final String id;

  /// Who sent it.
  final ChatRole role;

  /// The text. Grows as tokens stream in.
  final String content;

  /// Current status.
  final MessageStatus status;

  /// When it was created.
  final DateTime timestamp;

  /// Error detail when [status] is [MessageStatus.error].
  final String? error;

  /// True when sent by the user.
  bool get isUser => role.isUser;

  /// True when sent by the assistant.
  bool get isAssistant => role.isAssistant;

  /// A copy with the given fields replaced. Pass [clearError] to drop [error].
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

  /// A copy with [delta] appended to [content].
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
