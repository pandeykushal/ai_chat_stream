import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../exceptions/llm_exception.dart';

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
        detail ?? 'Authentication failed. Check your API key.',
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
    // not json, fall back to the raw snippet below
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
