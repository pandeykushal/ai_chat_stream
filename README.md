# ai_chat_stream

Streaming LLM chat for Flutter — **one interface for OpenAI, Claude and
Gemini**, a headless controller, and drop-in UI that ships in two shapes:

- **`AiChatView`** — a full-screen chat.
- **`AiChatBubble`** — a floating, Intercom-style launcher that overlays any
  screen and expands into a chat panel.

Both are driven by the same `ChatController` and the same swappable providers,
so you build once and use it anywhere. The only runtime dependency is `http`.

<!--
  Marketing tip: record a short GIF of live streaming + the bubble opening and
  drop it here, e.g.  ![demo](doc/demo.gif)
  A GIF of real streaming sells this far better than any screenshot.
-->

## Why

- **Provider-agnostic.** Swap OpenAI ⇄ Claude ⇄ Gemini — or plug in your own
  API — without touching your UI. This is the whole point.
- **Logic and UI are separate.** A headless `ChatController` you can use with
  no widgets at all, *and* polished drop-in views on top.
- **API-key safety built in.** Point the client at a backend proxy so keys
  never ship inside your app.

## Install

```yaml
dependencies:
  ai_chat_stream: ^0.1.0
```

## Quickstart

Works with **no API key** out of the box via the demo provider:

```dart
import 'package:ai_chat_stream/ai_chat_stream.dart';
import 'package:flutter/material.dart';

final controller = ChatController(
  provider: const DemoProvider(),          // swap for a real provider below
  config: const LlmConfig(model: 'demo'),
);

// ...inside a Scaffold body:
AiChatView(controller: controller);
```

That's the full-screen chat, streaming token-by-token.

## Use a real provider

Pick a provider and give it a model + key:

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

The `model` is passed straight through, so **new models work without updating
this package** — just pass the new name.

## 🔐 API-key safety (read this before shipping)

A key hardcoded in your app can be extracted from the APK/IPA and abused. In
production, run a tiny backend that holds the key and point the client at it
with `baseUrl`:

```dart
const LlmConfig(
  model: 'gpt-4o-mini',
  baseUrl: 'https://your-backend.example.com/openai', // your proxy
  // no apiKey here — the proxy injects it
  headers: {'Authorization': 'Bearer <your-app-token>'},
);
```

Each provider documents exactly how it combines `baseUrl` with its path (e.g.
OpenAI calls `"<baseUrl>/chat/completions"`). A proxy is also the only place you
can enforce **per-user rate limits and spend caps** — the client can't.

## The floating bubble

Mount `AiChatBubble` **above your routes** so it survives navigation. The
simplest way is `MaterialApp.builder`:

```dart
MaterialApp(
  builder: (context, child) => Stack(
    children: [
      if (child != null) child,
      AiChatBubble(
        controller: controller,
        title: 'Assistant',
        subtitle: 'Online — replies instantly',
        alignment: Alignment.bottomRight, // which corner
        draggable: true,                  // optional
      ),
    ],
  ),
  home: const MyHomePage(),
);
```

When collapsed, only the launcher absorbs touches — the rest of your app stays
interactive. It shares the controller with `AiChatView`, so one conversation
can span both.

## Driving it yourself (headless)

```dart
await controller.send('Explain streaming in one line.');
controller.stop();        // abort mid-stream; partial text is kept
controller.regenerate();  // redo the last reply
controller.clear();

controller.addListener(() {
  // messages, isStreaming, per-message status all update here
});
```

## Write your own provider

Implement one method — emit text deltas:

```dart
class MyProvider extends LlmProvider {
  @override
  Stream<String> streamChat(List<Message> history, LlmConfig config) async* {
    // open your streaming request, then:
    yield 'Hello';
    yield ', world';
  }
}
```

The same interface makes testing trivial — inject a fake provider, no HTTP, no
keys (see `test/mock_provider.dart`).

## Customizing the look

Everything your users see is overridable: **colors, the logo, and the icons.**

**Colors** — the chat follows your app's `Theme` automatically (light/dark).
Override any colour via `AiChatTheme`, including a dedicated header colour:

```dart
AiChatView(
  controller: controller,
  theme: AiChatTheme.fromTheme(Theme.of(context)).copyWith(
    userBubbleColor: Colors.indigo,
    accentColor: Colors.indigo,       // send button, links, launcher
    headerColor: const Color(0xFF14B8A6),  // bubble panel header bar
    headerTextColor: Colors.white,
    bubbleRadius: const BorderRadius.all(Radius.circular(12)),
  ),
);
```

**Logo & icons** — pass an `AiChatIcons`. Each slot takes *any widget*, so a
brand logo can be an `Image.asset`, an SVG, a `CircleAvatar`, or an `Icon`:

```dart
AiChatBubble(
  controller: controller,
  icons: AiChatIcons(
    launcher: Image.asset('assets/logo.png'),              // the floating bubble
    avatar: const CircleAvatar(                            // the panel header logo
      backgroundImage: AssetImage('assets/logo.png'),
    ),
    send: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
    stop: const Icon(Icons.stop_circle_rounded, color: Colors.white, size: 22),
  ),
);
```

`AiChatView` takes the same `icons` (its `send`/`stop` slots) and `theme`. You
can also override the whole message renderer with `contentBuilder`.

Need full CommonMark? Pass a `contentBuilder` and render with your preferred
Markdown package; the built-in renderer handles the common cases
(bold/italic/code, fenced code blocks with copy + horizontal scroll, lists,
blockquotes) with zero extra dependencies.

## Handling errors

Failures arrive as typed exceptions and are also reflected on the message
(`MessageStatus.error` + `message.error`), so the UI shows a retry affordance
automatically:

| Exception | When |
|---|---|
| `AuthException` | 401/403 — bad or missing key |
| `RateLimitException` | 429 — carries `retryAfter` when provided |
| `ServerException` | 5xx — provider overloaded |
| `NetworkException` | offline, timeout, or (on web) CORS |
| `ConfigException` | no key **and** no proxy `baseUrl` |

## Supported platforms

Pure-Dart networking → **Android, iOS, web, macOS, Windows, Linux**.

- **Android:** add the `INTERNET` permission (default in most apps).
- **macOS:** enable the network client entitlement
  (`com.apple.security.network.client`).
- **Web:** browsers enforce CORS, so calling provider APIs directly often
  fails — route web through your proxy `baseUrl`.

## A few edge cases, handled

Network drop mid-stream keeps the partial reply and marks it as an error;
**Stop** cancels the subscription and closes the HTTP client cleanly; SSE lines
split across packets are buffered before parsing; long code blocks scroll inside
their own box; the panel dodges the keyboard; and the controller guards against
`notifyListeners` after dispose.

## Roadmap

- v0.2 — tool/function calling, image/vision input, local history persistence,
  token/cost tracking.
- v0.3 — multiple concurrent conversations.

## License

MIT © Kushal Panday
