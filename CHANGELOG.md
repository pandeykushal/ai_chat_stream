# Changelog

## 0.1.0

First release.

- `LlmProvider` interface with OpenAI, Claude and Gemini adapters, plus a
  no-key `DemoProvider`.
- Token streaming over SSE with partial-line buffering.
- `ChatController`: `send`, `stop`, `regenerate`, `clear`, per-message status.
- Typed errors: `AuthException`, `RateLimitException`, `ServerException`,
  `NetworkException`, `ConfigException`.
- Proxy support via `LlmConfig.baseUrl`.
- `AiChatView` (full screen) and `AiChatBubble` (floating panel), sharing one
  message-list and input bar.
- Markdown and code rendering, typing indicator, streaming cursor, auto-scroll,
  copy/regenerate, send/stop toggle.
- Customization via `AiChatTheme`, `AiChatIcons` and `AiChatBuilders`.
- Only one runtime dependency: `http`.
