/// Request-time configuration shared by every provider.
///
/// Holds the model name, generation parameters, credentials and — crucially —
/// an optional [baseUrl] so apps can point at a backend proxy instead of
/// shipping an API key inside the client (see the README's "API-key safety").
class LlmConfig {
  /// Creates a configuration.
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

  /// The model identifier, e.g. `gpt-4o`, `claude-3-5-sonnet-latest`,
  /// `gemini-1.5-flash`. Passed straight through to the provider, so new
  /// models work without updating this package.
  final String model;

  /// The provider API key. Leave `null` when using a proxy ([baseUrl]) that
  /// injects credentials server-side.
  final String? apiKey;

  /// Override the provider's default endpoint. Point this at your own backend
  /// to keep keys off the device, or at an OpenAI-compatible gateway.
  ///
  /// Each provider documents exactly how it combines [baseUrl] with its paths.
  final String? baseUrl;

  /// Optional system / developer instruction prepended to the conversation.
  final String? systemPrompt;

  /// Sampling temperature. Provider default is used when `null`.
  final double? temperature;

  /// Maximum tokens to generate. Provider default is used when `null`.
  /// (Required by Claude; a sensible default is applied there if omitted.)
  final int? maxTokens;

  /// Nucleus sampling parameter. Provider default is used when `null`.
  final double? topP;

  /// Extra HTTP headers merged into every request (e.g. a proxy auth header).
  final Map<String, String> headers;

  /// Extra query parameters merged into the request URL.
  final Map<String, String> queryParameters;

  /// How long to wait for the first byte before failing with a timeout.
  final Duration timeout;

  /// Returns a copy with the given fields replaced.
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
