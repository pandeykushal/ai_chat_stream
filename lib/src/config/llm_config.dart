/// Per-request settings shared by every provider.
///
/// Set [baseUrl] to point at a backend proxy so the API key stays off the
/// device.
class LlmConfig {
  /// Creates a config. Only [model] is required.
  const LlmConfig({
    required this.model,
    this.apiKey,
    this.baseUrl,
    this.systemPrompt,
    this.temperature,
    this.maxTokens,
    this.topP,
    this.headers = const {},
    this.timeout = const Duration(seconds: 60),
    this.queryParameters = const {},
  });

  /// Model id, passed straight to the provider (e.g. `gpt-4o-mini`).
  final String model;

  /// API key. Leave null when a proxy ([baseUrl]) supplies it.
  final String? apiKey;

  /// Override the provider endpoint, e.g. your own backend.
  final String? baseUrl;

  /// Optional system instruction.
  final String? systemPrompt;

  /// Sampling temperature. Provider default when null.
  final double? temperature;

  /// Max tokens to generate. Provider default when null.
  final int? maxTokens;

  /// Nucleus sampling. Provider default when null.
  final double? topP;

  /// Extra headers merged into every request.
  final Map<String, String> headers;

  /// Extra query parameters merged into the request URL.
  final Map<String, String> queryParameters;

  /// Time to wait for the first byte.
  final Duration timeout;

  /// A copy with the given fields replaced.
  LlmConfig copyWith({
    String? model,
    String? apiKey,
    String? baseUrl,
    String? systemPrompt,
    double? temperature,
    int? maxTokens,
    double? topP,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Duration? timeout,
  }) {
    return LlmConfig(
      model: model ?? this.model,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      topP: topP ?? this.topP,
      headers: headers ?? this.headers,
      queryParameters: queryParameters ?? this.queryParameters,
      timeout: timeout ?? this.timeout,
    );
  }
}
