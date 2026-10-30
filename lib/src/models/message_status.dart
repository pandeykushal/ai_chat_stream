/// Where a message is in its lifecycle.
enum MessageStatus {
  /// Request sent, no tokens yet.
  sending,

  /// Receiving streamed tokens.
  streaming,

  /// Finished (or a user message).
  done,

  /// Failed. Any partial text is kept.
  error;

  /// True while [sending] or [streaming].
  bool get isInProgress =>
      this == MessageStatus.sending || this == MessageStatus.streaming;

  /// True for [error].
  bool get isError => this == MessageStatus.error;
}
