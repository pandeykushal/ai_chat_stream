/// Base class for all errors surfaced by this package.
///
/// Providers translate transport and API failures into these typed exceptions
/// so UIs can react precisely (e.g. show "check your key" for [AuthException]
/// vs "slow down" for [RateLimitException]).
class LlmException implements Exception {
  /// Creates an exception with a human-readable [message].
  const LlmException(this.message, {this.statusCode, this.cause});

  /// Human-readable description, safe to surface in a UI.
  final String message;

  /// The HTTP status code, when the failure came from an API response.
  final int? statusCode;

  /// The underlying error/exception, when wrapping a lower-level failure.
  final Object? cause;

  @override
  String toString() {
    final code = statusCode != null ? ' (HTTP $statusCode)' : '';
    return '$runtimeType$code: $message';
  }
}

/// The request was rejected for authentication/authorization reasons
/// (typically HTTP 401 or 403). Usually a missing, wrong or expired API key.
class AuthException extends LlmException {
  /// Creates an auth exception.
  const AuthException(super.message, {super.statusCode, super.cause});
}

/// The provider rate-limited the request (HTTP 429).
class RateLimitException extends LlmException {
  /// Creates a rate-limit exception, optionally carrying the server's
  /// suggested [retryAfter] delay (from the `Retry-After` header).
  const RateLimitException(
    super.message, {
    super.statusCode,
    super.cause,
    this.retryAfter,
  });

  /// How long the caller should wait before retrying, if the server said so.
  final Duration? retryAfter;
}

/// The provider failed server-side (HTTP 5xx / overloaded).
class ServerException extends LlmException {
  /// Creates a server exception.
  const ServerException(super.message, {super.statusCode, super.cause});
}

/// A transport-level failure: no connection, DNS failure, TLS error, timeout,
/// or (on web) a CORS block. Often means the device is offline or a proxy
/// [baseUrl] is unreachable.
class NetworkException extends LlmException {
  /// Creates a network exception.
  const NetworkException(super.message, {super.cause});
}

/// The provider was asked to run without enough configuration to proceed
/// (e.g. no API key and no proxy [baseUrl]). Thrown early with guidance,
/// before any network call.
class ConfigException extends LlmException {
  /// Creates a config exception.
  const ConfigException(super.message, {super.cause});
}
