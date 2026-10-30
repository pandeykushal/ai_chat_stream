/// Who authored a message in a conversation.
enum ChatRole {
  /// The end user typing into the chat.
  user,

  /// The language model's reply.
  assistant,

  /// A system / developer instruction that steers the model.
  system;

  /// `true` for [ChatRole.user].
  bool get isUser => this == ChatRole.user;

  /// `true` for [ChatRole.assistant].
  bool get isAssistant => this == ChatRole.assistant;

  /// `true` for [ChatRole.system].
  bool get isSystem => this == ChatRole.system;

  /// The wire value most OpenAI-compatible APIs expect
  /// (`user`, `assistant`, `system`).
  String get wireName => name;
}
