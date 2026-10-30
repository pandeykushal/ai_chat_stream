import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../exceptions/llm_exception.dart';

/// Internal HTTP helpers shared by the built-in streaming providers.
///
/// Not exported from the package's public API.

/// Opens a streaming POST request and returns the live [http.StreamedResponse].
///
/// Applies [timeout] to establishing the response (time-to-first-byte), maps
/// transport failures to [NetworkException], and throws a typed
/// [LlmException] for non-2xx responses. The caller owns [client] and must
/// close it (typically in a `finally`).
Future<http.StreamedResponse> openStreamingPost({
  required http.Client client,
  required Uri url,
  required Map<String, String> headers,
  required Object body,
  required Duration timeout,
}) async {
  final request = http.Request('POST', url);
  request.headers.addAll(headers);
  request.body = body is String ? body : jsonEncode(body);

  http.StreamedResponse response;
  try {
    response = await client.send(request).timeout(timeout);
  } on TimeoutException catch (e) {
    throw NetworkException(
      'No response from $url within ${timeout.inSeconds}s.',
      cause: e,
    );
  } on http.ClientException catch (e) {
    throw NetworkException(
      'Could not reach $url: ${e.message}',
      cause: e,
    );
  } catch (e) {
    // SocketException, HandshakeException, and (on web) CORS failures all land
    // here as opaque errors.
    throw NetworkException('Network error contacting $url.', cause: e);
  }

  if (response.statusCode < 200 || response.statusCode >= 300) {
    final errorBody = await response.stream.bytesToString();
    throw mapStatusToException(
      response.statusCode,
      errorBody,
      retryAfterHeader: response.headers['retry-after'],
      url: url,
    );
  }
  return response;
}

/// Translates an HTTP status code + error body into a typed [LlmException].
LlmException mapStatusToException(
  int statusCode,
  String body, {
  String? retryAfterHeader,
  Uri? url,
}) {
  final detail = _extractApiMessage(body);
  switch (statusCode) {
    case 401:
    case 403:
      return AuthException(
        detail ?? 'Authentication failed — check your API key.',
        statusCode: statusCode,
      );
    case 429:
      return RateLimitException(
        detail ?? 'Rate limited by the provider.',
        statusCode: statusCode,
        retryAfter: _parseRetryAfter(retryAfterHeader),
      );
    default:
      if (statusCode >= 500) {
        return ServerException(
          detail ?? 'The provider is temporarily unavailable.',
          statusCode: statusCode,
        );
      }
      return LlmException(
        detail ?? 'Request failed with status $statusCode.',
        statusCode: statusCode,
      );
  }
}

/// Best-effort extraction of a provider's error message from a JSON body.
/// Falls back to a trimmed snippet of the raw body.
String? _extractApiMessage(String body) {
  if (body.trim().isEmpty) return null;
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map) {
      final error = decoded['error'];
      if (error is Map && error['message'] is String) {
        return error['message'] as String;
      }
      if (error is String) return error;
      if (decoded['message'] is String) return decoded['message'] as String;
    }
  } catch (_) {
    // Not JSON — fall through to the raw snippet.
  }
  final snippet = body.trim();
  return snippet.length > 300 ? '${snippet.substring(0, 300)}…' : snippet;
}

Duration? _parseRetryAfter(String? header) {
  if (header == null) return null;
  final seconds = int.tryParse(header.trim());
  if (seconds != null) return Duration(seconds: seconds);
  return null;
}
