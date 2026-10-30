/// Lifecycle of a single [message](Message).
enum MessageStatus {
  /// User message queued / request in flight, no tokens yet.
  sending,

  /// The assistant reply is actively receiving streamed tokens.
  streaming,

  /// The message is complete (stream closed cleanly, or user sent).
  done,

  /// The request failed. Any partial text already received is kept.
  error;

  /// `true` while the message is still being produced
  /// ([sending] or [streaming]).
  bool get isInProgress =>
      this == MessageStatus.sending || this == MessageStatus.streaming;

  /// `true` for [MessageStatus.error].
  bool get isError => this == MessageStatus.error;
}
