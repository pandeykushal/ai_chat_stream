# Changelog

## 0.1.0

Initial release.

- Provider-agnostic `LlmProvider` interface with built-in adapters for
  **OpenAI**, **Claude** and **Gemini**, plus a zero-config `DemoProvider`.
- Token-by-token streaming over SSE, with robust chunk-boundary buffering.
- Headless `ChatController` (`send`, `stop`, `regenerate`, `clear`) that appends
  partial tokens and tracks per-message status.
- Typed errors: `AuthException`, `RateLimitException`, `ServerException`,
  `NetworkException`, `ConfigException`.
- Proxy / BYO-backend support via `LlmConfig.baseUrl` so API keys need not ship
  in the app.
- Drop-in UI sharing one engine:
  - `AiChatView` — full-screen chat with Markdown + code rendering, a typing
    indicator, a streaming cursor, auto-scroll, a scroll-to-bottom button, a
    Send ⇄ Stop toggle, and copy / regenerate actions.
  - `AiChatBubble` — a floating, Intercom-style launcher that expands into a
    keyboard-dodging panel, with an unread badge, configurable corner and an
    optional draggable launcher.
- Theming via `AiChatTheme` (derived from the host `Theme` by default).
- Only one runtime dependency: `http`.
