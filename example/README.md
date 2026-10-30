# ai_chat_stream example

Shows both shells of the package in one app:

- a full-screen **`AiChatView`** on the home screen, and
- a floating, draggable **`AiChatBubble`** mounted over every route via
  `MaterialApp.builder`.

Both share a single `ChatController`, so a conversation continues seamlessly
between them.

## Run it

```bash
cd example
flutter create .       # one-time: generates android/ios/web/… (won't touch lib/)
flutter pub get
flutter run            # or: flutter run -d chrome / -d macos / an emulator
```

It launches on the **Demo (no key)** provider, so streaming works instantly
with no API key. Open **Settings** (the tune icon in the app bar) to switch to
OpenAI, Claude or Gemini, enter a key (or a proxy URL), and set a system prompt.
