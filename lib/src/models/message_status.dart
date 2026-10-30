enum MessageStatus {
  sending,

  streaming,

  done,

  error;

  bool get isInProgress =>
      this == MessageStatus.sending || this == MessageStatus.streaming;

  bool get isError => this == MessageStatus.error;
}
