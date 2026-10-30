/// Who sent a message.
enum ChatRole {
  /// The end user.
  user,

  /// The model's reply.
  assistant,

  /// A system/developer instruction.
  system;

  /// True for [user].
  bool get isUser => this == ChatRole.user;

  /// True for [assistant].
  bool get isAssistant => this == ChatRole.assistant;

  /// True for [system].
  bool get isSystem => this == ChatRole.system;

  /// The value most APIs expect on the wire (`user`, `assistant`, `system`).
  String get wireName => name;
}
