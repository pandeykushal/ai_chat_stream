# ai_chat_stream

Streaming LLM chat for Flutter. One interface for OpenAI, Claude and Gemini, a
headless controller, and two ready-made UIs: a full-screen view and a floating
chat bubble. The only runtime dependency is `http`.

## Install

```yaml
dependencies:
  ai_chat_stream: ^0.1.0
```

## Quickstart

Runs with no API key using the built-in demo provider:

```dart
import 'package:ai_chat_stream/ai_chat_stream.dart';
import 'package:flutter/material.dart';

final controller = ChatController(
  provider: const DemoProvider(),
  config: const LlmConfig(model: 'demo'),
);

// inside a Scaffold body:
AiChatView(controller: controller);
```

## Real providers

```dart
// OpenAI (or any OpenAI-compatible endpoint)
ChatController(
  provider: const OpenAIProvider(),
  config: const LlmConfig(model: 'gpt-4o-mini', apiKey: 'sk-...'),
);

// Claude
ChatController(
  provider: const ClaudeProvider(),
  config: const LlmConfig(model: 'claude-3-5-sonnet-latest', apiKey: 'sk-ant-...'),
);

// Gemini
ChatController(
  provider: const GeminiProvider(),
  config: const LlmConfig(model: 'gemini-1.5-flash', apiKey: 'AIza...'),
);
```

`model` is passed straight through, so new models work without a package update.

## API keys

Don't ship a key inside a released app; it can be pulled out of the binary.
Run a small backend that holds the key and point the client at it with
`baseUrl`:

```dart
const LlmConfig(
  model: 'gpt-4o-mini',
  baseUrl: 'https://your-backend.example.com/openai',
  headers: {'Authorization': 'Bearer <your-app-token>'},
);
```

Each provider appends its own path to `baseUrl` (OpenAI hits
`<baseUrl>/chat/completions`, Claude `<baseUrl>/messages`, Gemini
`<baseUrl>/models/<model>:streamGenerateContent`). A backend is also the only
place you can enforce per-user rate limits and spend caps.

## Floating bubble

Mount it above your routes so it survives navigation:

```dart
MaterialApp(
  builder: (context, child) => Stack(
    children: [
      if (child != null) child,
      AiChatBubble(
        controller: controller,
        title: 'Assistant',
        subtitle: 'Online',
        alignment: Alignment.bottomRight,
        draggable: true,
      ),
    ],
  ),
  home: const MyHomePage(),
);
```

When collapsed, only the launcher takes touches; the rest of your app stays
interactive. It uses the same controller as `AiChatView`, so one conversation
can span both.

## Controller

```dart
await controller.send('Explain streaming in one line.');
controller.stop();        // abort mid-stream, keep the partial text
controller.regenerate();  // redo the last reply
controller.clear();

controller.addListener(() {
  // messages, isStreaming, per-message status update here
});
```

## Custom provider

```dart
class MyProvider extends LlmProvider {
  @override
  Stream<String> streamChat(List<Message> history, LlmConfig config) async* {
    yield 'Hello';
    yield ', world';
  }
}
```

The same interface makes a test double trivial (see `test/mock_provider.dart`).

## Customizing the UI

Both widgets take `theme`, `icons` and `builders`.

`AiChatTheme` covers colours, fonts, per-role bubble padding/radius, input
styling, button/launcher size and colour, timestamps and bubble width. It is
built from the app `Theme` by default:

```dart
AiChatView(
  controller: controller,
  theme: AiChatTheme.fromTheme(Theme.of(context)).copyWith(
    accentColor: Colors.indigo,
    headerColor: const Color(0xFF14B8A6),
    showTimestamps: true,
  ),
);
```

`AiChatIcons` swaps individual glyphs/logos (each takes any widget):

```dart
icons: AiChatIcons(
  launcher: Image.asset('assets/logo.png'),
  avatar: const CircleAvatar(backgroundImage: AssetImage('assets/logo.png')),
  send: const Icon(Icons.send_rounded),
),
```

`AiChatBuilders` replaces whole elements when the above isn't enough: the
message bubble, avatars, typing indicator, timestamp, input bar, send button,
header, launcher and scroll-to-bottom button. Anything left null uses the
default.

The example app toggles all of this on and off at runtime.

## Errors

Failures come back as typed exceptions and are also reflected on the message
(`MessageStatus.error` + `message.error`), so the UI shows a retry button.

| Exception | When |
|---|---|
| `AuthException` | 401/403, bad or missing key |
| `RateLimitException` | 429, carries `retryAfter` if provided |
| `ServerException` | 5xx |
| `NetworkException` | offline, timeout, or web CORS |
| `ConfigException` | no key and no proxy `baseUrl` |

## Platforms

Pure-Dart networking, so Android, iOS, web, macOS, Windows and Linux.

- Android: needs the `INTERNET` permission (on by default in most apps).
- macOS: enable the `com.apple.security.network.client` entitlement.
- Web: browsers enforce CORS, so route provider calls through your `baseUrl`.

## License

MIT
