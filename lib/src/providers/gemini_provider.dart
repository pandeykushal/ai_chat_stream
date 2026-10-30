import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/llm_config.dart';
import '../exceptions/llm_exception.dart';
import '../models/message.dart';
import 'llm_provider.dart';
import 'provider_http.dart';
import 'sse_parser.dart';

/// Google's Gemini (Generative Language API). Hits
/// `<prefix>/models/<model>:streamGenerateContent?alt=sse`. `assistant` maps to
/// Gemini's `model` role; a system prompt becomes `systemInstruction`.
class GeminiProvider extends LlmProvider {
  /// Creates a Gemini provider.
  const GeminiProvider();

  static const String _defaultPrefix =
      'https://generativelanguage.googleapis.com/v1beta';

  @override
  String get name => 'Gemini';

  @override
  Stream<String> streamChat(List<Message> history, LlmConfig config) async* {
    if ((config.apiKey == null || config.apiKey!.isEmpty) &&
        config.baseUrl == null) {
      throw const ConfigException(
        'GeminiProvider needs an apiKey, or a baseUrl pointing at a proxy '
        'that injects one. See the README on API-key safety.',
      );
    }

    final prefix = (config.baseUrl ?? _defaultPrefix).replaceAll(
      RegExp(r'/+$'),
      '',
    );
    final url = Uri.parse(
      '$prefix/models/${config.model}:streamGenerateContent',
    ).replace(
      queryParameters: <String, String>{
        'alt': 'sse',
        if (config.apiKey != null && config.apiKey!.isNotEmpty)
          'key': config.apiKey!,
        ...config.queryParameters,
      },
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
      ...config.headers,
    };

    final contents = <Map<String, dynamic>>[
      for (final m in history)
        if (!m.role.isSystem && !(m.isAssistant && m.content.isEmpty))
          {
            'role': m.isUser ? 'user' : 'model',
            'parts': [
              {'text': m.content},
            ],
          },
    ];

    final systemText = <String>[
      if (config.systemPrompt != null && config.systemPrompt!.isNotEmpty)
        config.systemPrompt!,
      for (final m in history)
        if (m.role.isSystem && m.content.isNotEmpty) m.content,
    ].join('\n\n');

    final generationConfig = <String, dynamic>{
      if (config.temperature != null) 'temperature': config.temperature,
      if (config.maxTokens != null) 'maxOutputTokens': config.maxTokens,
      if (config.topP != null) 'topP': config.topP,
    };

    final body = <String, dynamic>{
      'contents': contents,
      if (systemText.isNotEmpty)
        'systemInstruction': {
          'parts': [
            {'text': systemText},
          ],
        },
      if (generationConfig.isNotEmpty) 'generationConfig': generationConfig,
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
        final text = _extractText(data);
        if (text != null && text.isNotEmpty) yield text;
      }
    } finally {
      client.close();
    }
  }

  String? _extractText(String data) {
    try {
      final json = jsonDecode(data);
      if (json is! Map) return null;
      final candidates = json['candidates'];
      if (candidates is! List || candidates.isEmpty) return null;
      final content = candidates.first['content'];
      if (content is! Map) return null;
      final parts = content['parts'];
      if (parts is! List) return null;
      final buffer = StringBuffer();
      for (final part in parts) {
        if (part is Map && part['text'] is String) {
          buffer.write(part['text']);
        }
      }
      return buffer.toString();
    } catch (_) {
      return null;
    }
  }
}
