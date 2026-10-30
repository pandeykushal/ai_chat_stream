import 'chat_role.dart';
import 'message_status.dart';

class Message {
  Message({
    String? id,
    required this.role,
    this.content = '',
    this.status = MessageStatus.done,
    DateTime? timestamp,
    this.error,
  })  : id = id ?? _generateId(),
        timestamp = timestamp ?? DateTime.now();

  final String id;

  final ChatRole role;

  final String content;

  final MessageStatus status;

  final DateTime timestamp;

  final String? error;

  bool get isUser => role.isUser;

  bool get isAssistant => role.isAssistant;

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
