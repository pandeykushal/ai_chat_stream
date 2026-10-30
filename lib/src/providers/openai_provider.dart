import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/llm_config.dart';
import '../exceptions/llm_exception.dart';
import '../models/message.dart';
import 'llm_provider.dart';
import 'provider_http.dart';
import 'sse_parser.dart';

/// OpenAI (or any OpenAI-compatible endpoint). Hits
/// `<baseUrl or https://api.openai.com/v1>/chat/completions`.
class OpenAIProvider extends LlmProvider {
  /// Creates an OpenAI provider.
  const OpenAIProvider();

  static const String _defaultPrefix = 'https://api.openai.com/v1';

  @override
  String get name => 'OpenAI';

  @override
  Stream<String> streamChat(List<Message> history, LlmConfig config) async* {
    if ((config.apiKey == null || config.apiKey!.isEmpty) &&
        config.baseUrl == null) {
      throw const ConfigException(
        'OpenAIProvider needs an apiKey, or a baseUrl pointing at a proxy '
        'that injects one. See the README on API-key safety.',
      );
    }

    final prefix = (config.baseUrl ?? _defaultPrefix).replaceAll(
      RegExp(r'/+$'),
      '',
    );
    final url = Uri.parse('$prefix/chat/completions').replace(
      queryParameters: config.queryParameters.isEmpty
          ? null
          : config.queryParameters,
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
      if (config.apiKey != null && config.apiKey!.isNotEmpty)
        'Authorization': 'Bearer ${config.apiKey}',
      ...config.headers,
    };

    final messages = <Map<String, String>>[
      if (config.systemPrompt != null && config.systemPrompt!.isNotEmpty)
        {'role': 'system', 'content': config.systemPrompt!},
      for (final m in history)
        if (!(m.isAssistant && m.content.isEmpty))
          {'role': m.role.wireName, 'content': m.content},
    ];

    final body = <String, dynamic>{
      'model': config.model,
      'messages': messages,
      'stream': true,
      if (config.temperature != null) 'temperature': config.temperature,
      if (config.maxTokens != null) 'max_tokens': config.maxTokens,
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
        if (data == '[DONE]') return;
        final delta = _extractDelta(data);
        if (delta != null && delta.isNotEmpty) yield delta;
      }
    } finally {
      client.close();
    }
  }

  String? _extractDelta(String data) {
    try {
      final json = jsonDecode(data);
      if (json is! Map) return null;
      final choices = json['choices'];
      if (choices is! List || choices.isEmpty) return null;
      final delta = choices.first['delta'];
      if (delta is Map && delta['content'] is String) {
        return delta['content'] as String;
      }
    } catch (_) {
      // skip keep-alive / malformed chunks
    }
    return null;
  }
}
