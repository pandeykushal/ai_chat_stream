import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/llm_config.dart';
import '../exceptions/llm_exception.dart';
import '../models/message.dart';
import 'llm_provider.dart';
import 'provider_http.dart';
import 'sse_parser.dart';

/// Anthropic's Claude (Messages API). Hits
/// `<baseUrl or https://api.anthropic.com/v1>/messages`. `system` is lifted out
/// of the message list, and `max_tokens` falls back to [defaultMaxTokens].
class ClaudeProvider extends LlmProvider {
  /// Creates a Claude provider.
  const ClaudeProvider();

  static const String _defaultPrefix = 'https://api.anthropic.com/v1';
  static const String _anthropicVersion = '2023-06-01';

  /// Used when [LlmConfig.maxTokens] is null (Anthropic requires the field).
  static const int defaultMaxTokens = 1024;

  @override
  String get name => 'Claude';

  @override
  Stream<String> streamChat(List<Message> history, LlmConfig config) async* {
    if ((config.apiKey == null || config.apiKey!.isEmpty) &&
        config.baseUrl == null) {
      throw const ConfigException(
        'ClaudeProvider needs an apiKey, or a baseUrl pointing at a proxy '
        'that injects one. See the README on API-key safety.',
      );
    }

    final prefix = (config.baseUrl ?? _defaultPrefix).replaceAll(
      RegExp(r'/+$'),
      '',
    );
    final url = Uri.parse('$prefix/messages').replace(
      queryParameters:
          config.queryParameters.isEmpty ? null : config.queryParameters,
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
      'anthropic-version': _anthropicVersion,
      'anthropic-dangerous-direct-browser-access': 'true',
      if (config.apiKey != null && config.apiKey!.isNotEmpty)
        'x-api-key': config.apiKey!,
      ...config.headers,
    };

    final systemParts = <String>[
      if (config.systemPrompt != null && config.systemPrompt!.isNotEmpty)
        config.systemPrompt!,
      for (final m in history)
        if (m.role.isSystem && m.content.isNotEmpty) m.content,
    ];

    final messages = <Map<String, String>>[
      for (final m in history)
        if (!m.role.isSystem && !(m.isAssistant && m.content.isEmpty))
          {'role': m.role.wireName, 'content': m.content},
    ];

    final body = <String, dynamic>{
      'model': config.model,
      'max_tokens': config.maxTokens ?? defaultMaxTokens,
      'messages': messages,
      'stream': true,
      if (systemParts.isNotEmpty) 'system': systemParts.join('\n\n'),
      if (config.temperature != null) 'temperature': config.temperature,
      if (config.topP != null) 'top_p': config.topP,
    };

    final client = http.Client();
    try {
      final response = await openStreamingPost(
        client: client,
        url: url,
        headers: headers,
        body: body,
        timeout: config.timeout,
      );

      await for (final data in parseSse(response.stream)) {
        final event = _decode(data);
        if (event == null) continue;
        final type = event['type'];
        if (type == 'content_block_delta') {
          final delta = event['delta'];
          if (delta is Map &&
              delta['type'] == 'text_delta' &&
              delta['text'] is String) {
            final text = delta['text'] as String;
            if (text.isNotEmpty) yield text;
          }
        } else if (type == 'message_stop') {
          return;
        } else if (type == 'error') {
          final error = event['error'];
          final message = error is Map && error['message'] is String
              ? error['message'] as String
              : 'The provider reported an error mid-stream.';
          throw LlmException(message);
        }
      }
    } finally {
      client.close();
    }
  }

  Map<String, dynamic>? _decode(String data) {
    try {
      final json = jsonDecode(data);
      return json is Map<String, dynamic> ? json : null;
    } catch (_) {
      return null;
    }
  }
}
