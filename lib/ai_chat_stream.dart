/// Streaming LLM chat for Flutter.
///
/// A provider-agnostic interface for OpenAI, Claude and Gemini, a headless
/// [ChatController], and drop-in UI: a full-screen [AiChatView] and a floating,
/// Intercom-style [AiChatBubble].
///
/// See the README for a 10-line quickstart.
library;

// Models
export 'src/models/chat_role.dart';
export 'src/models/message_status.dart';
export 'src/models/message.dart';

// Config & errors
export 'src/config/llm_config.dart';
export 'src/exceptions/llm_exception.dart';

// Providers
export 'src/providers/llm_provider.dart';
export 'src/providers/openai_provider.dart';
export 'src/providers/claude_provider.dart';
export 'src/providers/gemini_provider.dart';
export 'src/providers/demo_provider.dart';
export 'src/providers/sse_parser.dart' show parseSse;

// Controller
export 'src/controller/chat_controller.dart';

// UI
export 'src/ui/chat_theme.dart';
export 'src/ui/chat_icons.dart';
export 'src/ui/ai_chat_view.dart';
export 'src/ui/ai_chat_bubble.dart';
export 'src/ui/message_bubble.dart' show MessageContentBuilder;
export 'src/ui/markdown_text.dart' show AiChatMarkdown;
