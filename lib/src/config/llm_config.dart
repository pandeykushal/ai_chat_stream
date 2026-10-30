class LlmConfig {
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

  final String model;

  final String? apiKey;

  final String? baseUrl;

  final String? systemPrompt;

  final double? temperature;

  final int? maxTokens;

  final double? topP;

  final Map<String, String> headers;

  final Map<String, String> queryParameters;

  final Duration timeout;

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
