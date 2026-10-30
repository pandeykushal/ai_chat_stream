class LlmException implements Exception {
  const LlmException(this.message, {this.statusCode, this.cause});

  final String message;

  final int? statusCode;

  final Object? cause;

  @override
  String toString() {
    final code = statusCode != null ? ' (HTTP $statusCode)' : '';
    return '$runtimeType$code: $message';
  }
}

class AuthException extends LlmException {
  const AuthException(super.message, {super.statusCode, super.cause});
}

class RateLimitException extends LlmException {
  const RateLimitException(
    super.message, {
    super.statusCode,
    super.cause,
    this.retryAfter,
  });

  final Duration? retryAfter;
}

class ServerException extends LlmException {
  const ServerException(super.message, {super.statusCode, super.cause});
}

class NetworkException extends LlmException {
  const NetworkException(super.message, {super.cause});
}

class ConfigException extends LlmException {
  const ConfigException(super.message, {super.cause});
}
