/// Base class for errors from this package.
class LlmException implements Exception {
  /// Creates an exception with a readable [message].
  const LlmException(this.message, {this.statusCode, this.cause});

  /// Readable description, safe to show in a UI.
  final String message;

  /// HTTP status code, when the failure came from a response.
  final int? statusCode;

  /// The underlying error, when wrapping a lower-level failure.
  final Object? cause;

  @override
  String toString() {
    final code = statusCode != null ? ' (HTTP $statusCode)' : '';
    return '$runtimeType$code: $message';
  }
}

/// Bad or missing credentials (401/403).
class AuthException extends LlmException {
  /// Creates an auth exception.
  const AuthException(super.message, {super.statusCode, super.cause});
}

/// Rate limited by the provider (429).
class RateLimitException extends LlmException {
  /// Creates a rate-limit exception, with the server's [retryAfter] if given.
  const RateLimitException(
    super.message, {
    super.statusCode,
    super.cause,
    this.retryAfter,
  });

  /// How long to wait before retrying, if the server said so.
  final Duration? retryAfter;
}

/// Provider-side failure (5xx).
class ServerException extends LlmException {
  /// Creates a server exception.
  const ServerException(super.message, {super.statusCode, super.cause});
}

/// Transport failure: offline, timeout, TLS, or (on web) CORS.
class NetworkException extends LlmException {
  /// Creates a network exception.
  const NetworkException(super.message, {super.cause});
}

/// Not enough config to run (no key and no proxy [baseUrl]).
class ConfigException extends LlmException {
  /// Creates a config exception.
  const ConfigException(super.message, {super.cause});
}
