# Example

A single app showing both UIs:

- a full-screen `AiChatView` on the home screen, and
- a floating `AiChatBubble` mounted over every route via `MaterialApp.builder`.

They share one `ChatController`. The palette icon in the app bar toggles a
custom theme/icons/builders on and off.

## Run

```bash
cd example
flutter create .      # one-time: generates android/ios/web (leaves lib/ alone)
flutter pub get
flutter run           # or: flutter run -d chrome
```

It starts on the demo provider (no key needed). Open Settings (the tune icon)
to switch to OpenAI/Claude/Gemini and enter a key or a proxy URL.
